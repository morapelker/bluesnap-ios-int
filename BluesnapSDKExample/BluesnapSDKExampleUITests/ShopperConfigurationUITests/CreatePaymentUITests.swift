//
//  CreatePaymentUITests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 26/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation
import XCTest

class CreatePaymentUITests: ChoosePaymentMethodUITests {

    internal func setUpForCreatePaymentSdk(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool, tapExistingCc: Bool = false, checkExistingCcLine: Bool = false) {
        
        setUpForChoosePaymentMethodSdk(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: checkoutFullBilling, checkoutWithEmail: checkoutWithEmail, checkoutWithShipping: checkoutWithShipping, tapExistingCc: tapExistingCc, checkExistingCcLine: checkExistingCcLine)
        
        if (!tapExistingCc){
            newCardBasicFillInInfoAndPay()
        }
        
        else{
            existingCardBasicFillInInfoAndPay(checkoutWithShipping: checkoutWithShipping)
        }
        
        checkResult(expectedSuccessText: "Success!")
        
        app.buttons["TryAgainButton"].tap()
    }
    
    /* -------------------------------- Create Payment Common tests ---------------------------------------- */
    
    
    func createCreditCardPaymentMethodFlow(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool, tapExistingCc: Bool = false, checkExistingCcLine: Bool = false) {
        setUpForCreatePaymentSdk(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: checkoutFullBilling, checkoutWithEmail: checkoutWithEmail, checkoutWithShipping: checkoutWithShipping, tapExistingCc: tapExistingCc, checkExistingCcLine: checkExistingCcLine)
        
        setPurchaseAmount()
        
        app.buttons["CreateButton"].tap()
        
        checkResult(expectedSuccessText: "Success!")
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DemoAPIHelper.retrieveVaultedShopper(vaultedShopperId: vaultedShopperId, completion: {
            isSuccess, data in
            XCTAssert(isSuccess, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")
            
            let error = BSUITestUtils.checkRetrieveVaultedShopperResponse(responseBody: data!, sdkRequest: self.sdkRequest, cardStored: true, expectedCreditCardInfo: [(BSUITestUtils.getValidVisaLast4Digits(), "VISA", BSUITestUtils.getValidExpMonth(),BSUITestUtils.getValidExpYear())], chosenPaymentMethod: "CC", cardIndex: 0)
            
            XCTAssertNil(error, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")
            
            semaphore.signal()
        })
        
        semaphore.wait()
        
    }
    
    /* -------------------------------- Create Payment tests ---------------------------------------- */
    
    func testFlowCreateNewCCPaymentMinimalBilling(){
        createCreditCardPaymentMethodFlow(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: false, tapExistingCc: false, checkExistingCcLine: false)
    }
    
    func testFlowCreateNewCCPaymentFullBillingWithShippingWithEmail(){
        createCreditCardPaymentMethodFlow(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true)
    }
    
    func testFlowCreateExistingCCPaymentMinimalBilling(){
        createCreditCardPaymentMethodFlow(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: false, tapExistingCc: true, checkExistingCcLine: true)
    }
    
    func testFlowCreateExistingCCPaymentFullBillingWithShippingWithEmail(){
        createCreditCardPaymentMethodFlow(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true, tapExistingCc: true, checkExistingCcLine: true)
    }
    
}
