import Foundation

enum EventStateError : Error {
    case invalidEventState
}

public enum EventState {
    case idle, prequeue, queue, postqueue
}

public class EventDTO {
    var state: EventState
    
    public init(_ state: EventState) {
        self.state = state
    }
}
