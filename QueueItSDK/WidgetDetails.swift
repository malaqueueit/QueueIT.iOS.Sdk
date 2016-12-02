import Foundation

open class WidgetDetails {
    var name: String
    var data: [String:String]
    
    init(_ name: String, _ data: [String:String]) {
        self.name = name
        self.data = data
    }
}
