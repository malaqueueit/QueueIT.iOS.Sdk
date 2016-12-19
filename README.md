# QueueIT.iOS.Sdk
Library for integrating Queue-IT logic into an iOS app. SDK will publish corresponding events based on responses 
from Queue-IT server. As a user of SDK one can subscribe to be notified when:
 * user gets through the queue
 * queueId has been assigned
 * postQueue event is published
 * widget's state has changed
 * queueId has been rejected
 * queue is in 'Idle' mode


##Usage:
    
    func setupAndRunQueueIT {
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
    
    
##Important:
    The SDK logic does not execute in the background. Once the application view  (which integrates with SDK)
    goes out of scope, you will need to invoke run() method on QueueITEngine instance every time the view 
    needs to become active again.




