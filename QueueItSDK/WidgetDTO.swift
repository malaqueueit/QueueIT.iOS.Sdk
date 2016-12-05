import Foundation

class WidgetDTO {
    var name: String
    var checksum: String
    var data: [String:String]
    
    init(_ name: String, _ checksum: String, _ data: [String:String]) {
        self.name = name
        self.checksum = checksum
        self.data = data
    }
}
