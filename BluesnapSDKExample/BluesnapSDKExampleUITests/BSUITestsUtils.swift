//
//  BSUITestsUtils.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 06/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
import BluesnapSDK

class BSUITestUtils {
    
    static func checkRetrieveVaultedShopperResponse(responseBody: Data, sdkRequest: BSSdkRequest, expectedCreditCardInfo: (String,String,String,String), shippingSameAsBilling: Bool = false) -> BSErrors? {
        var resultError: BSErrors? = nil
        do {
            // Parse the result JSOn object
            if let jsonData = try JSONSerialization.jsonObject(with: responseBody, options: .allowFragments) as? [String: AnyObject] {
                if sdkRequest.shopperConfiguration.withEmail {
                    checkFieldContent(expectedValue: (sdkRequest.shopperConfiguration.billingDetails?.email!)!, actualValue: jsonData["email"] as! String, fieldName: "email")
                }
                
                if let paymentSources = jsonData["paymentSources"] as? [String: AnyObject] {
                    if let creditCardInfo = paymentSources["creditCardInfo"] as? [[String: Any]] {
                        for item in creditCardInfo {
                            if let creditCard = item["creditCard"] as? [String: AnyObject], let billingContactInfo = item["billingContactInfo"] as? [String: AnyObject] {
                                //TODO: integrate this for multiple cc
//                                let cardLastFourDigits = creditCard["cardLastFourDigits"] as? String
                                checkShopperInfo(sdkRequest: sdkRequest, resultData: billingContactInfo, isBilling: true)
                                checkCreditCardInfo(expectedCreditCardInfo: expectedCreditCardInfo, resultData: creditCard)
                            }
                        }
                    }
                }
                
                if sdkRequest.shopperConfiguration.withShipping {
                    if let shippingContactInfo = jsonData["shippingContactInfo"] as? [String: AnyObject] {
                        checkShopperInfo(sdkRequest: sdkRequest, resultData: shippingContactInfo, isBilling: shippingSameAsBilling)
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
    
    static func checkCreditCardInfo(expectedCreditCardInfo: (String,String,String,String), resultData: [String: AnyObject]) {
        checkFieldContent(expectedValue: expectedCreditCardInfo.0 , actualValue: resultData["cardLastFourDigits"] as! String, fieldName: "cardLastFourDigits")
        checkFieldContent(expectedValue: expectedCreditCardInfo.1, actualValue: resultData["cardType"] as! String, fieldName: "cardType")
        checkFieldContent(expectedValue: expectedCreditCardInfo.2, actualValue: resultData["expirationMonth"] as! String, fieldName: "expirationMonth")
        checkFieldContent(expectedValue: expectedCreditCardInfo.3, actualValue: resultData["expirationYear"] as! String, fieldName: "expirationYear")
    }
    
    static func checkShopperInfo(sdkRequest: BSSdkRequest, resultData: [String: AnyObject], isBilling: Bool) {
//        let address = "address1"
        let fullInfo = (isBilling && sdkRequest.shopperConfiguration.fullBilling) || !isBilling
        let shopperInfo = isBilling ? sdkRequest.shopperConfiguration.billingDetails! : sdkRequest.shopperConfiguration.shippingDetails!
        let country = shopperInfo.country!
        
        let (firstName, lastName) = shopperInfo.getSplitName()!
        checkFieldContent(expectedValue: firstName, actualValue: resultData["firstName"] as! String, fieldName: "firstName")
        checkFieldContent(expectedValue: lastName, actualValue: resultData["lastName"] as! String, fieldName: "lastName")
        checkFieldContent(expectedValue: country.lowercased(), actualValue: resultData["country"] as! String, fieldName: "country")
        
        if (checkCountryHasZip(country: country)){
            checkFieldContent(expectedValue: shopperInfo.zip!, actualValue: resultData["zip"] as! String, fieldName: "zip")
        }
        
        if (fullInfo){ //full billing or shipping
            if (checkCountryHasState(country: country)){
                checkFieldContent(expectedValue: shopperInfo.state!, actualValue: resultData["state"] as! String, fieldName: "state")
            }
            checkFieldContent(expectedValue: shopperInfo.city!, actualValue: resultData["city"] as! String, fieldName: "city")
            checkFieldContent(expectedValue: shopperInfo.address!, actualValue: resultData["address1"] as! String, fieldName: "address")
        }
        
    }
    
    static func checkFieldContent(expectedValue: String, actualValue: String, fieldName: String) {
        XCTAssertEqual(expectedValue, actualValue, "Field \(fieldName) was not saved correctly in DataBase")
    }
    
    static func checkCountryHasState(country: String) -> Bool {
        var countryHasState = false
        
        if country == "US" || country == "CA" || country == "BR" {
            countryHasState =  true
        }
        
        return countryHasState
    }
    
    static func checkCountryHasZip(country: String) -> Bool {
        let countryHasZip = !BSCountryManager.getInstance().countryHasNoZip(countryCode: country)
        return countryHasZip
    }
    
}
