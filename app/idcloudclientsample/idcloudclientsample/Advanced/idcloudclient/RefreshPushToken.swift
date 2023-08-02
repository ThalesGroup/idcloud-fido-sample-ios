//
//
// Copyright © 2021-2022 THALES. All rights reserved.
//

//
//  RefreshPushToken.swift
//  Advanced
//
//

import UIKit
import IdCloudClient

class RefreshPushToken: NSObject {
    typealias ProgressClosure = (IDCProgress) -> ()
    typealias CompletionClosure = (NSError?) -> ()

    // Set up an instance variable of IDCIdCloudClient
    private let idcloudclient: IDCIdCloudClient!
    private var request: IDCRefreshPushTokenRequest!

    override init() {
        // Initialize an instance of IDCIdCloudClient.
        self.idcloudclient = try? IDCIdCloudClient(url: URL, tenantId: TENANT_ID)
    }

    func execute(devicePushToken: String, progress progressClosure: @escaping ProgressClosure, completion: @escaping (NSError?) -> ()) {
        // Create an instance of the RefreshPushToken request.
        // Instances of requests should be held as an instance variable to ensure that completion callbacks will function as expected and to prevent unexpected behaviour.
        request = idcloudclient.createRefreshPushTokenRequest(withDeviceToken: devicePushToken, progress: { (progress) in
            progressClosure(progress)
        }, completion: { (response, error) in
            // Callback to the UI.
            // These are executed on the Main thread.
            completion(error as NSError?)
        })
        
        // Execute the request.
        // Requests on IdCloud FIDO SDK are executed on the own unique threads.
        // Ensure that a scenario was previously invoked. Otherwise, an Error will be returned when no actionable events are present.
        request.execute()
    }
}
