//
//
// Copyright © 2022 THALES. All rights reserved.
//

//
//  UIAlertControllerExtension.swift
//  idcloudclientsample
//
//

import UIKit
import IdCloudClient

extension UIAlertController {
    static func showAlert(viewController: UIViewController?,
                          title: String,
                          message: String,
                          okMessage: String = NSLocalizedString("alert_ok", comment: ""),
                          okAction: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: okMessage, style: .default, handler: okAction))
        viewController?.present(alertController, animated: true, completion: nil)
    }

    static func showErrorAlert(viewController: UIViewController?,
                               error: NSError,
                               okMessage: String = NSLocalizedString("alert_ok", comment: ""),
                               okAction: ((UIAlertAction) -> Void)? = nil) {
        // Do not show alert when error code is IDCErrorUserCancelled
        let idcError = IDCError(_nsError: error)
        if idcError.code == .userCancelled {
            return
        }
        let alertController = UIAlertController(title: NSLocalizedString("alert_error_title", comment: ""),
                                                message: idcError.localizedDescription,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: okMessage, style: .default, handler: okAction))
        viewController?.present(alertController, animated: true, completion: nil)
    }

    static func showToast(viewController: UIViewController?,
                          title: String,
                          message: String,
                          duration: Double = 1.5,
                          completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        viewController?.present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            alertController.dismiss(animated: true, completion: completion)
        }
    }
}
