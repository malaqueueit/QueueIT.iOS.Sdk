# QueueIT.iOS.Sdk
Library for integrating Queue-IT sdk into an iOS app

##Usage:



    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:        [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let customerId = "sasha"
        let eventId = "itl5"
        let configId = "configId1"
        let widget1 = WidgetRequest("CountDown", 1)
        let widget2 = WidgetRequest("Progress", 1)
        let engine = QueueITEngine(customerId: customerId,
                                   eventId: eventId,
                                   configId: configId,
                                   widgets: widget1, widget2,
                                   layoutName: "",
                                   language: "",
                                   onQueueItemAssigned: (onQueueItemAssigned),
                                   onQueuePassed: (onQueuePassed),
                                   onPostQueue: (onPostQueue),
                                   onIdleQueue: (onIdleQueue),
                                   onWidgetChanged: (onWidgetChanged),
                                   onQueueIdRejected: (onQueueIdRejected),
                                   onQueueItError: (onQueueItError))
        
        engine.run()
        
        return true
    }
    
    func onQueueItemAssigned(queueItemDetails: QueueItemDetails) {
        print(queueItemDetails.queueId)
    }
    
    func onQueuePassed(queuePassedDetails: QueuePassedDetails) {
        print("REDIRECTED!!! RedirectType: \(queuePassedDetails.passedType)")
    }
    
    func onPostQueue() {
        print("Postqueue published...")
    }
    
    func onIdleQueue() {
        print("Idle queue published...")
    }
    
    func onWidgetChanged(widget: WidgetDetails) {
        print("Widget changed!: \(widget.name)")
        if widget.name == "Progress" {
            print("value: \(widget.data["progress"])")
        }
    }
    
    func onQueueIdRejected(reason: String) {
        print("QueueId rejected! Reason: \(reason)")
    }
    
    func onQueueItError(errorMessage: String) {
        print("ERROR: \(errorMessage)")
    }




