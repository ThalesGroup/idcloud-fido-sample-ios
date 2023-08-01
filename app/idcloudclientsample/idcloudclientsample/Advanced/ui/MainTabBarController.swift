//
//
// Copyright © 2022 THALES. All rights reserved.
//

//
//  MainTabBarController.swift
//  Advanced
//
//

import UIKit
import IdCloudClient
import IdCloudClientUi

class MainTabBarController: UITabBarController {
    private var processNotificationObj: ProcessNotification!
    let clientConformer = CustomAppClientConformer()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the presentViewClosure. This is required to enable a proper management
        // of the view hierarchy.
        clientConformer.presentViewClosure = { [weak self] (presentViewController: UIViewController, isPresent: Bool) in
            guard let navigationController = self?.selectedViewController as? UINavigationController else {
                return
            }

            if isPresent {
                navigationController.present(presentViewController, animated: true, completion: nil)
            } else if let navigationController = self?.selectedViewController as? UINavigationController {
                navigationController.pushViewController(presentViewController, animated: true)
            }
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.processNotification(_:)), name: PushNotificationConstants.didReceiveUserNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.processNotification(_:)), name: PushNotificationConstants.willPresentUserNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleUserActivityEnroll(_:)), name: AppLinksConstants.didContinueUserActivity, object: nil)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: PushNotificationConstants.didReceiveUserNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: PushNotificationConstants.willPresentUserNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AppLinksConstants.didContinueUserActivity, object: nil)
        super.viewWillDisappear(animated)
    }

    // MARK: IBActions

    @objc func processNotification(_ notification: Notification) {
        // Execute the process notification use-case.

        // Retrieve the notification object from Notification
        // This object is then passed to the IdCloud FIDO SDK for further processing.
        // The SDK will then proceed to complete any pending scenarios.
        let notificationObject = notification.object as! [AnyHashable : Any]

        // Initialize an instance of the ProcessNotification use-case, providing
        // (1) the uiDelegates
        processNotificationObj = ProcessNotification(uiDelegates: clientConformer)
        processNotificationObj.execute(notification: notificationObject, progress: { [weak self] (progress) in
            if let navigationController = self?.selectedViewController as? UINavigationController,
               let aView = navigationController.topViewController?.view {
                ProgressHud.showProgress(forView: aView, progress: progress)
            }
        }, completion: { [weak self] (error) in
            // Remove all views displayed by the IdCloud FIDO UI SDK.
            if let navigationController = self?.selectedViewController as? UINavigationController {
                navigationController.popToRootViewController(animated: true)
            }

            if error == nil {
                // Display the result of the use-case and proceed accordingly.
                UIAlertController.showToast(viewController: self,
                                            title: NSLocalizedString("fetch_alert_title", comment: ""),
                                            message: NSLocalizedString("fetch_alert_message", comment: ""))
            } else {
                UIAlertController.showErrorAlert(viewController: self?.navigationController,
                                                 error: error!)
            }
        })
    }

    @objc internal func handleUserActivityEnroll(_ notification: Notification) {
        guard let navigationController = selectedViewController as? UINavigationController,
                SamplePersistence.isEnrolled else {
            return
        }

        UIAlertController.showAlert(viewController: navigationController,
                                    title: NSLocalizedString("alert_error_title", comment: ""),
                                    message: NSLocalizedString("app_link_error_alert_message", comment: ""))
    }
}
