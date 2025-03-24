//
//
// Copyright © 2020-2022 THALES. All rights reserved.
//

//
//  RemoveAuthenticator.swift
//  Advanced
//

import Foundation
import IdCloudClient

class RemoveAuthenticator : NSObject {
    typealias ProgressClosure = (IDCProgress) -> ()
    typealias CompletionClosure = (IDCError?) -> ()
    private var authenticator : Authenticator
    
    // Set up an instance variable of IDCIdCloudClient
    private let idcloudclient: IDCIdCloudClient!
    private var request: RemoveAuthenticatorRequest!
    
    init(authenticator: Authenticator) {
        self.authenticator = authenticator
        
        // Initialize an instance of IDCIdCloudClient.
        self.idcloudclient = try? IDCIdCloudClient(url: MS_URL, tenantId: TENANT_ID)
    }
    
    func execute(progress progressClosure: @escaping ProgressClosure, completion: @escaping CompletionClosure) {

        // Create an instance of the Remove authenticator request.
        // Instances of requests should be held as an instance variable to ensure that completion callbacks will function as expected and to prevent unexpected behaviour.
        request = idcloudclient.createRemoveAuthenticatorRequest(with: authenticator, progress: { (progress) in
            // Refer to IDCProgress for corresponding callbacks which provide an update to the existing request execution.
            progressClosure(progress)
        }, completion: {[weak self] (response, error) in
            self?.authenticator.wipe()
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
