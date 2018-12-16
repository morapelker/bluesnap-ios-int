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
        let ccn = "4111 1111 1111 1111"
        let cvv = "111"
        let exp = "10/2020"
        let tokenizeRequest = BSTokenizeRequest()
        tokenizeRequest.paymentDetails = BSTokenizeNewCCDetails(ccNumber: ccn, cvv: cvv, ccType: nil, expDate: exp)
        
        let semaphore = DispatchSemaphore(value: 0)
        BluesnapSDKIntegrationTestsHelper.createToken(completion: { token, error in
            
            BlueSnapSDK.submitTokenizedDetails(tokenizeRequest: tokenizeRequest, completion: { (result, error) in
                XCTAssertNil(error, "error: \(String(describing: error))")
                let ccType = result[BSTokenizeBaseCCDetails.CARD_TYPE_KEY]
                let last4 = result[BSTokenizeBaseCCDetails.LAST_4_DIGITS_KEY]
                let country = result[BSTokenizeBaseCCDetails.ISSUING_COUNTRY_KEY]
                NSLog("Result: ccType=\(ccType!), last4Digits=\(last4!), ccIssuingCountry=\(country!)")
                
                BluesnapSDKIntegrationTestsHelper.createTokenizedTransaction(
                    purchaseAmount: 22.0,
                    purchaseCurrency: "USD",
                    bsToken: token,
                    completion: { success, data in
                        XCTAssert(success, "error: \(String(describing: "Transaction failed"))")
                        let (resultData, resultError) = BluesnapSDKIntegrationTestsHelper.parseTransactionResponse(responseBody: data)
                        XCTAssertNil(resultError, "Error parsing BS result on CC transaction submit")
                        BluesnapSDKIntegrationTestsHelper.checkTransactionResult(resultData: resultData)
                        semaphore.signal()
                })
            })
        })
        semaphore.wait()
        
    }

}


