import Foundation
import CardinalMobile



class BSCardinalManager: NSObject {

    
    internal var session : CardinalSession!
    internal var cardinalToken : String?
    private var cardinalFailure: Bool = false
    internal static var instance: BSCardinalManager = BSCardinalManager()
    
    override private init(){}
    
    public func setCardinalJWT(cardinalToken: String?) {
        cardinalFailure = false
        
        if (cardinalToken == nil) {
            cardinalFailure = true
        }
        
        self.cardinalToken = cardinalToken
    }
    
    //Setup can be called in viewDidLoad
    public func configureCardinal(isProduction: Bool) {
        session = CardinalSession()
        let config = CardinalSessionConfiguration()

        if (isProduction) {

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

    
    public func setupCardinal(_ completion: @escaping () -> Void) {
        if (isCardinalFailure()){
            NSLog("skipping due to cardinal failure")
            return
        }
        
        session.setup(jwtString: self.cardinalToken!,
                      completed: {(consumerSessionID: String) in
                        completion()
                        },
                      
                      validated: {(validateResponse: CardinalResponse) in
                        // in case of an error we continue with the flow
                        self.cardinalFailure = true
                        completion()
                        })
    }
    
    public func authWith3DS(currency: String, amount: String, _ completion: @escaping () -> Void)  -> BS3DSAuthResponse? {
        if (isCardinalFailure()){
            NSLog("skipping due to cardinal failure")
            return nil
        }

        let response: BS3DSAuthResponse  = BS3DSAuthResponse()

        BSApiManager.requestAuthWith3ds(currency: currency, amount: amount, cardinalToken: cardinalToken!, completion: { response, errors in
            if (errors != nil) {
                NSLog("Error in request auth with 3ds")
            }
        
            completion()
        })
        
        return response
    }
    
    private func isCardinalFailure() -> Bool {
        return cardinalFailure
    }


    private  class validationDelegate: CardinalValidationDelegate {

        var completion :  () -> Void

        init (_ completion: @escaping () -> Void) {
            self.completion = completion
        }

        func cardinalSession(cardinalSession session: CardinalSession!, stepUpValidated validateResponse: CardinalResponse!, serverJWT: String!) {

            switch validateResponse.actionCode {
            case .success:
                // Handle successful transaction, send JWT to backend to verify
                break

            case .noAction:
                // Handle no actionable outcome
                break

            case .failure:
                // Handle failed transaction attempt
                break

            case .error:
                // Handle service level error
                break

            case .cancel:
                // Handle transaction canceled by user
                break
            }

            completion()
        }

    }

    public func process(response: BS3DSAuthResponse?, _ completion: @escaping () -> Void) {
        let delegate : validationDelegate = validationDelegate(completion)

        if let authResponse = response {
                session.continueWith(transactionId: authResponse.transactionId!, payload: authResponse.payload!, validationDelegate:
                delegate)

        }
    }


}
