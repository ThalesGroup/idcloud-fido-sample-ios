//
//
// Copyright © 2020-2022 THALES. All rights reserved.
//

//
//  Authenticators.swift
//  Advanced
//

import Foundation
import IdCloudClient

class ActivatedAuthenticators : NSObject {
    
    // Set up an instance variable of IDCIdCloudClient
    private var idcloudclient: IDCIdCloudClient!
    typealias CompletionClosure = (IDCError?) -> ()
    
    override init() {
       
    }
    
    func execute(completion: @escaping CompletionClosure) -> [Authenticator] {
   
        do {
            // Initialize an instance of IDCIdCloudClient.
            self.idcloudclient = try IDCIdCloudClient(url: MS_URL, tenantId: TENANT_ID)
            // Retrieve a list of previously registered authenticators. Use this list to properly manage your authenticators.
            let authenticators = try idcloudclient.activatedAuthenticators()
            return authenticators
        } catch let error as IDCError {
            completion(error)
            return []
        } catch _ {
            fatalError("Unhandled error.")
        }
    }
}
