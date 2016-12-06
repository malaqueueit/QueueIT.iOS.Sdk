import Foundation

enum PassedTypeError : Error {
    case invalidPassedType
}

public enum PassedType {
    case safetyNet, queue, disabled, directLink, afterEvent
}

public class QueuePassedDetails {
    public var passedType: PassedType?
    
    init(_ passedType: PassedType?) {
        self.passedType = passedType
    }
}
