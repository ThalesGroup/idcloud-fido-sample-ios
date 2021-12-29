//
//  PushNotifications.swift
//  idcloudclientsampleapp
//
//  Copyright © 2021 Thales Group. All rights reserved.
//

import Foundation
import UIKit

struct PushNotificationConstants {
    static let didRegisterForRemoteNotificationsWithDeviceToken = NSNotification.Name(rawValue: "didRegisterForRemoteNotificationsWithDeviceToken")
    static let didFailToRegisterForRemoteNotificationsWithError = NSNotification.Name(rawValue: "didFailToRegisterForRemoteNotificationsWithError")
    static let didReceiveUserNotification = NSNotification.Name(rawValue: "didReceiveUserNotification")
    static let willPresentUserNotification = NSNotification.Name(rawValue: "willPresentUserNotification")
}

class PushNotificationManager {
    
    static func registerForPushNotifications(completion: @escaping (Bool)->()) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            getNotificationSettings(completion: completion)
        }
    }
    
    private static func getNotificationSettings(completion: @escaping (Bool)->()) {
        UNUserNotificationCenter.current().getNotificationSettings {settings in
            switch settings.authorizationStatus {
            case .authorized,.provisional,.ephemeral:
                completion(true)
            case .denied,.notDetermined:
                completion(false)
                return
            @unknown default:
                return
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

