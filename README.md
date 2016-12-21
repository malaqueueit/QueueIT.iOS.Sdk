# QueueIT.iOS.Sdk
Library for integrating Queue-IT logic into an iOS app. SDK will publish corresponding events based on responses 
from Queue-IT server. As a user of SDK one can subscribe to be notified when:
 * user gets through the queue
 * queueId has been assigned
 * postQueue event is published
 * widget's state has changed
 * queueId has been rejected
 * queue is in 'Idle' mode


##Installation:
    SDK can be installed via following options:
    *By including QueueITSDK project into the application project and adding it as an Embeded Binaries in the project's target properties.
    *From cocoapods repository by including following pod into app's Podfile:
        pod 'QueueITSDK', '~> 1.0.7'


##Usage:
    
    func setupAndRunQueueIT {
        let customerId = "exampleCustomerId"
        let eventId = "exampleEventId"
        let configId = "exampleConfigId"
        let countDownWidget = WidgetRequest("CountDown", 1)
        let progressWidget = WidgetRequest("Progress", 1)
        let engine = QueueITEngine(customerId: customerId,
                                   eventId: eventId,
                                   configId: configId,
                                   widgets: countDownWidget, progressWidget,
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
    
    func onQueuePassed() {
        print("You have been redirected!")
    }
    
    func onPostQueue() {
        print("Event has ended!")
    }
    
    func onIdleQueue() {
        print("Event has not started yet!")
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

##Widgets:
    Widgets are object definitions which can provide specific values that can be used by an application. 
    These values are frequently updated by QueueIT server and reflect the state of various queue-specific 
    runtime components. The current version of SDK supports following widgets: "CountDown", "Progress".
    *"CountDown": { "secondsToEventStart" : "10" } 
    *"Progress": { "progress" : "0.2" } 
    The key-value pairs (i.e. "progress" : "0.2") will be available on "data" property of WidgetDetails object.



