//
//  Authenticators.swift
//  Advanced
//

import Foundation
import IdCloudClient

class ActivatedAuthenticators : NSObject {
    
    private let url: String
    
    // Set up an instance variable of IDCIdCloudClient
    private let idcloudclient: IDCIdCloudClient

    init(url: String) {
        self.url = url
        
        // Initialize an instance of IDCIdCloudClient.
        self.idcloudclient = IDCIdCloudClient(url: url)
    }
    
    func execute() -> [IDCAuthenticator] {
        // Retrieve a list of previously registered authenticators. Use this list to properly manage your authenticators.
        return idcloudclient.activatedAuthenticators()
    }
}
