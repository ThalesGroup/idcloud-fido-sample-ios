//
//
// Copyright © 2020-2022 THALES. All rights reserved.
//

//
//  AddAuthenticator.swift
//  Advanced
//

import Foundation
import IdCloudClient

class AddAuthenticator : NSObject {
    typealias ProgressClosure = (IDCProgress) -> ()
    typealias CompletionClosure = (NSError?) -> ()
    private let uiDelegates: IDCCommonUiDelegate & IDCBiometricUiDelegate & IDCSecurePinPadUiDelegate
    
    // Set up an instance variable of IDCIdCloudClient
    private let idcloudclient: IDCIdCloudClient!
    private var request: IDCAddAuthenticatorRequest!
    
    init(uiDelegates: IDCCommonUiDelegate & IDCBiometricUiDelegate & IDCSecurePinPadUiDelegate) {
        self.uiDelegates = uiDelegates
        
        // Initialize an instance of IDCIdCloudClient.
        self.idcloudclient = try? IDCIdCloudClient(url: URL, tenantId: TENANT_ID)
    }
    
    func execute(progress progressClosure: @escaping ProgressClosure, completion: @escaping CompletionClosure) {
        // Set up an instance of IDCUiDelegates, an encapsulated class containing all necessary UI delegates required by IdCloud FIDO SDK.
        // Ensure that you conform to these corresponding delegates.
        // Required callbacks are essential to ensure a proper UX behaviour.
        // As a means of convenience, the IdCloud FIDO UI SDK provides a ClientConformer class which conforms to all necessary delegates of IdCloud FIDO SDK
        let idcUiDelegates = IDCUiDelegates()
        idcUiDelegates.commonUiDelegate = uiDelegates
        idcUiDelegates.biometricUiDelegate = uiDelegates
        idcUiDelegates.securePinPadUiDelegate = uiDelegates
        
        // Create an instance of the Add authenticator request.
        // Instances of requests should be held as an instance variable to ensure that completion callbacks will function as expected and to prevent unexpected behaviour.
        request = idcloudclient.createAddAuthenticatorRequest(with: idcUiDelegates, progress: { (progress) in
            // Refer to IDCProgress for corresponding callbacks which provide an update to the existing request execution.
            progressClosure(progress)
        }, completion: { (response, error) in
            // Callback to the UI.
            // These are executed on the Main thread.
            completion(error as NSError?)
        })
        
        // Execute the request.
        // Requests on IdCloud FIDO SDK are executed on the own unique threads.
        // Ensure that an Authentication scenario was previously invoked. Otherwise, an Error will be returned when no actionable events are present.
        request.execute()
    }
}
