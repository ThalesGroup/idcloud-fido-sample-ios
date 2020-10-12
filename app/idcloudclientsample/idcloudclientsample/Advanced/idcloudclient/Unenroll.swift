//
//  Unenroll.swift
//  Advanced
//

import Foundation
import IdCloudClient

class Unenroll : NSObject {
    typealias CompletionClosure = (NSError?) -> ()

    private let url: String
    
    // Set up an instance variable of IDCIdCloudClient
    private let idcloudclient: IDCIdCloudClient
    private var request: IDCUnenrollRequest!

    init(url: String) {
        self.url = url
        
        // Initialize an instance of IDCIdCloudClient.
        self.idcloudclient = IDCIdCloudClient(url: url)
    }
    
    func execute(completion: @escaping CompletionClosure) {
        // Create an instance of the Unenroll request.
        // Instances of requests should be held as an instance variable to ensure that completion callbacks will function as expected and to prevent unexpected behaviour.
        request = idcloudclient.createUnenrollRequest() { (progress) in
            // Refer to IDCProgress for corresponding callbacks which provide an update to the existing request execution.
        } completion: { (response, error) in
            // Callback to the UI.
            // These are executed on the Main thread.
            // As a resutl of the unenroll request, the user is returned to an initial (default) state.
            // The user would that need to re-enroll in order to properly utilize the IdCloud FIDO SDK.
            completion(error as NSError?)
        }
        
        // Execute the request.
        // Requests on IdClouf FIDO SDK are executed on the own unique threads.
        request.execute()
    }
}
