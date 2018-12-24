//
//  BluesnapSDKIntegrationTests.swift
//  BluesnapSDKIntegrationTests
//
//  Created by Sivani on 11/12/2018.
//  Copyright © 2018 Bluesnap. All rights reserved.
//

import XCTest
@testable import BluesnapSDK

class BluesnapSDKIntegrationTests: XCTestCase {
    let email = "test@sdk.com"
    
    let purchaseCCData = ["cardLastFourDigits": "1111", "expirationMonth": "10","expirationYear": "2020", "cardType": "VISA"]
    
    let purchaseBillingData = [ "firstName": "La", "lastName": "Fleur", "address1": "555 Broadway street",
                                "city": "New York", "zip": "3abc 324a", "country": "us", "state": "NY"]
    
    let purchaseShippingData = ["firstName": "Taylor", "lastName": "Love", "address1": "AddressTest",
                                "city": "CityTest", "zip": "12345", "country": "br", "state": "RJ"]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    /**
     Called by the BlueSnapSDK when token expired error is recognized.
     Here we generate and set a new token, so that when the action re-tries, it will succeed.
     */
    private func generateAndSetBsToken(completion: @escaping (_ token: BSToken?, _ error: BSErrors?)->Void) {
        
        NSLog("Got BS token expiration notification!")
        
        BlueSnapSDK.createSandboxTestToken(completion: { resultToken, errors in
            NSLog("Got BS token= \(resultToken?.getTokenStr() ?? "")")
            DispatchQueue.main.async {
                completion(resultToken, errors)
            }
        })
    }

    func testEndToEndFullBillingWithShippingWithMailCheckoutFlow() {
        let shopper = MockShopper(creditCardInfo: [(purchaseBillingData,purchaseCCData)], email: email, shippingContactInfo: purchaseShippingData, fullBillingRequired: true, emailRequired: true, shippingRequired: true)

        let tokenizeRequest = BSTokenizeRequest()
        tokenizeRequest.paymentDetails = BSTokenizeNewCCDetails(ccNumber: "4111 1111 1111 1111", cvv: "123", ccType: nil, expDate: "\(purchaseCCData["expirationMonth"]!)/\(purchaseCCData["expirationYear"]!)")
        tokenizeRequest.billingDetails = BSBillingAddressDetails(email: email, name: "\(purchaseBillingData["firstName"]!) \(purchaseBillingData["lastName"]!)", address: purchaseBillingData["address1"], city: purchaseBillingData["city"], zip: purchaseBillingData["zip"], country: purchaseBillingData["country"]?.uppercased(), state: purchaseBillingData["state"])
        tokenizeRequest.shippingDetails = BSShippingAddressDetails(phone: nil, name: "\(purchaseShippingData["firstName"]!) \(purchaseShippingData["lastName"]!)", address: purchaseShippingData["address1"], city: purchaseShippingData["city"], zip: purchaseShippingData["zip"], country: purchaseShippingData["country"]?.uppercased(), state: purchaseShippingData["state"])
        
        let semaphore = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in
            
            BlueSnapSDK.submitTokenizedDetails(tokenizeRequest: tokenizeRequest, completion: { (result, error) in
                XCTAssertNil(error, "error: \(String(describing: error))")
                
                BSIntegrationTestingAPIHelper.createTokenizedTransaction(
                    purchaseAmount: 22.0,
                    purchaseCurrency: "USD",
                    bsToken: token,
                    completion: { isSuccess, data, shopperId in
                        XCTAssert(isSuccess, "error: \(String(describing: "Transaction failed"))")
                        XCTAssertNotNil(data, "error: \(String(describing: "No data from transaction"))")
                        XCTAssertNotNil(shopperId, "error: \(String(describing: "No shopperId from transaction"))")
                        
                        BSIntegrationTestingAPIHelper.retrieveVaultedShopper(vaultedShopperId: shopperId!, completion: {
                            isSuccess, data in
                            XCTAssert(isSuccess, "error: \(String(describing: "Transaction failed"))")
                            let error = BluesnapSDKIntegrationTestsHelper.checkRetrieveVaultedShopperResponse(responseBody: data!, shopperInfo: shopper)

                            XCTAssertNil(error, "error: \(String(describing: error))")
              
                            semaphore.signal()
                        })
                })
            })
        })
        semaphore.wait()
        
    }
    
}


