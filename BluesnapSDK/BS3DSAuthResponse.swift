import Foundation

public class BS3DSAuthResponse: NSObject, BSModel {

    var enrollmentStatus: String?
    var acsUrl: String?
    var payload: String?
    var transactionId: String?


    override init() {
        super.init()
    }


    public func toJson() -> ([String: Any])! {
        var request: [String: Any] = [:]


        return request

    }

    public static func parseJson(data: Data?) -> (BS3DSAuthResponse?, BSErrors?) {

        do {
            let resultData: BS3DSAuthResponse = BS3DSAuthResponse()
            guard let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject]
                    else {
                let resultError = BSErrors.unknown
                return (nil, resultError)
            }
            let authResponse: BS3DSAuthResponse = BS3DSAuthResponse()
            authResponse.enrollmentStatus = json["enrollmentStatus"] as? String
            authResponse.acsUrl = json["acsUrl"] as? String
            authResponse.payload = json["payload"] as? String
            authResponse.transactionId = json["transactionId"] as? String
            return (resultData, nil)
        } catch {
            NSLog("Parse error")
        }
        return (nil, BSErrors.unknown)
    }

}