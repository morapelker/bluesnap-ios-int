import Foundation
import CardinalMobile



class BSCardinalManager: NSObject {

    
    internal var session : CardinalSession!
    internal var cardinalToken : String?
    private var cardinalFailure: Bool = false
    private var cardinalResult: String = CardinalManagerResponse.AUTHENTICATION_UNAVAILABLE.rawValue
    internal static var instance: BSCardinalManager = BSCardinalManager()
    
    public enum CardinalManagerResponse : String{
        case AUTHENTICATION_BYPASSED
        case AUTHENTICATION_SUCCEEDED
        case AUTHENTICATION_UNAVAILABLE
        case AUTHENTICATION_FAILED
        case AUTHENTICATION_NOT_SUPPORTED
    }
    
    override private init(){}
    
    public func setCardinalJWT(cardinalToken: String?) {
        // reset CardinalFailure and CardinalResult for singleton use
        cardinalFailure = false
        cardinalResult = CardinalManagerResponse.AUTHENTICATION_UNAVAILABLE.rawValue
        
        if (cardinalToken == nil) {
            cardinalFailure = true
        }
        
        self.cardinalToken = cardinalToken
    }
    
    //Setup can be called in viewDidLoad
    public func configureCardinal(isProduction: Bool) {
        if (isCardinalFailure()){
            NSLog("skipping due to cardinal failure")
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
    
    public func setupCardinal(_ completion: @escaping () -> Void) {
        if (isCardinalFailure()){
            NSLog("skipping due to cardinal failure")
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
                        self.cardinalFailure = true
                        completion()
                        })
        
    }
    
    public func authWith3DS(currency: String, amount: String, creditCardNumber: String, _ completion: @escaping (Bool?) -> Void, _ startActivityIndicator: @escaping () -> Void, _ stopActivityIndicator: @escaping () -> Void) {
        if (isCardinalFailure()){
            NSLog("skipping due to cardinal failure")
            return
        }

//        let response: BS3DSAuthResponse  = BS3DSAuthResponse()

        BSApiManager.requestAuthWith3ds(currency: currency, amount: amount, cardinalToken: cardinalToken!, completion: { response, errors in
            if (errors != nil) {
                NSLog("Error in request auth with 3ds")
            }
        
            if (response?.enrollmentStatus == "CHALLENGE_REQUIRED") { // triggering cardinal challenge
                self.process(response: response ,creditCardNumber: creditCardNumber, completion: completion, startActivityIndicator, stopActivityIndicator)
            } else {
                self.cardinalResult = response?.enrollmentStatus ?? CardinalManagerResponse.AUTHENTICATION_UNAVAILABLE.rawValue
                completion(nil)
            }

        })
        
    }
    
    private class validationDelegate: CardinalValidationDelegate {
        
        var completion :  (Bool?) -> Void
        var startActivityIndicator :  () -> Void
        
        init (_ completion: @escaping (Bool?) -> Void, _ startActivityIndicator: @escaping () -> Void) {
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
                BSCardinalManager.instance.cardinalResult = BSCardinalManager.CardinalManagerResponse.AUTHENTICATION_FAILED.rawValue
                completion(nil)
                break
                
            case .error:
                self.startActivityIndicator()
                BSCardinalManager.instance.cardinalResult = BSCardinalManager.CardinalManagerResponse.AUTHENTICATION_UNAVAILABLE.rawValue
                completion(nil)
                break
                
            case .cancel:
                self.startActivityIndicator()
                BSCardinalManager.instance.cardinalResult = BSCardinalManager.CardinalManagerResponse.AUTHENTICATION_UNAVAILABLE.rawValue
                completion(true)
                break
                
            }
            
        }
        
    }
    
    public func process(response: BS3DSAuthResponse?, creditCardNumber: String, completion: @escaping (Bool?) -> Void, _ startActivityIndicator: @escaping () -> Void, _ stopActivityIndicator: @escaping () -> Void) {
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
    
    public func processCardinalResult(resultJwt: String, completion: @escaping (Bool?) -> Void) {
        
        BSApiManager.processCardinalResult(cardinalToken: cardinalToken!, resultJwt: resultJwt, completion: { response, errors in
            if (errors != nil) {
                NSLog("Error in process 3ds result")
                BSCardinalManager.instance.cardinalResult = BSCardinalManager.CardinalManagerResponse.AUTHENTICATION_UNAVAILABLE.rawValue
            }
            
            BSCardinalManager.instance.cardinalResult = response?.authResult ?? BSCardinalManager.CardinalManagerResponse.AUTHENTICATION_UNAVAILABLE.rawValue
            
            completion(nil)
        })
        
    }
    
    private func isCardinalFailure() -> Bool {
        return cardinalFailure
    }
    
    public func getCardinalResult() -> String {
        return cardinalResult
    }
    
}


