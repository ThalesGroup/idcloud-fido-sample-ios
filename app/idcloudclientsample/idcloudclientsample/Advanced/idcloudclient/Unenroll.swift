//
//
// Copyright © 2020-2022 THALES. All rights reserved.
//

//
//  Unenroll.swift
//  Advanced
//

import Foundation
import IdCloudClient

class Unenroll : NSObject {
    typealias ProgressClosure = (IDCProgress) -> ()
    typealias CompletionClosure = (IDCError?) -> ()

    // Set up an instance variable of IDCIdCloudClient
    private let idcloudclient: IDCIdCloudClient!
    private var request: UnenrollRequest!

    override init() {
        // Initialize an instance of IDCIdCloudClient.
        self.idcloudclient = try? IDCIdCloudClient(url: MS_URL, tenantId: TENANT_ID)
    }
    
    func execute(progress progressClosure: @escaping ProgressClosure, completion: @escaping CompletionClosure) {
        // Create an instance of the Unenroll request.
        // Instances of requests should be held as an instance variable to ensure that completion callbacks will function as expected and to prevent unexpected behaviour.
        request = idcloudclient.createUnenrollRequest(progress: { (progress) in
            // Refer to IDCProgress for corresponding callbacks which provide an update to the existing request execution.
            progressClosure(progress)
        }, completion: { (response, error) in
            // Callback to the UI.
            // These are executed on the Main thread.
            // As a resutl of the unenroll request, the user is returned to an initial (default) state.
            // The user would that need to re-enroll in order to properly utilize the IdCloud FIDO SDK.
            completion(error)
        })
        
        // Execute the request.
        // Requests on IdCloud FIDO SDK are executed on the own unique threads.
        request.execute()
    }
}
