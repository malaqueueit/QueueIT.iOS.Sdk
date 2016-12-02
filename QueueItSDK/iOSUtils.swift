import Foundation
import UIKit

open class iOSUtils {
    
    class func getUserId() -> String {
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }
}
