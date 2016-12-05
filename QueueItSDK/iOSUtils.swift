import Foundation
import UIKit

class iOSUtils {
    
    class func getUserId() -> String {
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }
}
