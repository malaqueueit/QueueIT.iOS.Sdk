import Foundation

open class WidgetRequest {
    var name: String
    var version: Int
    
    init(_ name: String, _ version: Int) {
        self.name = name
        self.version = version
    }
}
