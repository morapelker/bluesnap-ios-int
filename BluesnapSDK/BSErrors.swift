//
//  BSErrors.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 07/06/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation


public enum BSSdkRequestBaseError: Error {
    case invalid(String)
    case missingPaymentMethod(String)
    case missingReturningShopper(String)
    case sdkNotInitialized(String)
    case tokenIsNil(String)
    case threeDSDisabledInDashboard(String)
}

public enum BSServiceError: Error {
    case illegalToken(String)
}

public enum BSErrors: Int {

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

    // cardinal
    case cardinalTokenParseError

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
