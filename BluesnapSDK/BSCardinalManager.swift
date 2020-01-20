import Foundation
import CardinalMobile



class BSCardinalManager: NSObject {

    internal static let SUPPORTED_CARD_VERSION = "2"
    private var session : CardinalSession!
    private var cardinalToken : String?
    private var cardinalError: Bool = false
    private var threeDSAuthResult: String = ThreeDSManagerResponse.AUTHENTICATION_UNAVAILABLE.rawValue
    public static var instance: BSCardinalManager = BSCardinalManager()
    
    public enum ThreeDSManagerResponse : String{
        // server response
        case AUTHENTICATION_BYPASSED
        case AUTHENTICATION_SUCCEEDED
        case AUTHENTICATION_UNAVAILABLE
        case AUTHENTICATION_FAILED
        
        // challenge was canceled by the user
        case AUTHENTICATION_CANCELED

        // cardinal internal error or server error
        case THREE_DS_ERROR
        
        // V1 unsupported cards
        case CARD_NOT_SUPPORTED
    }
    
    override private init(){}
    
    internal func setCardinalJWT(cardinalToken: String?) {
        // reset CardinalFailure and CardinalResult for singleton use
        setCardinalError(cardinalError: false)
        setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.AUTHENTICATION_UNAVAILABLE.rawValue)
        
        self.cardinalToken = cardinalToken
    }
    
    //Setup can be called in viewDidLoad
    internal func configureCardinal(isProduction: Bool) {
        if (!is3DSecureEnabled()){ // 3DS is disabled in merchant configuration
            NSLog("skipping due to missing cardinal token- 3D Secure disabled")
            return
        }
        
        session = CardinalSession()
        let config = CardinalSessionConfiguration()

        if (isProduction) {

            config.deploymentEnvironment = .production
        } else  {

            config.deploymentEnvironment = .staging
        }
        config.timeout = 23000
        config.uiType = .native

        let renderType = [CardinalSessionRenderTypeOTP, CardinalSessionRenderTypeHTML]
        config.renderType = renderType
        config.enableQuickAuth = true
        config.enableDFSync = true
        session.configure(config)
    }
    
    internal func setupCardinal(_ completion: @escaping () -> Void) {
        if (!is3DSecureEnabled()){ // 3DS is disabled in merchant configuration
            NSLog("skipping due to missing cardinal token- 3D Secure disabled")
            //NSLog("skipping due to cardinal failure")
            completion()
            return
        }
        
        session.setup(jwtString: self.cardinalToken!,
                      completed: { sessionID in
                        NSLog("cardinal setup complete")
                        completion()
                        },
                      
                      validated: { validateResponse in
                        // in case of an error we continue with the flow
                        NSLog("cardinal setup failed")
                        self.setCardinalError(cardinalError: true)
                        completion()
                        })
        
    }
    
    public func authWith3DS(currency: String, amount: String, creditCardNumber: String, _ completion: @escaping (BSErrors?) -> Void, _ startActivityIndicator: @escaping () -> Void, _ stopActivityIndicator: @escaping () -> Void) {
        if (!is3DSecureEnabled() || isCardinalError()){ // 3DS is disabled in merchant configuration or error occurred
            NSLog("skipping due to missing cardinal token- 3D Secure disabled or cardinal error")
            completion(nil)
            return
        }

//        let response: BS3DSAuthResponse  = BS3DSAuthResponse()

        BSApiManager.requestAuthWith3ds(currency: currency, amount: amount, cardinalToken: cardinalToken!, completion: { response, error in
            if (error != nil) {
                NSLog("BS Server Error in 3DS Auth API call: \(String(describing: error))")
                self.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.THREE_DS_ERROR.rawValue);
                completion(error)
            }
        
            if let response = response, let threeDSVersion = response.threeDSVersion, let enrollmentStatus = response.enrollmentStatus {
                if (enrollmentStatus == "CHALLENGE_REQUIRED") {
                    // verifying 3DS version
                    let index = threeDSVersion.index(threeDSVersion.startIndex, offsetBy: 1)
                    let firstChar = threeDSVersion[..<index]
                    
                    if (!(firstChar == BSCardinalManager.SUPPORTED_CARD_VERSION)) {
                        self.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.CARD_NOT_SUPPORTED.rawValue);
                        completion(nil)
                    } else { // call process to trigger cardinal challenge
                        self.process(response: response ,creditCardNumber: creditCardNumber, completion: completion, startActivityIndicator, stopActivityIndicator)
                    }
                    
                } else { // populate Enrollment Status as 3DS result
                    self.setThreeDSAuthResult(threeDSAuthResult: enrollmentStatus)
                    completion(nil)
                }
            } else {
                self.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.THREE_DS_ERROR.rawValue);
                NSLog("Error in getting response from 3DS Auth API call")
                completion(nil)
            }

        })
        
    }
    
    private class validationDelegate: CardinalValidationDelegate {
        
        var completion :  (BSErrors?) -> Void
        var startActivityIndicator :  () -> Void
        
        init (_ completion: @escaping (BSErrors?) -> Void, _ startActivityIndicator: @escaping () -> Void) {
            self.completion = completion
            self.startActivityIndicator = startActivityIndicator
        }
        
        func cardinalSession(cardinalSession session: CardinalSession!, stepUpValidated validateResponse: CardinalResponse!, serverJWT: String!) {
            
            switch validateResponse.actionCode {
            case .success,
                 .noAction:
                self.startActivityIndicator()
                BSCardinalManager.instance.processCardinalResult(resultJwt: serverJWT, completion: self.completion)
                break
                
            case .failure:
                self.startActivityIndicator()
                BSCardinalManager.instance.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.AUTHENTICATION_FAILED.rawValue)
                completion(nil)
                break
                
            case .error:
                self.startActivityIndicator()
                BSCardinalManager.instance.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.THREE_DS_ERROR.rawValue)
                completion(nil)
                break
                
            case .cancel:
                self.startActivityIndicator()
                BSCardinalManager.instance.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.AUTHENTICATION_CANCELED.rawValue)
                completion(nil)
                break
                
            }
            
        }
        
    }
    
    private func process(response: BS3DSAuthResponse?, creditCardNumber: String, completion: @escaping (BSErrors?) -> Void, _ startActivityIndicator: @escaping () -> Void, _ stopActivityIndicator: @escaping () -> Void) {
        let delegate : validationDelegate = validationDelegate(completion, startActivityIndicator)

        
        if let authResponse = response {
            
            setupCardinal {
                self.session.processBin(creditCardNumber, completed: {
                    DispatchQueue.main.async {
                        self.session.continueWith(transactionId: authResponse.transactionId!, payload: authResponse.payload!, validationDelegate:
                            delegate)
                        stopActivityIndicator()
                    }
                })
            }

        }
    }
    
    private func processCardinalResult(resultJwt: String, completion: @escaping (BSErrors?) -> Void) {
        
        BSApiManager.processCardinalResult(cardinalToken: cardinalToken!, resultJwt: resultJwt, completion: { response, error in
            if (error != nil) {
                NSLog("BS Server Error in 3DS process result API call: \(String(describing: error))")
                self.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.THREE_DS_ERROR.rawValue);
                completion(error)
            }
            
            if let response = response, let authResult = response.authResult {
                self.setThreeDSAuthResult(threeDSAuthResult: authResult)
                completion(nil)
                
            } else {
                NSLog("Error in getting response from 3DS process result API call")
                self.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.THREE_DS_ERROR.rawValue);
                completion(nil)
            }
            
        })
        
    }
    
    private func is3DSecureEnabled() -> Bool {
        return (cardinalToken != nil)
    }
    
    private func isCardinalError() -> Bool {
        return cardinalError
    }
    
    private func setCardinalError(cardinalError: Bool) {
        if (cardinalError) {
            setThreeDSAuthResult(threeDSAuthResult: BSCardinalManager.ThreeDSManagerResponse.THREE_DS_ERROR.rawValue);
        }
        self.cardinalError = cardinalError;
    }
    
    public func getThreeDSAuthResult() -> String {
        return threeDSAuthResult
    }
    
    fileprivate func setThreeDSAuthResult(threeDSAuthResult: String) {
        self.threeDSAuthResult = threeDSAuthResult
    }
    
}


