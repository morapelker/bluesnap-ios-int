//
//  TestingAPIHelper.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 17/12/2018.
//  Copyright © 2018 Bluesnap. All rights reserved.
//

import Foundation

import Foundation
import PassKit
import BluesnapSDK

class DemoAPIHelper {
    //temporary
    static var bsAPIUser: String {
        return (Bundle(for: DemoAPIHelper.self).object(forInfoDictionaryKey: "BsAPIUser") as? String) ?? "USER_UNDEFINED"
    }
    
    static var bsAPIPassword: String {
        return (Bundle(for: DemoAPIHelper.self).object(forInfoDictionaryKey: "BsAPIPassword") as? String) ?? "PASSWORD_UNDEFINED"
    }
    
    internal static let BS_SANDBOX_DOMAIN = "https://sandbox.bluesnap.com/"
    internal static let BS_SANDBOX_TEST_USER = bsAPIUser
    internal static let BS_SANDBOX_TEST_PASSWORD = bsAPIPassword
    
    static func createToken(shopperId: Int?, completion: @escaping (BSToken?, BSErrors?) -> Void) {
        createSandboxBSToken(shopperId: shopperId, completion: { bsToken, bsError in
            BlueSnapSDK.setBsToken(bsToken: bsToken)
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
    static func createSandboxBSToken(shopperId: Int?, completion: @escaping (BSToken?, BSErrors?) -> Void) {

        let domain: String = DemoAPIHelper.BS_SANDBOX_DOMAIN

        // create request
        var urlStr = domain + "services/2/payment-fields-tokens"
        if let shopperId = shopperId {
            urlStr = urlStr + "?shopperId=\(shopperId)"
        }
        let url = NSURL(string: urlStr)!
        var request = getURLRequest(urlStr: urlStr, httpMethod: "POST", contentType: "text/xml")

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
                        result = self.extractTokenFromResponse(httpResponse: httpResponse)
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


    static private func extractTokenFromResponse(httpResponse: HTTPURLResponse?) -> BSToken? {

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

    /**
     Here all the data is on the token, we only need to send amount and currency
     */
    static func createTokenizedTransaction(
        purchaseDetails: BSBaseSdkResult!,
        bsToken: BSToken!,
        completion: @escaping (_ isSuccess: Bool, _ data: String?, _ shopperId: String?)->Void) {
        
        var responseData: Data!
        var requestBody = [
            "amount": "\(purchaseDetails.getAmount()!)",
            "recurringTransaction": "ECOMMERCE",
            "softDescriptor": "MobileSDKtest",
            "currency": "\(purchaseDetails.getCurrency()!)",
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
        
        var result : (isSuccess:Bool, data: String?, shopperId: String?) = (isSuccess:false, data: nil, shopperId: nil)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                NSLog("error calling create transaction: \(error.localizedDescription)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode:Int = (httpResponse?.statusCode) {
                    
                    if let data = data {
                        responseData = data
                        result.data = String(data: data, encoding: .utf8)
                        NSLog("Response body = \(result.data ?? "")")
                    }
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: AnyObject] {
                                //Extract shopper ID from transaction API response
                                result.shopperId = String(json["vaultedShopperId"] as! Int)
                                result.isSuccess = true
                            }
                        } catch let error as NSError {
                            NSLog("Error parsing BS result on Retrieve vaulted shopper: \(error.localizedDescription)")
                        }
                        
                    } else {
                        NSLog("Http error Creating BS Transaction; HTTP status = \(httpStatusCode)")
                    }
                }
            }
            defer {
                DispatchQueue.main.async {
                    completion(result.isSuccess, result.data, result.shopperId)
                }
            }
        }
        task.resume()
    }
    
    /**
     Get shopper information from BlueSnap server by a shopper Id
     Normally you will not do this from the app.

     - parameters:
     - shopperId: shopper Id
     - completion: callback function for after the call returns; receives optional token and optional error
     */
    static func retrieveVaultedShopper(
        vaultedShopperId shopperId: String,
        completion: @escaping (_ isSuccess: Bool, _ data: Data?)->Void) {

        print("shopperId= \(shopperId)")
        let authorization = getBasicAuth()

        let urlStr = DemoAPIHelper.BS_SANDBOX_DOMAIN + "services/2/vaulted-shoppers/" + shopperId;
        let url = NSURL(string: urlStr)!

        var request = getURLRequest(urlStr: urlStr, httpMethod: "GET", contentType: "application/json")

        var result : (isSuccess:Bool, data: Data?) = (isSuccess:false, data: nil)

        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                NSLog("error in calling retrieve vaulted shopper: \(error.localizedDescription)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode:Int = (httpResponse?.statusCode) {

                    if let data = data {
                        result.data = data
                        let StringData = String(data: data, encoding: .utf8)
                        NSLog("Response body = \(StringData ?? "")")
                    }
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        result.isSuccess = true
                    } else {
                        NSLog("Http error Creating BS Transaction; HTTP status = \(httpStatusCode)")
                    }
                }
            }
            defer {
                completion(result.isSuccess, result.data)
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
    static private func getBasicAuth(user: String!, password: String!) -> String {
        let loginStr = String(format: "%@:%@", user, password)
        let loginData = loginStr.data(using: String.Encoding.utf8)!
        let base64LoginStr = loginData.base64EncodedString()
        return "Basic \(base64LoginStr)"
    }

    /**
     Build the basic authentication header from username/password
     */
    static private func getBasicAuth() -> String {
        return getBasicAuth(user: DemoAPIHelper.BS_SANDBOX_TEST_USER, password: DemoAPIHelper.BS_SANDBOX_TEST_PASSWORD)
    }

    /**
     Build a basic URL Request
     - parameters:
     - urlStr: url
     - httpMethod: operationt type to request
     - ContentType: content type of the request
     */
    static private func getURLRequest(urlStr: String, httpMethod: String, contentType: String, requestBody: Any? = nil) -> NSMutableURLRequest {
        let authorization = getBasicAuth()
        let url = NSURL(string: urlStr)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = httpMethod
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        //request.setValue("0", forHTTPHeaderField: "Content-Length")
        if let requestBody = requestBody {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
            } catch let error {
                NSLog("Error serializing request body: \(error.localizedDescription)")
            }
        }
        return request

    }

    public enum MockBSErrors : Int {

        // CC
        case invalidCcNumber
        case invalidCvv
        case invalidExpDate

        // ApplePay
        case cantMakePaymentError
        case applePayOperationError
        case applePayCanceled

        // PayPal
        case paypalUnsupportedCurrency
        case paypalUTokenAlreadyUsed

        // generic
        case invalidInput
        case expiredToken
        case cardTypeNotSupported
        case tokenNotFound
        case tokenAlreadyUsed
        case unAuthorised
        case unknown

        public func description() -> String {
            switch self {

            case .invalidCcNumber:
                return "invalidCcNumber";
            case .invalidCvv:
                return "invalidCvv";
            case .invalidExpDate:
                return "invalidExpDate";

            case .cantMakePaymentError:
                return "cantMakePaymentError";
            case .applePayOperationError:
                return "applePayOperationError";
            case .applePayCanceled:
                return "applePayCanceled";

            case .paypalUnsupportedCurrency:
                return "paypalUnsupportedCurrency";

            case .invalidInput:
                return "invalidInput";
            case .expiredToken:
                return "expiredToken";
            case .cardTypeNotSupported:
                return "cardTypeNotSupported";
            case .tokenNotFound:
                return "tokenNotFound";
            case .tokenAlreadyUsed:
                return "tokenAlreadyUsed";
            case .unAuthorised:
                return "unAuthorised";

            default:
                return "unknown";
            }
        }

    }


}
