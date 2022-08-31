//
//  Authenticators.swift
//  Advanced
//

import Foundation
import IdCloudClient

class ActivatedAuthenticators : NSObject {
    
    // Set up an instance variable of IDCIdCloudClient
    private var idcloudclient: IDCIdCloudClient!
    typealias CompletionClosure = (NSError?) -> ()
    
    override init() {
       
    }
    
    func execute(completion: @escaping CompletionClosure) -> [IDCAuthenticator] {
   
        do {
            // Initialize an instance of IDCIdCloudClient.
            self.idcloudclient = try IDCIdCloudClient(url: URL, tenantId: TENANT_ID)
            // Retrieve a list of previously registered authenticators. Use this list to properly manage your authenticators.
            let authenticators = try idcloudclient.activatedAuthenticators()
            return authenticators
        } catch let error {
            completion(error as NSError?)
            return [];
        }
    }
}
