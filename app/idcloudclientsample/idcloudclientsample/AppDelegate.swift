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
        
        //Initialise SecureLog, to log necessary retrievable information.
        initializeSecureLog()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        var vc: UIViewController
        if SamplePersistence.isEnrolled {
            vc = AppDelegate.mainViewHierarchy()
        } else {
            vc = AppDelegate.enrollViewHierarchy()
        }
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    static func enrollViewHierarchy() -> UIViewController {
        let enrollNVC = UINavigationController(rootViewController: EnrollViewController())
        enrollNVC.navigationBar.isTranslucent = false
        return enrollNVC
    }
    
    static func mainViewHierarchy() -> UIViewController {
        var vc: UIViewController
#if GETTING_STARTED
        let authenticateNVC = UINavigationController(rootViewController: AuthenticateViewController())
        authenticateNVC.navigationBar.isTranslucent = false
        vc = authenticateNVC
#elseif ADVANCED
        vc = UITabBarController()
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
        }
#endif
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
            //Set Mandatory parameters
            slComps.publicKeyModulus = NSData(bytes: SecureLogPublicKey.publicKeyModulus, length:SecureLogPublicKey.publicKeyModulus.count) as Data
            slComps.publicKeyExponent = NSData(bytes: SecureLogPublicKey.publicKeyExponent, length: SecureLogPublicKey.publicKeyExponent.count) as Data
        }
        //create instance of secure logger with configuration, only 1 instance is allowed to be created.
        secureLog = IDCIdCloudClient.configureSecureLog(config)
    }
}

