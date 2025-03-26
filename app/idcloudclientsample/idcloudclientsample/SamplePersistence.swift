//
//
// Copyright © 2020 THALES. All rights reserved.
//

//
//  SamplePersistence.swift
//  idcloudclientsample
//
//

import Foundation

struct SamplePersistence {
    private static let IsEnrolledKey: String = "IsEnrolledKey"
    private static let IsEulaAccepted: String = "IsEulaAcceptedKey"

    static var isEnrolled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: IsEnrolledKey)
        }
    }
    
    static func setEnrolled(_ isEnrolled: Bool) {
        UserDefaults.standard.set(isEnrolled, forKey: IsEnrolledKey)
    }
    
    static var isEulaAccepted: Bool {
        get {
            return UserDefaults.standard.bool(forKey: IsEulaAccepted)
        }
    }
    
    static func setEulaAccepted(_ isEulaAccepted: Bool) {
        UserDefaults.standard.set(isEulaAccepted, forKey: IsEulaAccepted)
    }
}
