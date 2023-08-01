//
//
// Copyright © 2021-2022 THALES. All rights reserved.
//

//
//  ProcessNotification.swift
//  Advanced
//
//

import UIKit
import IdCloudClient

class ProcessNotification: NSObject {
    typealias ProgressClosure = (IDCProgress) -> ()
    typealias CompletionClosure = (NSError?) -> ()

    private let uiDelegates: IDCCommonUiDelegate & IDCBiometricUiDelegate & IDCSecurePinPadUiDelegate

    // Set up an instance variable of IDCIdCloudClient
    private let idcloudclient: IDCIdCloudClient!
    private var request: IDCProcessNotificationRequest!

    init(uiDelegates: IDCCommonUiDelegate & IDCBiometricUiDelegate & IDCSecurePinPadUiDelegate) {
        self.uiDelegates = uiDelegates
        
        // Initialize an instance of IDCIdCloudClient.
        self.idcloudclient = try? IDCIdCloudClient(url: URL, tenantId: TENANT_ID)
    }

    func execute(notification: [AnyHashable : Any], progress progressClosure: @escaping ProgressClosure, completion: @escaping (NSError?) -> ()) {
        // Set up an instance of IDCUiDelegates, an encapsulated class containing all necessary UI delegates required by IdCloud FIDO SDK.
        // Ensure that you conform to these corresponding delegates.
        // Required callbacks are essential to ensure a proper UX behaviour.
        // As a means of convenience, the IdCloud FIDO UI SDK provides a ClientConformer class which conforms to all necessary delegates of IdCloud FIDO SDK
        let idcUiDelegates = IDCUiDelegates()
        idcUiDelegates.commonUiDelegate = uiDelegates
        idcUiDelegates.biometricUiDelegate = uiDelegates
        idcUiDelegates.securePinPadUiDelegate = uiDelegates
        
        // Create an instance of the ProcessNotification request.
        // Instances of requests should be held as an instance variable to ensure that completion callbacks will function as expected and to prevent unexpected behaviour.
        request = idcloudclient.createProcessNotificationRequest(withNotification: notification, uiDelegates: idcUiDelegates, progress: { progress in
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
