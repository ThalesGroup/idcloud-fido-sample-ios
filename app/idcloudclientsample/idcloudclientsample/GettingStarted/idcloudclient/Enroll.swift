//
//  Enroll.swift
//  idcloudclientsample
//

import Foundation
import IdCloudClient

class Enroll : NSObject {
    typealias ProgressClosure = (IDCProgress) -> ()
    typealias CompletionClosure = (NSError?) -> ()

    private let code: String
    private let uiDelegates: IDCCommonUiDelegate & IDCBiometricUiDelegate & IDCSecurePinPadUiDelegate
    
    // Set up an instance variable of IDCIdCloudClient
    private let idcloudclient: IDCIdCloudClient
    private var request: IDCEnrollRequest!
    
    init(code: String, url: String, uiDelegates: IDCCommonUiDelegate & IDCBiometricUiDelegate & IDCSecurePinPadUiDelegate) {
        self.code = code
        self.uiDelegates = uiDelegates
        
        // Initialize an instance of IDCIdCloudClient.
        self.idcloudclient = IDCIdCloudClient(url: url)
    }
    
    func execute(progress progressClosure: @escaping ProgressClosure, completion: @escaping CompletionClosure) {
        
        // Initialize an instance of IDCEnrollmentToken from its corresponding Factory.
        // Instances of IDCEnrollmentToken are initialized with a code retrieved from the Bank via a QR code (i.e. or other means) and is simply encoded as a UTF8 data.
        /* 1 */
        ## Insert enrollment token creation ##
        
        
        // Set up an instance of IDCUiDelegates, an encapsulated class containing all necessary UI delegates required by IdCloud FIDO SDK.
        // Ensure that you conform to these corresponding delegates.
        // Required callbacks are essential to ensure a proper UX behaviour.
        // As a means of convenience, the IdCloud FIDO UI SDK provides a ClientConformer class which conforms to all necessary delegates of IdCloud FIDO SDK
        /* 2 */
        ## Set up UI Delegates ##
        
        
        // Create an instance of the Enrollment request providing the required credentials.
        // Instances of requests should be held as an instance variable to ensure that completion callbacks will function as expected and to prevent unexpected behaviour.
        /* 3 */
        ## Create necessary request ##
        
        
        // Execute the request.
        // Requests on IdClouf FIDO SDK are executed on the own unique threads.
        /* 4 */
        ## Execute request ##
        
        
    }
}
