import Foundation

enum PassedTypeError : Error {
    case invalidPassedType
}

enum PassedType {
    case safetyNet, queue, disabled, directLink, afterEvent
}

class QueuePassedDetails {
    var passedType: PassedType?
    
    init(_ passedType: PassedType?) {
        self.passedType = passedType
    }
}
