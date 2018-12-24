//
//  BluesnapSDKIntegrationTestsHelper.swift
//  BluesnapSDKIntegrationTests
//
//  Created by Sivani on 11/12/2018.
//  Copyright © 2018 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
@testable import BluesnapSDK

class BluesnapSDKIntegrationTestsHelper {
    
    static func checkRetrieveVaultedShopperResponse(responseBody: Data, shopperInfo: MockShopper)-> BSErrors? {
        var resultError: BSErrors? = nil
        do {
            // Parse the result JSOn object
            if let jsonData = try JSONSerialization.jsonObject(with: responseBody, options: .allowFragments) as? [String: AnyObject] {
                if shopperInfo.shopperCheckoutRequirements.emailRequired {
                    checkApiCallResult(expectedData: ["email" : shopperInfo.email!] , resultData: jsonData)
                }

                if let paymentSources = jsonData["paymentSources"] as? [String: AnyObject] {
                    if let creditCardInfo = paymentSources["creditCardInfo"] as? [[String: Any]] {
                        for item in creditCardInfo{
                            if let creditCard = item["creditCard"] as? [String: AnyObject], let billingContactInfo = item["billingContactInfo"] as? [String: AnyObject] {
                                let cardLastFourDigits = creditCard["cardLastFourDigits"] as? String
                                checkApiCallResult(expectedData: shopperInfo.creditCardInfo[cardLastFourDigits!]!.billingContactInfo, resultData: billingContactInfo)
                                checkApiCallResult(expectedData: shopperInfo.creditCardInfo[cardLastFourDigits!]!.creditCard, resultData: creditCard)
                            }
                        }
                    }
                }
                
                if shopperInfo.shopperCheckoutRequirements.shippingRequired {
                    if let shippingContactInfo = jsonData["shippingContactInfo"] as? [String: AnyObject] {
                        checkApiCallResult(expectedData: shopperInfo.shippingContactInfo!, resultData: shippingContactInfo)
                        
                    }
                }
                
            } else {
                NSLog("Error parsing BS result on Retrieve vaulted shopper")
                resultError = .unknown
            }
        } catch let error as NSError {
            NSLog("Error parsing BS result on Retrieve vaulted shopper: \(error.localizedDescription)")
            resultError = .unknown
        }
        
        return resultError
        
    }
    
    
    static func checkApiCallResult(expectedData: [String:String], resultData: [String: AnyObject]){
        for (fieldName, fieldValue) in expectedData {
            let actualValue = resultData[fieldName] as! String
            checkFieldContent(expectedValue: fieldValue, actualValue: actualValue, fieldName: fieldName)
        }
    }
    
    static func checkFieldContent(expectedValue: String, actualValue: String, fieldName: String){
        XCTAssertTrue(expectedValue == actualValue, "Field \(fieldName) was not saved correctly in DataBase")
    }
    
}
