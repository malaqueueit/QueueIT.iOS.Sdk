import Foundation

public class WidgetDetails {
    public var name: String
    public var data: [String:String]
    
    init(_ name: String, _ data: [String:String]) {
        self.name = name
        self.data = data
    }
}
