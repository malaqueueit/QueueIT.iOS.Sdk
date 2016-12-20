import Foundation

public class QueueITEngine {
    let MAX_RETRY_SEC = 10
    let INITIAL_WAIT_RETRY_SEC = 1
    
    var customerId: String
    var eventId: String
    var configId: String
    var layoutName: String
    var language: String
    var widgets = [WidgetRequest]()
    var deltaSec: Int
    
    var onQueueItemAssigned: (QueueItemDetails) -> Void
    var onQueuePassed: () -> Void
    var onPostQueue: () -> Void
    var onIdleQueue: () -> Void
    var onWidgetChanged: (WidgetDetails) -> Void
    var onQueueIdRejected: (String) -> Void
    var onQueueItError: (String) -> Void
    
    public init(customerId: String, eventId: String, configId: String, widgets:WidgetRequest ..., layoutName: String, language: String,
         onQueueItemAssigned: @escaping (_ queueItemDetails: QueueItemDetails) -> Void,
         onQueuePassed: @escaping () -> Void,
         onPostQueue: @escaping () -> Void,
         onIdleQueue: @escaping () -> Void,
         onWidgetChanged: @escaping(WidgetDetails) -> Void,
         onQueueIdRejected: @escaping(String) -> Void,
         onQueueItError: @escaping(String) -> Void) {
        self.deltaSec = self.INITIAL_WAIT_RETRY_SEC
        self.customerId = customerId
        self.eventId = eventId
        self.configId = configId
        self.layoutName = layoutName
        self.language = language
        self.onQueueItemAssigned = onQueueItemAssigned
        self.onQueuePassed = onQueuePassed
        self.onPostQueue = onPostQueue
        self.onIdleQueue = onIdleQueue
        self.onWidgetChanged = onWidgetChanged
        self.onQueueIdRejected = onQueueIdRejected
        self.onQueueItError = onQueueItError
        for w in widgets {
            self.widgets.append(w)
        }
        QueueCache.sharedInstance.initialize(customerId, eventId)
    }
    
    public func run() {
        if isInSession(tryExtendSession: true) {
            onQueuePassed()
        } else if isWithinQueueIdSession() {
            if ensureConnected() {
                checkStatus()
            }
        } else if ensureConnected() {
            enqueue()
        }
    }
    
    func ensureConnected() -> Bool {
        var count = 0;
        while count < 5
        {
            if !iOSUtils.isInternetAvailable()
            {
                sleep(1)
                count += 1
            }
            else
            {
                return true
            }
        }
        self.onQueueItError("No internet connection!")
        return false
    }
    
    func isWithinQueueIdSession() -> Bool {
        let cache = QueueCache.sharedInstance
        if cache.getQueueIdTtl() != nil {
            let currentTime = Date()
            let queueIdTtl = Date(timeIntervalSince1970: Double(cache.getQueueIdTtl()!))
            if currentTime < queueIdTtl {
                return true
            }
        }
        return false
    }
    
    func isInSession(tryExtendSession: Bool) -> Bool {
        let cache = QueueCache.sharedInstance
        if cache.getRedirectId() != nil {
            let currentDate = Date()
            let sessionDate = Date(timeIntervalSince1970: Double(cache.getSessionTtl()!))
            if currentDate < sessionDate {
                if tryExtendSession {
                    let isExtendSession = cache.getExtendSession()
                    if isExtendSession != nil {
                        cache.setSessionTtl(currentTimeUnixUtil() + cache.getSessionTtlDelta()!)
                    }
                }
                return true
            }
        }
        return false
    }
    
    func enqueue() {
        QueueService.sharedInstance.enqueue(self.customerId, self.eventId, self.configId, layoutName: nil, language: nil,
            success: { (enqueueDto) -> Void in
                self.onEnqueueSuccess(enqueueDto)
            },
            failure: { (errorMessage, errorStatusCode) -> Void in
                self.onEnqueueFailed(errorMessage, errorStatusCode)
            })
    }
    
    func onEnqueueSuccess(_ enqueueDto: EnqueueDTO) {
        self.resetDeltaSec()
        let redirectInfo = enqueueDto.redirectDto
        if redirectInfo != nil {
            self.handleQueuePassed(redirectInfo!)
        } else {
            let eventState = enqueueDto.eventDetails.state
            if eventState == .queue || eventState == .prequeue {
                self.handleQueueIdAssigned(enqueueDto.queueIdDto!, enqueueDto.eventDetails)
                self.checkStatus()
            } else if eventState == .postqueue {
                self.onPostQueue()
            } else if eventState == .idle {
                self.onIdleQueue()
            }
        }
    }
    
    func handleQueueIdAssigned(_ queueIdInfo: QueueIdDTO, _ eventDetails: EventDTO) {
        let cache = QueueCache.sharedInstance
        cache.setQueueId(queueIdInfo.queueId)
        cache.setQueueIdTtl(queueIdInfo.ttl + currentTimeUnixUtil())
        self.onQueueItemAssigned(QueueItemDetails(queueIdInfo.queueId, eventDetails))
    }
    
    func checkStatus() {
        let queueId = QueueCache.sharedInstance.getQueueId()!
        QueueService.sharedInstance.getStatus(self.customerId, self.eventId, queueId, self.configId, self.widgets, onGetStatus: (onGetStatusSuccess), onFailed: (onGetStatusFailed))
    }
    
    func onGetStatusSuccess(statusDto: StatusDTO) {
        self.resetDeltaSec()
        if statusDto.widgets != nil {
            self.handleWidgets(statusDto.widgets!)
        }
        if statusDto.rejectDto != nil {
            self.handleQueueIdRejected((statusDto.rejectDto?.reason)!)
        }
        else if statusDto.redirectDto != nil {
            self.handleQueuePassed(statusDto.redirectDto!)
        }
        else if statusDto.eventDetails?.state == .postqueue {
            self.onPostQueue()
        }
        else {
            let delaySec = statusDto.nextCallMSec / 1000
            self.executeWithDelay(delaySec, self.checkStatus)
        }
    }
    
    func onGetStatusFailed(errorMessage: String) {
        if ensureConnected() {
            self.retryMonitor(self.checkStatus, errorMessage)
        }
    }
    
    func handleWidgets(_ widgets: [WidgetDTO]) {
        let cache = QueueCache.sharedInstance
        for widget in widgets {
            if cache.widgetExist(widget.name) {
                let checksumFromCache = cache.getWidgets()?[widget.name]
                if checksumFromCache != widget.checksum {
                    cache.addOrUpdateWidget(widget)
                    self.onWidgetChanged(WidgetDetails(widget.name, widget.data))
                }
            } else {
                cache.addOrUpdateWidget(widget)
                self.onWidgetChanged(WidgetDetails(widget.name, widget.data))
            }
        }
    }
    
    func handleQueueIdRejected(_ reason: String) {
        self.onQueueIdRejected(reason)
        QueueCache.sharedInstance.clear()
    }
    
    func handleQueuePassed(_ redirectInfo: RedirectDTO) {
        let cache = QueueCache.sharedInstance
        cache.clear()
        cache.setRedirectId(redirectInfo.redirectId)
        cache.setSessionTtlDelta(redirectInfo.ttl)
        cache.setSessionTtl(redirectInfo.ttl + currentTimeUnixUtil())
        cache.setExtendSession(redirectInfo.extendTtl)
        
        self.onQueuePassed()
    }
    
    func currentTimeUnixUtil() -> Int64 {
        let val = Int64(NSDate().timeIntervalSince1970)
        return val
    }
    
    func executeWithDelay(_ delaySec: Int, _ action: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delaySec), execute: {
            action()
        })
    }
    
    func resetDeltaSec() {
        self.deltaSec = self.INITIAL_WAIT_RETRY_SEC
    }
    
    func retryMonitor(_ action: @escaping () -> Void, _ errorMessage: String) {
        if self.deltaSec < MAX_RETRY_SEC
        {
            executeWithDelay(self.deltaSec, action)
            self.deltaSec = self.deltaSec * 2;
        } else {
            self.onQueueItError(errorMessage)
        }
    }
    
    func onEnqueueFailed(_ message: String, _ errorStatusCode: Int) {
        if errorStatusCode >= 400 && errorStatusCode < 500
        {
            self.onQueueItError(message)
        } else if errorStatusCode >= 500 {
            self.retryMonitor(self.enqueue, message)
        }
    }
}
