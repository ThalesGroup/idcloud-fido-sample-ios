//
//
// Copyright © 2020-2022 THALES. All rights reserved.
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
    private let idcloudclient: IDCIdCloudClient!
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
        /* 1 */
        ## Set up UI Delegates ##

        // Create an instance of the Fetch request.
        // Instances of requests should be held as an instance variable to ensure that completion callbacks will function as expected and to prevent unexpected behaviour.
        /* 2 */
        ## Create necessary request ##
        
        // Execute the request.
        // Requests on IdCloud FIDO SDK are executed on the own unique threads.
        // Ensure that an Authentication scenario was previously invoked. Otherwise, an Error will be returned when no actionable events are present.
        /* 3 */
        ## Execute request ##
    }

}
