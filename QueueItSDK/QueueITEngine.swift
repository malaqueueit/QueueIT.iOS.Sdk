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
    var onQueuePassed: (QueuePassedDetails) -> Void
    var onPostQueue: () -> Void
    var onIdleQueue: () -> Void
    var onWidgetChanged: (WidgetDetails) -> Void
    var onQueueIdRejected: (String) -> Void
    var onQueueItError: (String) -> Void
    
    public init(customerId: String, eventId: String, configId: String, widgets:WidgetRequest ..., layoutName: String, language: String,
         onQueueItemAssigned: @escaping (_ queueItemDetails: QueueItemDetails) -> Void,
         onQueuePassed: @escaping (_ queuePassedDetails: QueuePassedDetails) -> Void,
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
        QueueCache.sharedInstatnce.initialize(customerId, eventId)
    }
    
    public func run() {
        if isInSession(tryExtendSession: true) {
            onQueuePassed(QueuePassedDetails(nil))//TODO: should not be nill, figure out what
        } else if isWithinQueueIdSession() {
            checkStatus()
        } else {
            enqueue()
        }
    }
    
    func isWithinQueueIdSession() -> Bool {
        let cache = QueueCache.sharedInstatnce
        if cache.getQueueIdTtl() != nil {
            let currentTime = Date()
            let queueIdTtl = Date(timeIntervalSince1970: Double(cache.getQueueIdTtl()!))
            if(currentTime < queueIdTtl) {
                return true
            }
        }
        return false
    }
    
    func isInSession(tryExtendSession: Bool) -> Bool {
        let cache = QueueCache.sharedInstatnce
        if cache.getRedirectId() != nil {
            let currentDate = Date()
            let sessionDate = Date(timeIntervalSince1970: Double(cache.getSessionTtl()!))
            if(currentDate < sessionDate) {
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
        },
                                            failure: { (error, errorStatusCode) -> Void in
                                                self.onEnqueueFailed(error!, errorStatusCode)
        })
    }
    
    func handleQueueIdAssigned(_ queueIdInfo: QueueIdDTO, _ eventDetails: EventDTO) {
        let cache = QueueCache.sharedInstatnce
        cache.setQueueId(queueIdInfo.queueId)
        cache.setQueueIdTtl(queueIdInfo.ttl + currentTimeUnixUtil())
        self.onQueueItemAssigned(QueueItemDetails(queueIdInfo.queueId, eventDetails))
    }
    
    func checkStatus() {
        let queueId = QueueCache.sharedInstatnce.getQueueId()!
        QueueService.sharedInstance.getStatus(self.customerId, self.eventId, queueId, self.configId, self.widgets, onGetStatus: (onGetStatus))
    }
    
    func onGetStatus(statusDto: StatusDTO) {
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
            print("requesting status...")
            let delaySec = statusDto.nextCallMSec / 1000
            self.executeWithDelay(delaySec, self.checkStatus)
        }
    }
    
    func handleWidgets(_ widgets: [WidgetDTO]) {
        let cache = QueueCache.sharedInstatnce
        for widget in widgets {
            if cache.widgetExist(widget.name) {
                let checksumFromCache = cache.getWidgets()?[widget.name]
                if checksumFromCache != widget.checksum {
                    cache.addOrUpdateWidget(widget)
                    self.onWidgetChanged(WidgetDetails(widget.name, widget.data))
                }
            } else {
                cache.addOrUpdateWidget(widget)
            }
        }
    }
    
    func handleQueueIdRejected(_ reason: String) {
        self.onQueueIdRejected(reason)
        QueueCache.sharedInstatnce.clear()
    }
    
    func handleQueuePassed(_ redirectInfo: RedirectDTO) {
        let cache = QueueCache.sharedInstatnce
        cache.clear()
        cache.setRedirectId(redirectInfo.redirectId)
        cache.setSessionTtlDelta(redirectInfo.ttl)
        cache.setSessionTtl(redirectInfo.ttl + currentTimeUnixUtil())
        cache.setExtendSession(redirectInfo.extendTtl)
        
        self.onQueuePassed(QueuePassedDetails(redirectInfo.passedType))
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
    
    func retryMonitor(_ action: @escaping () -> Void, _ errorMessage: String) {
        if (self.deltaSec < MAX_RETRY_SEC)
        {
            executeWithDelay(self.deltaSec, action)
            self.deltaSec = self.deltaSec * 2;
        } else {
            self.onQueueItError(errorMessage)
        }
    }
    
    func onEnqueueFailed(_ error: ErrorInfo, _ errorStatusCode: Int) {
        if (errorStatusCode >= 400 && errorStatusCode < 500)
        {
            self.onQueueItError(error.message)
        } else if errorStatusCode >= 500 {
            print("retrying, delta: \(self.deltaSec)")
            self.retryMonitor(self.enqueue, error.message)
        }
    }
}
