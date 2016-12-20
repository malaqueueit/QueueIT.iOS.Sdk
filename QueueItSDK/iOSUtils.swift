import Foundation
import UIKit
import SystemConfiguration

class iOSUtils {
    
    class func getUserId() -> String {
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }
    
    class func getSystemInfo() -> String {
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        return "\(systemName) \(systemVersion)"
    }
    
    class func getSDKVersion() -> String {
        return "iOS-2.1.5"
    }
    
    class func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
