import Foundation

class QueueCache {
    fileprivate var KEY_CACHE = ""
    fileprivate let KEY_QUEUE_ID = "queueId"
    fileprivate let KEY_QUEUEID_TTL = "queueIdTtl"
    fileprivate let KEY_EXTEND_SESSION = "extendSession"
    fileprivate let KEY_REDIRECT_ID = "redirectId"
    fileprivate let KEY_SESSION_TTL = "sessionTtl"
    fileprivate let KEY_SESSION_TTL_DELTA = "sessionTtlDelta"
    fileprivate let KEY_WIDGETS = "widgets"
    
    static let sharedInstatnce  = QueueCache()
    
    func initialize(_ customerId: String, _ eventId: String) {
        KEY_CACHE = "\(customerId)-\(eventId)"
    }
    
    func getWidgets() -> [String:String]? {
        let cache: [String : Any] = ensureCache()
        let widgets: [String:String]? = (cache[KEY_WIDGETS] as? [String:String]?)!
        return widgets
    }
    
    func widgetExist(_ name: String) -> Bool {
        let widgets = getWidgets()
        return widgets?[name] != nil
    }
    
    func getQueueId() -> String? {
        let cache: [String : Any] = ensureCache()
        let queueId: String? = cache[KEY_QUEUE_ID] as? String
        return queueId
    }
    
    func hasQueueId() -> Bool {
        let cache: [String : Any] = ensureCache()
        let queueId: String? = cache[KEY_QUEUE_ID] as? String
        return queueId != nil
    }
    
    func getQueueIdTtl() -> Int64? {
        let cache: [String : Any] = ensureCache()
        let queueIdTtl: Int64? = cache[KEY_QUEUEID_TTL] as? Int64
        return queueIdTtl
    }
    
    func getExtendSession() -> Bool? {
        let cache: [String : Any] = ensureCache()
        let extendSession: Bool? = cache[KEY_EXTEND_SESSION] as? Bool
        return extendSession
    }
    
    func getRedirectId() -> String? {
        let cache: [String : Any] = ensureCache()
        let redirectId: String? = cache[KEY_REDIRECT_ID] as? String
        return redirectId
    }
    
    func getSessionTtl() -> Int64? {
        let cache: [String : Any] = ensureCache()
        let sessionTtl: Int64? = cache[KEY_SESSION_TTL] as? Int64
        return sessionTtl
    }
    
    func getSessionTtlDelta() -> Int? {
        let cache: [String : Any] = ensureCache()
        let sessionTtlDelta: Int? = cache[KEY_SESSION_TTL_DELTA] as? Int
        return sessionTtlDelta
    }
    
    func setQueueId(_ queueId: String) {
        update(key: KEY_QUEUE_ID, value: queueId)
    }
    
    func setExtendSession(_ extendSession: Bool) {
        update(key: KEY_EXTEND_SESSION, value: extendSession)
    }
    
    func setRedirectId(_ redirectId: String) {
        update(key: KEY_REDIRECT_ID, value: redirectId)
    }
    
    func setQueueIdTtl(_ queueIdTtl: Int64) {
        update(key: KEY_QUEUEID_TTL, value: queueIdTtl)
    }
    
    func setSessionTtl(_ sessionTtl: Int64) {
        update(key: KEY_SESSION_TTL, value: sessionTtl)
    }
    
    func addOrUpdateWidget(_ widget: WidgetDTO) {
        var widgets = getWidgets()
        if widgets == nil {
            widgets = [String:String]()
        }
        widgets![widget.name] = widget.checksum
        update(key: KEY_WIDGETS, value: widgets!)
    }
    
    func setSessionTtlDelta(_ sessionTtlDelta: Int) {
        update(key: KEY_SESSION_TTL_DELTA, value: sessionTtlDelta)
    }
    
    func clear() {
        var cache: [String : Any] = ensureCache()
        cache.removeAll()
        setCache(cache)
    }
    
    func ensureCache() -> [String : Any] {
        let defaults = UserDefaults.standard
        if defaults.dictionary(forKey: KEY_CACHE) == nil {
            let emptyDict = [String : Any]()
            setCache(emptyDict)
        }
        let cache : [String : Any] = defaults.dictionary(forKey: KEY_CACHE)!
        return cache
    }
    
    func update(key: String, value: Any) {
        var cache : [String : Any] = ensureCache()
        cache.updateValue(value, forKey: key)
        setCache(cache)
    }
    
    func setCache(_ cache: [String : Any]) {
        let defaults = UserDefaults.standard
        defaults.set(cache, forKey: KEY_CACHE)
        defaults.synchronize()
    }
}
