//
//
// Copyright © 2020-2022 THALES. All rights reserved.
//

//
//  MainViewController.swift
//  Advanced
//

import UIKit
import IdCloudClientUi
import SSZipArchive
import IdCloudClient

class MainViewController: UIViewController {
    private let authenticateButton: UIButton = UIButton(type: .system)
    private let descriptionLabel: UILabel = UILabel()
    private var authenticateObj: Authenticate!
    private var unenrollObj: Unenroll!
    private var secureLogObj : SecureLogArchive!
    
    // IdCloud FIDO UI SDK provides a conformer to the necessary delegates of IdCloud FIDO SDK
    // providing integrators with a convenient way of exploring the use-cases available.
    // This sample further extends the feature provided by the IdCloud FIDO UI SDK to customize the displays even further.
    let clientConformer = CustomAppClientConformer()

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Init navigation bar to add action button for sending log files.
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareLogFiles))
        navigationItem.setRightBarButton(shareButton, animated: false)

        view.backgroundColor = UIColor.extBackground
        
        authenticateButton.setTitle(NSLocalizedString("fetch_button_title", comment: ""), for: .normal)
        authenticateButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        authenticateButton.addTarget(self, action: #selector(authenticate(_:)), for: .touchUpInside)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = NSLocalizedString("fetch_instruction", comment: "")
        
        let unenrollButton = UIBarButtonItem(title: NSLocalizedString("unenroll_button_title", comment: ""),
                                             style: .plain,
                                             target: self,
                                             action: #selector(unenroll(_:)))
        navigationItem.setLeftBarButton(unenrollButton, animated: false)
        
        setupLayout()
        
        // Set up the presentViewClosure. This is required to enable a proper management
        // of the view hierarchy.
        clientConformer.presentViewClosure = { [weak self] (presentViewController: UIViewController, isPresent: Bool) in
            if isPresent {
                self?.navigationController?.present(presentViewController, animated: true, completion: nil)
            } else {
                self?.navigationController?.pushViewController(presentViewController, animated: true)
            }
        }
    }

    // MARK: IBActions
    
    @objc internal func shareLogFiles(sender: AnyObject) {
        //Set up an instance of the SecureLogArchive to prepare archiving logfiles
        secureLogObj = SecureLogArchive.init()
        // Retreive archivePath
        let archivePath = secureLogObj.execute()
        
        //User press this button to send logfiles.
        let activityVC = UIActivityViewController(activityItems: [archivePath], applicationActivities: nil)
        //Support share files through airdrop & mail
        activityVC.excludedActivityTypes = [.addToReadingList,
                                            .assignToContact,
                                            .copyToPasteboard,
                                            .message,
                                            .openInIBooks,
                                            .postToFacebook,
                                            .postToFlickr,
                                            .postToTencentWeibo,
                                            .postToTwitter,
                                            .postToVimeo,
                                            .postToWeibo,
                                            .print,
                                            .saveToCameraRoll,
                                            .markupAsPDF]
       
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @objc internal func authenticate(_ button: UIButton) {
        // Execute the authentication use-case.
        // Ensure that this use-case is first initiated on the server generate a scenario.

        
        // Initialize an instance of the Authenticate use-case, providing
        // (1) the uiDelegates
        authenticateObj = Authenticate(uiDelegates: clientConformer)
        authenticateObj.execute(progress: { [weak self] (progress) in
            if let aView = self?.view {
                ProgressHud.showProgress(forView: aView, progress: progress)
            }
        }, completion: { [weak self] (error) in
            // Remove all views displayed by the IdCloud FIDO UI SDK.
            self?.navigationController?.popToRootViewController(animated: true)
            
            if error == nil {
                // Display the result of the use-case and proceed accoridngly.
                UIAlertController.showToast(viewController: self?.navigationController,
                                            title: NSLocalizedString("fetch_alert_title", comment: ""),
                                            message: NSLocalizedString("fetch_alert_message", comment: ""))
            } else {
                let idcError = IDCError(_nsError: error!)
                if idcError.code == .noPendingEvents {
                    UIAlertController.showToast(viewController: self?.navigationController,
                                                title: NSLocalizedString("fetch_alert_title", comment: ""),
                                                message: idcError.localizedDescription)
                } else {
                    UIAlertController.showErrorAlert(viewController: self?.navigationController,
                                                     error: error!)
                }
            }
        })
    }
    
    @objc internal func unenroll(_ button: UIBarButtonItem) {
        // Execute the unenroll use-case.
        
        // Initialize an instance of the Unenroll use-case.
        unenrollObj = Unenroll()
        unenrollObj.execute(progress: { [weak self] (progress) in
            if let aView = self?.view {
                ProgressHud.showProgress(forView: aView, progress: progress)
            }
        }, completion: { [weak self] (error) in
            if error == nil {
                SamplePersistence.setEnrolled(false)
                UIAlertController.showToast(viewController: self?.navigationController,
                                            title: NSLocalizedString("unenroll_alert_title", comment: ""),
                                            message: NSLocalizedString("unenroll_alert_message", comment: "")) {
                    let vc = AppDelegate.enrollViewHierarchy()
                    AppDelegate.switchWindowRootViewController(vc)
                }
            } else {
                UIAlertController.showErrorAlert(viewController: self?.navigationController,
                                                 error: error!) { (okAction) in
                    if error?.code == IDCError.userNotEnrolled.rawValue {
                        let vc = AppDelegate.enrollViewHierarchy()
                        AppDelegate.switchWindowRootViewController(vc)
                    }
                }
            }
        })
    }
    
    // MARK: Layout
    
    private func setupLayout() {
        guard authenticateButton.translatesAutoresizingMaskIntoConstraints,
              descriptionLabel.translatesAutoresizingMaskIntoConstraints else {
            return
        }
                
        view.addSubview(authenticateButton)
        authenticateButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authenticateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authenticateButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -8.0)
        ])
        
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 8.0),
            descriptionLabel.leadingAnchor.constraint(equalTo:view.readableContentGuide.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo:view.readableContentGuide.trailingAnchor)
        ])
    }
}
