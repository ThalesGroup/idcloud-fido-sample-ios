//
//
// Copyright © 2020-2022 THALES. All rights reserved.
//

//
//  AppDelegate.swift
//  GettingStarted
//

import UIKit
import IdCloudClient
import IdCloudClientUi

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var idcloudclient: IDCIdCloudClient!
    var request: IDCUnenrollRequest!
    
    var secureLog : SecureLog!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialise SecureLog, to log necessary retrievable information.
        initializeSecureLog()

        // Configure the PIN policy ruloes
        configurePinRules()

        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        var vc: UIViewController
        if SamplePersistence.isEnrolled {
            vc = AppDelegate.mainViewHierarchy()
        } else {
            vc = AppDelegate.enrollViewHierarchy()
        }
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        
#if ADVANCED
        UNUserNotificationCenter.current().delegate = self
#endif
        
        return true
    }
}

#if ADVANCED
// MARK: Push Notification
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(String(describing: token))")
        NotificationCenter.default.post(name: PushNotificationConstants.didRegisterForRemoteNotificationsWithDeviceToken, object: token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
        NotificationCenter.default.post(name: PushNotificationConstants.didFailToRegisterForRemoteNotificationsWithError, object: nil)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(name: PushNotificationConstants.didReceiveUserNotification, object: userInfo)
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        NotificationCenter.default.post(name: PushNotificationConstants.willPresentUserNotification, object: userInfo)
        
        completionHandler(UNNotificationPresentationOptions(rawValue: 0))
    }
}
#endif

// MARK: App-links
extension AppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL,
              let components = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
              let code = components.queryItems?.first?.value else {
                  return false
              }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(name: AppLinksConstants.didContinueUserActivity, object: code)
        }
        return true
    }
}

// MARK: Helper Methods
extension AppDelegate {
    static func enrollViewHierarchy() -> UIViewController {
        let enrollNVC = UINavigationController(rootViewController: EnrollViewController())
        enrollNVC.navigationBar.isTranslucent = false
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .extBackground
            enrollNVC.navigationBar.standardAppearance = appearance
            enrollNVC.navigationBar.scrollEdgeAppearance = enrollNVC.navigationBar.standardAppearance
        }
        return enrollNVC
    }
    
    static func mainViewHierarchy() -> UIViewController {
        var vc: UIViewController
#if GETTING_STARTED
        let authenticateNVC = UINavigationController(rootViewController: AuthenticateViewController())
        authenticateNVC.navigationBar.isTranslucent = false

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .extBackground
            authenticateNVC.navigationBar.standardAppearance = appearance
            authenticateNVC.navigationBar.scrollEdgeAppearance = authenticateNVC.navigationBar.standardAppearance
        }
        vc = authenticateNVC
#elseif ADVANCED
        vc = MainTabBarController()
        if let vc = vc as? UITabBarController {
            vc.tabBar.isTranslucent = false
            let mainNVC = UINavigationController(rootViewController: MainViewController())
            mainNVC.navigationBar.isTranslucent = false
            vc.addChild(mainNVC)
            mainNVC.tabBarItem.image = #imageLiteral(resourceName: "home")
            mainNVC.tabBarItem.title = NSLocalizedString("home_tabbar_title", comment: "")
            
            let authenticatorsNVC = UINavigationController(rootViewController: AuthenticatorsViewController())
            authenticatorsNVC.navigationBar.isTranslucent = false
            vc.addChild(authenticatorsNVC)
            authenticatorsNVC.tabBarItem.image = #imageLiteral(resourceName: "lock_tabbar")
            authenticatorsNVC.tabBarItem.title = NSLocalizedString("authenticators_tabbar_title", comment: "")
            
            let settingsNVC = UINavigationController(rootViewController: SettingsViewController())
            settingsNVC.navigationBar.isTranslucent = false
            vc.addChild(settingsNVC)
            settingsNVC.tabBarItem.image = #imageLiteral(resourceName: "settings")
            settingsNVC.tabBarItem.title = NSLocalizedString("settings_tabbar_title", comment: "")
            
            if #available(iOS 13.0, *) {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithOpaqueBackground()
                vc.tabBar.standardAppearance = tabBarAppearance
                
#if compiler(>=5.5) // Use compiler check, 5.5 compiler is Xcode 13. So that code doesn't compile on older Xcode
                if #available(iOS 15.0, *) {
                    vc.tabBar.scrollEdgeAppearance = vc.tabBar.standardAppearance
                }
#endif
            }
        }
#endif
        if #available(iOS 13.0, *) {
            if let nvcs = vc.children as? [UINavigationController] {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .extBackground
                
                for nvc in nvcs {
                    nvc.navigationBar.standardAppearance = appearance
                    nvc.navigationBar.scrollEdgeAppearance = nvc.navigationBar.standardAppearance
                }
            }
        }
        
        return vc
    }
    
    static func switchWindowRootViewController(_ viewController: UIViewController) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        window.rootViewController = viewController
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromBottom, animations: {}, completion: nil)
    }
    
    // MARK: Private Methods
    
    private func initializeSecureLog() {
        
        //Configure SecureLog
        let config = SecureLogConfig { (slComps) in
            slComps.fileID = "sample"
            
            //Set Mandatory parameters
            slComps.publicKeyModulus = NSData(bytes: SecureLogPublicKey.publicKeyModulus, length:SecureLogPublicKey.publicKeyModulus.count) as Data
            slComps.publicKeyExponent = NSData(bytes: SecureLogPublicKey.publicKeyExponent, length: SecureLogPublicKey.publicKeyExponent.count) as Data
        }
        //create instance of secure logger with configuration, only 1 instance is allowed to be created.
        secureLog = IDCIdCloudClient.configureSecureLog(config)
    }

    private func configurePinRules() {
        // Configure the PIN minimum and maximum accepted lengths.
        IDCPinConfig.setMinimumLength(PIN_LENGTH.min)
        IDCPinConfig.setMaximumLength(PIN_LENGTH.max)

        // Set the PIN rule policy.
        do {
            try IDCPinConfig.setPinRules(PIN_RULES)
        } catch let error {
            fatalError("Failed to set pin rules! error:\(error.localizedDescription)")
        }
    }
}
