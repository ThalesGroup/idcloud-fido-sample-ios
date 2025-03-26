//
//
// Copyright © 2021-2022 THALES. All rights reserved.
//

//
//  Authenticate.swift
//  idcloudclientsample
//

import Foundation
import IdCloudClient

class Authenticate : NSObject {
    typealias ProgressClosure = (IDCProgress) -> ()
    typealias CompletionClosure = (IDCError?) -> ()

    private let uiDelegates: CommonUiDelegate & BiometricUiDelegate & SecurePinPadUiDelegate
    
    // Set up an instance variable of IDCIdCloudClient
    private var idcloudclient: IDCIdCloudClient!
    private var request: FetchRequest!

    init(uiDelegates: CommonUiDelegate & BiometricUiDelegate & SecurePinPadUiDelegate) {
        self.uiDelegates = uiDelegates
        // Initialize an instance of IDCIdCloudClient.
        self.idcloudclient = try? IDCIdCloudClient(url: MS_URL, tenantId: TENANT_ID)
    }
    
    func execute(progress progressClosure: @escaping ProgressClosure, completion: @escaping CompletionClosure) {
        
        // Set up an instance of IDCUiDelegates, an encapsulated class containing all necessary UI delegates required by IdCloud FIDO SDK.
        // Ensure that you conform to these corresponding delegates.
        // Required callbacks are essential to ensure a proper UX behaviour.
        // As a means of convenience, the IdCloud FIDO UI SDK provides a ClientConformer class which conforms to all necessary delegates of IdCloud FIDO SDK
        var idcUiDelegates = UiDelegates()
        idcUiDelegates.commonUiDelegate = uiDelegates
        idcUiDelegates.biometricUiDelegate = uiDelegates
        idcUiDelegates.securePinPadUiDelegate = uiDelegates
        
        // Create an instance of the Fetch request.
        // Instances of requests should be held as an instance variable to ensure that completion callbacks will function as expected and to prevent unexpected behaviour.
        request = idcloudclient.createFetchRequest(with: idcUiDelegates, progress: { (progress) in
            // Refer to IDCProgress for corresponding callbacks which provide an update to the existing request execution.
            progressClosure(progress)
        }, completion: { (response, error) in
            // Callback to the UI.
            // These are executed on the Main thread.
            completion(error)
        })
        
        // Execute the request.
        // Requests on IdCloud FIDO SDK are executed on the own unique threads.
        // Ensure that an Authentication scenario was previously invoked. Otherwise, an Error will be returned when no actionable events are present.
        request.execute()
    }

}
