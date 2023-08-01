//
//
// Copyright © 2020-2022 THALES. All rights reserved.
//

//
//  Configuration.swift
//  GettingStarted
//
//

import Foundation
import IdCloudClient

// IdCloud Mobile Service Server URL
let URL = ""

// IdCloud Server Tenant ID
#if DEBUG
let TENANT_ID = ""
#else
let TENANT_ID = ""
#endif


// IdCloud PIN Authenticator rules
let PIN_RULES: IDCPinRule = [.length, .palindrome, .series, .uniform]

// IdCloud PIN Authenticator minimum and maximum lengths
let PIN_LENGTH: (min: UInt, max: UInt) = (6, 8)

// IdCloud Securelog public key
struct SecureLogPublicKey {
    //Replace this byte array with your own public key modulus.
     static let publicKeyModulus: [CUnsignedChar] = []
    //Replace this byte array with your own public key exponent.
    static let publicKeyExponent: [CUnsignedChar] = []
}
