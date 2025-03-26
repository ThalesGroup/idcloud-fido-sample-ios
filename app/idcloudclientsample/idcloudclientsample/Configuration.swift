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
let MS_URL = ""

// IdCloud EULA URL
let EULA_URL = "https://thales-cpl.stoplight.io/docs/idcloud-fido/dkfz5854w3rab-mobile-testing-application-end-user-license-agreement"

// IdCloud Server Tenant ID
#if DEBUG
let TENANT_ID = ""
#else
let TENANT_ID = ""
#endif

// IdCloud PIN Authenticator rules
let PIN_RULES: PinConfig.PinRule = [.length, .palindrome, .series, .uniform]

// IdCloud PIN Authenticator minimum and maximum lengths
let PIN_LENGTH: (min: UInt, max: UInt) = (6, 8)

// IdCloud Securelog public key
struct SecureLogPublicKey {
    //Replace this byte array with your own public key modulus.
     static let publicKeyModulus: [CUnsignedChar] = []
    //Replace this byte array with your own public key exponent.
    static let publicKeyExponent: [CUnsignedChar] = []
}
