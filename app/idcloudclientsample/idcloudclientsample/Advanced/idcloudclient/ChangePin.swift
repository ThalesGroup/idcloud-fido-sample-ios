//
//
// Copyright © 2020-2022 THALES. All rights reserved.
//

//
//  ChangePin.swift
//  Advanced
//

import Foundation
import IdCloudClient
import IdCloudClientUi

class ChangePin : NSObject {
    typealias ProgressClosure = (IDCProgress) -> ()
    typealias CompletionClosure = (IDCError?) -> ()
    weak var pinPadUiDelegate: SecurePinPadUiDelegate?
    
    // Set up an instance variable of IDCIdCloudClient
    private let idcloudclient: IDCIdCloudClient!
    private var request: ChangePinRequest!
    
    init(pinPadUiDelegate: SecurePinPadUiDelegate) {

        self.pinPadUiDelegate = pinPadUiDelegate
        
        // Initialize an instance of IDCIdCloudClient.
        self.idcloudclient = try? IDCIdCloudClient(url: MS_URL, tenantId: TENANT_ID)
    }
    
    func execute(progress progressClosure: @escaping ProgressClosure, completion: @escaping CompletionClosure) {

        // Create an instance of the Change pin request.
        // Instances of requests should be held as an instance variable to ensure that completion callbacks will function as expected and to prevent unexpected behaviour.
        request = idcloudclient.createChangePinRequest(with: pinPadUiDelegate!, progress: { (progress) in
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
