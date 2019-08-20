import Foundation
import CardinalMobile



class BSCardinalManager: NSObject {
    
    internal var session : CardinalSession!
    internal var cardinalToken : BSCardinalToken?


    //Setup can be called in viewDidLoad
    public func setupCardinalSession(bsToken: BSToken!) {
        session = CardinalSession()
        let config = CardinalSessionConfiguration()

        if (bsToken.isProduction) {

            config.deploymentEnvironment = .production
        } else  {

            config.deploymentEnvironment = .sandbox
        }
        config.timeout = 23000
        config.uiType = .native
        

        config.renderType = [CardinalSessionRenderTypeOTP]
        config.enableQuickAuth = true
        session.configure(config)
    }

    public func getCardinalJWT(bsToken: BSToken) {
        BSApiCaller.getCardinalJWT(bsToken: bsToken) { cardinalToken, errors in
            if (errors != nil) {
                NSLog("No cardinal token")
                return
            }
            self.cardinalToken = cardinalToken
        }
    }

    public func authWith3DS(token: BSToken, currency: String, ammount: String)  -> BS3DSAuthResponse {

        let authRequest: BS3DSAuthRequest = BS3DSAuthRequest(currencyCode: currency, amount: ammount, jwt: cardinalToken?.jwtStr)
        let response: BS3DSAuthResponse  = BS3DSAuthResponse()

        BSApiCaller.requestAuthWith3ds(bsToken: token, authRequest: authRequest) { response, errors in
            if (errors != nil) {
                NSLog("No cardinal token")
                return
            }

        }
        return response
    }

//    public func process(response: BS3DSAuthResponse) {
//
//    }


}
