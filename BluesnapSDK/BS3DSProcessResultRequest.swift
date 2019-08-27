
import Foundation

public class BS3DSProcessResultRequest: NSObject, BSModel {
    
    var jwt: String?
    var resultJwt: String?
    
    public init(jwt: String?, resultJwt: String?) {
        self.jwt = jwt
        self.resultJwt = resultJwt
        super.init()
    }
    
    public func toJson() -> ([String: Any])! {
        var request: [String: Any] = [:]
        
        if let currencyCode  = self.jwt {
            request["jwt"] = currencyCode
        }
        if let amount  = self.resultJwt {
            request["resultJwt"] = amount
        }
        
        return request
        
    }
    
}
