import Foundation

public class WidgetRequest {
    var name: String
    var version: Int
    
    public init(_ name: String, _ version: Int) {
        self.name = name
        self.version = version
    }
}
