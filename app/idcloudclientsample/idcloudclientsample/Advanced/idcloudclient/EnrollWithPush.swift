//
//  EnrollWithPush.swift
//  idcloudclientsample
//
//

import Foundation
import IdCloudClient

class EnrollWithPush: Enroll {
    private var progressClosure: Enroll.ProgressClosure!
    private var executeCompletion: Enroll.CompletionClosure!
    
    override func execute(progress progressClosure: @escaping Enroll.ProgressClosure, completion: @escaping Enroll.CompletionClosure) {
        self.progressClosure = progressClosure
        self.executeCompletion = completion
        
        // Refer to the PushNotificationManager for convenience methods regarding push notification registration.
        PushNotificationManager.registerForPushNotifications { [unowned self] enableRemoteNotifications in
            if enableRemoteNotifications {
                // Add observers to set up deviceToken prior to Enroll.
                NotificationCenter.default.addObserver(self, selector: #selector(self.setUpDeviceTokenAndEnroll(_:)), name: PushNotificationConstants.didRegisterForRemoteNotificationsWithDeviceToken, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.setUpDeviceTokenAndEnroll(_:)), name: PushNotificationConstants.didFailToRegisterForRemoteNotificationsWithError, object: nil)
            } else {
                // Proceed with Enroll.
                self.enroll()
            }
        }
    }
    
    // MARK: Notification Observers
    
    @objc private func setUpDeviceTokenAndEnroll(_ notification: Notification) {

        guard let devicePushToken = notification.object as? String else {
            fatalError("Notification should contain a devicePushToken")
        }
        
        enrollmentToken = IDCEnrollmentTokenFactory.createEnrollmentToken(code.data(using: .utf8)!)
        
        // Set the devicePushToken to be used for subsequent remote notifications.
        enrollmentToken.setDevicePushToken(devicePushToken)
        enroll()
    }
    
    // MARK: Private Helper Functions
    
    private func enroll() {
        super.execute(progress: progressClosure, completion: executeCompletion)
        
        // Remove reference to existing enrollment token
        enrollmentToken = nil
    }
}

