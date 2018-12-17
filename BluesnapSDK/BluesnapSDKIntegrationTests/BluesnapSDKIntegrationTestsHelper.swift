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
    
    internal static let BLUESNAP_VERSION_HEADER = "BLUESNAP_VERSION_HEADER"
    internal static let BLUESNAP_VERSION_HEADER_VAL = "2.0"
    internal static let SDK_VERSION_HEADER = "BLUESNAP_ORIGIN_HEADER"
    internal static let SDK_VERSION_HEADER_VAL = "IOS SDK 0.2.0"
    //    internal static let BS_SANDBOX_DOMAIN = "https://us-qa-fct02.bluesnap.com/"
    
    
    static func createToken(shopperId: Int?, completion: @escaping (BSToken?, BSErrors?) -> Void) {
        createSandboxBSToken(shopperId: shopperId, user: BSApiManager.BS_SANDBOX_TEST_USER, password: BSApiManager.BS_SANDBOX_TEST_PASSWORD, completion: { bsToken, bsError in
            
            BSApiManager.setBsToken(bsToken: bsToken)
            XCTAssertNil(bsError)
            XCTAssertNotNil(bsToken)
            completion(bsToken, bsError)
        })
    }
    
    static func createToken(completion: @escaping (BSToken?, BSErrors?) -> Void) {
        createToken(shopperId: nil, completion: completion)
    }
    
    /**
     Get BlueSnap Token from BlueSnap server
     Normally you will not do this from the app.
     
     - parameters:
     - user: username
     - password: password
     - completion: callback function for after the token is created; recfeives optional token and optional error
     */
    static func createSandboxBSToken(shopperId: Int?, user: String, password: String, completion: @escaping (BSToken?, BSErrors?) -> Void) {
        
        let domain: String = BSApiManager.BS_SANDBOX_DOMAIN
        
        // create request
        let authorization = getBasicAuth(user: user, password: password)
        var urlStr = domain + "services/2/payment-fields-tokens"
        if let shopperId = shopperId {
            urlStr = urlStr + "?shopperId=\(shopperId)"
        }
        let url = NSURL(string: urlStr)!
        var request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        //request.timeoutInterval = 60
        request.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        request.setValue("0", forHTTPHeaderField: "Content-Length")
        request.setValue(BLUESNAP_VERSION_HEADER_VAL, forHTTPHeaderField: BLUESNAP_VERSION_HEADER)
        request.setValue(SDK_VERSION_HEADER_VAL, forHTTPHeaderField: SDK_VERSION_HEADER)
        
        // fire request
        
        var result: BSToken?
        var resultError: BSErrors?
        NSLog("BlueSnap; createSandboxBSToken")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            NSLog("BlueSnap; createSandboxBSToken completion")
            if let error = error {
                let errorType = type(of: error)
                NSLog("error getting BSToken - \(errorType). Error: \(error.localizedDescription)")
                resultError = .unknown
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode: Int = (httpResponse?.statusCode) {
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        result = extractTokenFromResponse(httpResponse: httpResponse)
                        if let result = result {
                            NSLog("createSandboxBSToken result")
                        } else {
                            resultError = .unknown
                        }
                    } else if (httpStatusCode >= 400 && httpStatusCode <= 499) {
                        NSLog("Http error getting BSToken; http status = \(httpStatusCode)")
                        resultError = .invalidInput
                    } else {
                        resultError = .unknown
                        NSLog("Http error getting BSToken; http status = \(httpStatusCode)")
                    }
                } else {
                    resultError = .unknown
                    NSLog("Http error getting response for BSToken")
                }
            }
            defer {
                completion(result, resultError)
            }
        }
        task.resume()
    }
    
    
    private static func extractTokenFromResponse(httpResponse: HTTPURLResponse?) -> BSToken? {
        
        var result: BSToken?
        if let location: String = httpResponse?.allHeaderFields["Location"] as? String {
            if let lastIndexOfSlash = location.range(of: "/", options: String.CompareOptions.backwards, range: nil, locale: nil) {
                let tokenStr = String(location[lastIndexOfSlash.upperBound..<location.endIndex])
                result = BSToken(tokenStr: tokenStr)
            } else {
                NSLog("Error: BS Token does not contain /")
            }
        } else {
            NSLog("Error: BS Token does not appear in response headers")
        }
        return result
    }
    
    static func createTokenizedTransaction(
        purchaseAmount: Double,
        purchaseCurrency: String,
        bsToken: BSToken!,
        completion: @escaping (_ success: Bool, _ data: Data?)->Void) {
        
        var requestBody = [
            "amount": "\(purchaseAmount)",
            "recurringTransaction": "ECOMMERCE",
            "softDescriptor": "MobileSDKtest",
            "currency": "\(purchaseCurrency)",
            "cardTransactionType": "AUTH_CAPTURE",
            "pfToken": "\(bsToken.getTokenStr()!)",
            ] as [String : Any]
        print("requestBody= \(requestBody)")
        let authorization = getBasicAuth()
        
        let urlStr = bsToken.getServerUrl() + "services/2/transactions";
        let url = NSURL(string: urlStr)!
        var request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
        } catch let error {
            NSLog("Error serializing CC details: \(error.localizedDescription)")
        }
        
        // fire request
        
        var result : (success:Bool, data: Data?) = (success:false, data: nil)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                NSLog("error calling create transaction: \(error.localizedDescription)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode:Int = (httpResponse?.statusCode) {
                    
                    if let data = data {
                        result.data = data
                        NSLog("Response body = \(result.data!)")
                    }
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        result.success = true
                    } else {
                        NSLog("Http error Creating BS Transaction; HTTP status = \(httpStatusCode)")
                    }
                }
            }
            defer {
                    completion(result.success, result.data)
                
            }
        }
        task.resume()
    }
    
    /**
     Build the basic authentication header from username/password
     - parameters:
     - user: username
     - password: password
     */
    private static func getBasicAuth(user: String!, password: String!) -> String {
        let loginStr = String(format: "%@:%@", user, password)
        let loginData = loginStr.data(using: String.Encoding.utf8)!
        let base64LoginStr = loginData.base64EncodedString()
        return "Basic \(base64LoginStr)"
    }
    
    /**
     Build the basic authentication header from username/password
     */
    private static func getBasicAuth() -> String {
        return getBasicAuth(user: BSApiManager.BS_SANDBOX_TEST_USER, password: BSApiManager.BS_SANDBOX_TEST_PASSWORD)
    }
    
    static func parseTransactionResponse(responseBody: Data?)->([String:String], BSErrors?){
        var resultData: [String:String] = [:]
        var resultError: BSErrors? = nil
        if let data = responseBody {
            if !data.isEmpty {
                do {
                    // Parse the result JSOn object
                    if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
                        resultData["vaultedShopperId"] = json["vaultedShopperId"] as? String

                        if let cardHolderInfo = json["cardHolderInfo"] as? [String: AnyObject] {
                            resultData["firstName"] = cardHolderInfo["firstName"] as? String
                            resultData["lastName"] = cardHolderInfo["lastName"] as? String
                            resultData["email"] = cardHolderInfo["email"] as? String
                            resultData["country"] = cardHolderInfo["country"] as? String
                            resultData["state"] = cardHolderInfo["state"] as? String
                            resultData["address"] = cardHolderInfo["address"] as? String
                            resultData["city"] = cardHolderInfo["city"] as? String
                            resultData["zip"] = cardHolderInfo["zip"] as? String
            
                        }
                        
                        if let creditCardInfo = json["creditCard"] as? [String: AnyObject] {
                            resultData["cardLastFourDigits"] = creditCardInfo["cardLastFourDigits"] as? String
                            resultData["cardType"] = creditCardInfo["cardType"] as? String
//                            resultData["cardSubType"] = creditCardInfo["cardSubType"] as? String
                        }
                        
                        
                        
                    } else {
                        NSLog("Error parsing BS result on CC transaction submit")
                        resultError = .unknown
                    }
                } catch let error as NSError {
                    NSLog("Error parsing BS result on CC transaction submit: \(error.localizedDescription)")
                    resultError = .unknown
                }
            }
        } else {
            NSLog("Error: no data exists")
            resultError = .unknown
            
        }
        return (resultData, resultError)
        
        
    }
    
    
    static func checkTransactionResult(expectedData: [String:String], resultData: [String:String]){
        for (fieldName, fieldValue) in resultData {
            checkFieldContent(expectedValue: expectedData[fieldName]!, actualValue: fieldValue, fieldName: fieldName)
        }

    }
    
    static func checkFieldContent(expectedValue: String, actualValue: String, fieldName: String){
        XCTAssertTrue(expectedValue == actualValue, "Field \(fieldName) was not saved correctly in DataBase")
    }
    
}
