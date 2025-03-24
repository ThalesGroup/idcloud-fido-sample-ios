//
//
// Copyright © 2021-2022 THALES. All rights reserved.
//

//
//  Enroll.swift
//  idcloudclientsample
//

import Foundation
import IdCloudClient

class Enroll: NSObject {
    typealias ProgressClosure = (IDCProgress) -> ()
    typealias CompletionClosure = (IDCError?) -> ()
    
    private var _enrollmentToken: EnrollmentToken?
    var enrollmentToken: EnrollmentToken! {
        set {
            if _enrollmentToken == nil {
                // Ignore incoming value
                _enrollmentToken = newValue
            }
        }
        get {
            return _enrollmentToken
        }
    }

    internal let code: String
    private let uiDelegates: CommonUiDelegate & BiometricUiDelegate & SecurePinPadUiDelegate
    
    // Set up an instance variable of IDCIdCloudClient
    private var idcloudclient: IDCIdCloudClient!
    private var request: EnrollRequest!
    
    init(code: String, uiDelegates: CommonUiDelegate & BiometricUiDelegate & SecurePinPadUiDelegate) {
        self.code = code
        self.uiDelegates = uiDelegates
    }
    
    func execute(progress progressClosure: @escaping ProgressClosure, completion: @escaping CompletionClosure) {
        do {
            // Initialize an instance of IDCIdCloudClient.
            self.idcloudclient = try IDCIdCloudClient(url: MS_URL, tenantId: TENANT_ID)
            
            // Initialize an instance of IDCEnrollmentToken from its corresponding Factory.
            // Instances of IDCEnrollmentToken are initialized with a code retrieved from the Bank via a QR code (i.e. or other means) and is simply encoded as a UTF8 data.
            enrollmentToken = try EnrollmentTokenFactory.createEnrollmentToken(code.data(using: .utf8)!)
            
            // Set up an instance of IDCUiDelegates, an encapsulated class containing all necessary UI delegates required by IdCloud FIDO SDK.
            // Ensure that you conform to these corresponding delegates.
            // Required callbacks are essential to ensure a proper UX behaviour
            // As a means of convenience, the IdCloud FIDO UI SDK provides a ClientConformer class which conforms to all necessary delegates of IdCloud FIDO SDK
            var idcUiDelegates = UiDelegates()
            idcUiDelegates.commonUiDelegate = uiDelegates
            idcUiDelegates.biometricUiDelegate = uiDelegates
            idcUiDelegates.securePinPadUiDelegate = uiDelegates
            
            // Create an instance of the Enrollment request providing the required credentials.
            // Instances of requests should be held as an instance variable to ensure that completion callbacks will function as expected and to prevent unexpected behaviour.
            request = idcloudclient.createEnrollRequest(with: enrollmentToken,
                                                        uiDelegates: idcUiDelegates, progress: { (progress) in
                // Refer to IDCProgress for corresponding callbacks which provide an update to the existing request execution.
                progressClosure(progress)
            }, completion: { [weak self] (response, error) in
                // Callback to the UI.
                // These are executed on the Main thread.
                self?.enrollmentToken.wipe()
                completion(error)
            })
            
            // Execute the request.
            // Requests on IdCloud FIDO SDK are executed on the own unique threads.
            request.execute()
        } catch let error as IDCError {
            completion(error)
        } catch _ {
            fatalError("Invalid unhandled error.")
        }
    }
}
