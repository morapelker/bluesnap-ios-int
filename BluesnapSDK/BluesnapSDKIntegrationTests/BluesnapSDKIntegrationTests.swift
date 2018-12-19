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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let semaphore = DispatchSemaphore(value: 0)
        BlueSnapSDK.createSandboxTestToken(completion: { token, error in
            
            XCTAssertNotNil(token, "Failed to get token")
            NSLog("Token: \(token?.getTokenStr() ?? "")")
            
            BlueSnapSDK.initBluesnap(bsToken: token, generateTokenFunc: self.generateAndSetBsToken, initKount: false, fraudSessionId: nil, applePayMerchantIdentifier: nil, merchantStoreCurrency: nil, completion: { error in
                
                let bsCurrencies = BlueSnapSDK.getCurrencyRates()
                XCTAssertNotNil(bsCurrencies, "Failed to get currencies")
                
                let gbpCurrency : BSCurrency! = bsCurrencies?.getCurrencyByCode(code: "GBP")
                XCTAssertNotNil(gbpCurrency)
                NSLog("testGetTokenAndCurrencies; GBP currency name is: \(String(describing: gbpCurrency.getName())), its rate is \(String(describing: gbpCurrency.getRate()))")
                
                let eurCurrencyRate : Double! = bsCurrencies?.getCurrencyRateByCurrencyCode(code: "EUR")
                XCTAssertNotNil(eurCurrencyRate)
                NSLog("testGetTokeString(describing: nAndCurrencies;) EUR currency rate is: \(String(describing: eurCurrencyRate))")
                
                semaphore.signal()
            })
            
        })
        
        semaphore.wait()
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
    
    func testEndToEndCheckoutFlow() {
        let purchaseCCData = ["ccn": "4111 1111 1111 1111", "cardLastFourDigits": "1111", "cvv": "123", "expirationMonth": "10","expirationYear": "2020", "cardType": "VISA"]
        
        let purchaseBillingData = ["email": "test@sdk.com", "firstName": "La", "lastName": "Fleur", "address": "555 Broadway street",
                            "city": "New York", "zip": "3abc 324a", "country": "us", "state": "NY"]
        
        let purchaseShippingData = ["email": "test@sdk.com", "firstName": "Taylor", "lastName": "Love", "address": "AddressTest",
                                   "city": "CityTest", "zip": "12345", "country": "br", "state": "RJ"]
        
        let tokenizeRequest = BSTokenizeRequest()
        tokenizeRequest.paymentDetails = BSTokenizeNewCCDetails(ccNumber: purchaseCCData["ccn"], cvv: purchaseCCData["cvv"], ccType: nil, expDate: "\(purchaseCCData["expirationMonth"]!)/\(purchaseCCData["expirationYear"]!)")
        tokenizeRequest.billingDetails = BSBillingAddressDetails(email: purchaseBillingData["email"], name: "\(purchaseBillingData["firstName"]!) \(purchaseBillingData["lastName"]!)", address: purchaseBillingData["address"], city: purchaseBillingData["city"], zip: purchaseBillingData["zip"], country: purchaseBillingData["country"]?.uppercased(), state: purchaseBillingData["state"])
        tokenizeRequest.shippingDetails = BSShippingAddressDetails(phone: nil, name: "\(purchaseShippingData["firstName"]!) \(purchaseShippingData["lastName"]!)", address: purchaseShippingData["address"], city: purchaseShippingData["city"], zip: purchaseShippingData["zip"], country: purchaseShippingData["country"]?.uppercased(), state: purchaseShippingData["state"])
        
        let semaphore = DispatchSemaphore(value: 0)
        BluesnapSDKIntegrationTestsHelper.createToken(completion: { token, error in
            
            BlueSnapSDK.submitTokenizedDetails(tokenizeRequest: tokenizeRequest, completion: { (result, error) in
                XCTAssertNil(error, "error: \(String(describing: error))")
                
                BluesnapSDKIntegrationTestsHelper.createTokenizedTransaction(
                    purchaseAmount: 22.0,
                    purchaseCurrency: "USD",
                    bsToken: token,
                    completion: { isSuccess, data, shopperId in
                        XCTAssert(isSuccess, "error: \(String(describing: "Transaction failed"))")
                        XCTAssertNotNil(data, "error: \(String(describing: "No data from transaction"))")
                        XCTAssertNotNil(shopperId, "error: \(String(describing: "No shopperId from transaction"))")
                        
                        BluesnapSDKIntegrationTestsHelper.retrieveVaultedShopper(vaultedShopperId: shopperId!, completion: {
                            isSuccess, data in
                            XCTAssert(isSuccess, "error: \(String(describing: "Transaction failed"))")
                            let (ccData, billingData, shippingData, error) = BluesnapSDKIntegrationTestsHelper.parseRetrieveVaultedShopperResponse(responseBody: data, fullBillingRequired: true, emailRequired: true, shippingRequired: true)
                            XCTAssertNil(error, "error: \(String(describing: error))")
                            
                            BluesnapSDKIntegrationTestsHelper.checkApiCallResult(expectedData: purchaseBillingData, resultData: billingData)
                            BluesnapSDKIntegrationTestsHelper.checkApiCallResult(expectedData: purchaseCCData, resultData: ccData)
                            BluesnapSDKIntegrationTestsHelper.checkApiCallResult(expectedData: purchaseShippingData, resultData: shippingData)
                            
                            semaphore.signal()
                        })
                })
            })
        })
        semaphore.wait()
        
    }

}


