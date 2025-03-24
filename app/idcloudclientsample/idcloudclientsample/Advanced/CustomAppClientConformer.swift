//
//
// Copyright © 2021 THALES. All rights reserved.
//

//
//  CustomAppClientConformer.swift
//  Advanced
//
//

import UIKit
import IdCloudClient
import IdCloudClientUi
import LocalAuthentication

public typealias PresentViewClosure = ((_ vc: UIViewController, _ isPresent: Bool) -> ())

open class CustomAppClientConformer: NSObject {
    open var presentViewClosure: PresentViewClosure?
    private var pinpadVC: PinPadViewController?
    
    // MARK: Private
    
    private func amountString(from amount: String, currencyCode: String) -> String? {
        guard let floatAmount = Float(amount) else {
            return nil
        }
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = currencyCode
        return nf.string(from: NSNumber(value: floatAmount))
    }
    
    private func dateString(from timeInMiliseconds: String) -> String? {
        guard let timeIntervalInMiliseconds = TimeInterval(timeInMiliseconds) else {
            return nil
        }
        let timeInterval = timeIntervalInMiliseconds / 1000.0
        let date = Date(timeIntervalSince1970: timeInterval)
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        
        let dateString = df.string(from: date)
        
        return dateString
    }
}

extension CustomAppClientConformer: PlatformUiDelegate {
    public func idCloudClient(_ idCloudClient: IdCloudClient.IDCIdCloudClient, presentationForPlatformController controller: IdCloudClient.PlatformController) -> UIWindow {
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
    }
}

extension CustomAppClientConformer: BiometricUiDelegate {
    public func idCloudClient(_ idCloudClient: IdCloudClient.IDCIdCloudClient, touchIdOperationPromptFor scenarioContext: IdCloudClient.ScenarioContext) -> String {
        var message = "Biometric verification"
        if let rpId = scenarioContext.content[.message] as? String {
            message += " for \(rpId)"
        }
        return message
    }
    
    public func idCloudClient(_ idCloudClient: IdCloudClient.IDCIdCloudClient, biometricShouldStartFor scenarioContext: IdCloudClient.ScenarioContext, startHandler: @escaping ((Bool) -> Void)) {
        guard let biometryType = scenarioContext.content[.biometryType] as? LABiometryType else {
            startHandler(false)
            return
        }
        
        var message = "Biometric verification"
        if let rpId = scenarioContext.content[.message] as? String {
            message += " for \(rpId)"
        }
        
        switch biometryType {
        case .faceID:
            let alertController = UIAlertController(title: "Face ID", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Start", style: .default) { (action) in
                startHandler(true)
            })
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                startHandler(false)
            })
            presentViewClosure?(alertController, true)
        case .touchID:
            startHandler(true)
        default:
            fatalError("BiometryType must not be none")
        }
    }
}

extension CustomAppClientConformer: CommonUiDelegate {
    public func idCloudClient(_ idCloudClient: IdCloudClient.IDCIdCloudClient, authenticators: [IdCloudClient.Authenticator], userChoiceHandler: @escaping (IdCloudClient.Authenticator) -> Void, cancelHandler: @escaping () -> Void) {
        if authenticators.count == 0 {return}
        let actionSheet = UIAlertController(title: "How do you want to be authenticated?", message: nil, preferredStyle: .actionSheet)
        for authenticator in authenticators {
            var title = ""
            switch authenticator.type {
            case .biometric:
                title = "Biometric"
            case .pin:
                title = "PIN"
            case .platform:
                title = "Platform"
            default:
                title = ""
            }
            let action = UIAlertAction(title: title, style: .default) { (action) in
                userChoiceHandler(authenticator)
            }
            actionSheet.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] (action) in
            let revertHandler: () -> Void = { [weak self] in
                self?.idCloudClient(idCloudClient, authenticators: authenticators, userChoiceHandler: userChoiceHandler, cancelHandler: cancelHandler)
            }
            if let cancelConfirmationAlert: UIViewController = self?.cancelConfirmationAlert(cancelHandler: cancelHandler, revertHandler: revertHandler)  {
                self?.presentViewClosure?(cancelConfirmationAlert, true)
            }
        }
        actionSheet.addAction(cancelAction)
        
        // Constraint bug on iOS
        // Workaround documented here
        // https://stackoverflow.com/questions/55430168/how-to-fix-actionsheet-of-uialertcontroller-has-the-conflict-constraint-error
        actionSheet.view.subviews.flatMap({$0.constraints}).filter{ (one: NSLayoutConstraint)-> (Bool)  in
           return (one.constant < 0) && (one.secondItem == nil) &&  (one.firstAttribute == .width)
        }.first?.isActive = false

        presentViewClosure?(actionSheet, true)
    }
    
    public func idCloudClient(_ idCloudClient: IdCloudClient.IDCIdCloudClient, authenticatorDescription authenticator: IdCloudClient.Authenticator, authenticatorDescriptionHandler: @escaping (IdCloudClient.AuthenticatorDescriptor) -> Void, cancelHandler: @escaping () -> Void) {
        var authenticatorName: String = ""
        switch authenticator.type {
        case .biometric:
            authenticatorName = "Biometric"
        case .pin:
            authenticatorName = "PIN"
        case .platform:
            authenticatorName = "Platform"
        @unknown default:
            fatalError()
        }
        
        let authenticatorDescriptor = AuthenticatorDescriptor(friendlyName: "\(authenticatorName) Authenticator")
        authenticatorDescriptionHandler(authenticatorDescriptor)
    }
    
    public func idCloudClient(_ idCloudClient: IdCloudClient.IDCIdCloudClient, transactionConfirmation transactionContext: IdCloudClient.TransactionContext, proceedHandler: @escaping () -> Void, cancelHandler: @escaping () -> Void) {
        let transactionDetails = transactionContext.transactionDetails
        var message = NSLocalizedString("sign_alert_message_default", comment: "")
        if let timeInMiliseconds = transactionDetails["date"],
           let date = dateString(from: timeInMiliseconds),
           let amount = transactionDetails["amount"],
           let currencyCode = transactionDetails["currency"],
           let amountString = amountString(from: amount, currencyCode: currencyCode),
           let from = transactionDetails["from"],
           let to = transactionDetails["to"] {
            
            message = String(format: NSLocalizedString("sign_alert_message: date %@ amount %@ from %@ to %@", comment: ""), date, amountString, from, to)
        }
        
        let alertController = UIAlertController(title: NSLocalizedString("sign_alert_title", comment: ""), message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("alert_proceed", comment: ""), style: .default, handler:  {(action) in
            proceedHandler()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("alert_cancel", comment: ""), style: .cancel, handler: {(action) in
            cancelHandler()
        }))
        presentViewClosure?(alertController, true)
    }
}

extension CustomAppClientConformer: SecurePinPadUiDelegate {
    public func idCloudClient(_ idCloudClient: IdCloudClient.IDCIdCloudClient, willEnterPin securePinPad: any IdCloudClient.SecurePinPad, scenarioContext: IdCloudClient.ScenarioContext, cancelHandler: @escaping () -> Void) {
        let content = scenarioContext.content[.message] as? String ?? ""
        pinpadVC = PinPadViewController(pinpad: securePinPad, content: content, cancelHandler: cancelHandler)
        presentViewClosure?(pinpadVC!, false)
    }
    
    
}

// MARK: Private
extension CustomAppClientConformer {
    private func cancelConfirmationAlert(cancelHandler: @escaping () -> Void, revertHandler: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "Do you want to cancel this process?", message: nil, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            cancelHandler()
        }
        let noAction = UIAlertAction(title: "No", style: .cancel) { (action) in
            revertHandler()
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)

        return alert
    }
}
