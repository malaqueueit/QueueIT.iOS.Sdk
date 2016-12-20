import Foundation

enum UrlRequestFailure : Error {
    case invalidUrl(String)
}

class QueueService_NSURLConnectionRequest : NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate
{
    var request: URLRequest
    var response: URLResponse?
    var conn: NSURLConnection?
    var expectedStatusCode: Int
    var actualStatusCode: Int?
    var data: Data?
    var successCallback: QueueServiceSuccess
    var failureCallback: QueueServiceFailure
    
    init(request: URLRequest, expectedStatusCode: Int, successCallback: @escaping QueueServiceSuccess, failureCallback: @escaping QueueServiceFailure) {
        self.request = request
        self.expectedStatusCode = expectedStatusCode
        self.successCallback = successCallback
        self.failureCallback = failureCallback
        super.init()
        self.initiateRequest()
    }
    
    func initiateRequest() {
        self.data = NSMutableData() as Data
        self.actualStatusCode = NSNotFound
        self.conn = NSURLConnection(request: self.request, delegate: self)
    }
    
    enum JSONParseError: Error {
        case notADictionary, missingErrors
    }
    
    func connectionDidFinishLoading(_ conn:NSURLConnection)
    {
        if hasExpectedStatusCode() {
            let data = self.data!
            self.successCallback(data as Data)
        } else {
            let jsonStr = NSString(data: self.data!, encoding: String.Encoding.utf8.rawValue)
            let rawErrorJson = jsonStr?.data(using: String.Encoding.ascii.rawValue, allowLossyConversion: false)
            do {
                let json = try JSONSerialization.jsonObject(with: rawErrorJson!, options: [])
                guard let dict = json as? [String: Any] else { throw JSONParseError.notADictionary }
                guard let errorsJson = dict["errors"] as? [[String: Any]] else { throw JSONParseError.missingErrors}
                let errorMessage = errorsJson[0]["message"] as! String
                self.failureCallback(errorMessage, self.actualStatusCode!)
            }
            catch {
                self.failureCallback("Could not unwrap error data", self.actualStatusCode!)
            }
        }
    }
    
    func connection(_ conn:NSURLConnection, didReceive response:URLResponse)
    {
        self.response = response
        let httpResponse = response as! HTTPURLResponse
        let statusCode = httpResponse.statusCode;
        self.actualStatusCode = statusCode
    }
    
    func connection(_ conn:NSURLConnection, didReceive data:Data)
    {
        appendData(data)
    }
    
    func connection(_ conn:NSURLConnection, didFailWithError error:Error)
    {
        self.failureCallback(error.localizedDescription, 400)
    }
    
    func hasExpectedStatusCode() -> Bool {
        if self.expectedStatusCode != NSNotFound {
            return self.expectedStatusCode == self.actualStatusCode
        }
        return false
    }
    
    func appendData(_ data: Data)
    {
        self.data?.append(data)
    }
    
    
}
