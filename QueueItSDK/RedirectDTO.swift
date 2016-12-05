import Foundation

class RedirectDTO {
    var passedType: PassedType
    var ttl: Int
    var extendTtl: Bool
    var redirectId: String
    
    init(_ passedType: PassedType, _ ttl: Int, _ extendTtl: Bool, _ redirectId: String) {
        self.passedType = passedType
        self.ttl = ttl
        self.extendTtl = extendTtl
        self.redirectId = redirectId
    }
}
