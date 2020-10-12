//
//  SamplePersistence.swift
//  idcloudclientsample
//
//

import Foundation

struct SamplePersistence {
    private static let IsEnrolledKey: String = "IsEnrolledKey"
    
    static var isEnrolled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: IsEnrolledKey)
        }
    }
    
    static func setEnrolled(_ isEnrolled: Bool) {
        UserDefaults.standard.set(isEnrolled, forKey: IsEnrolledKey)
    }
}
