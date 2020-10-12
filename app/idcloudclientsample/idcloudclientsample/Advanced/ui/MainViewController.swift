//
//  MainViewController.swift
//  Advanced
//

import UIKit
import IdCloudClientUi
import SSZipArchive

class MainViewController: UIViewController {
    private let authenticateButton: UIButton = UIButton(type: .system)
    private let descriptionLabel: UILabel = UILabel()
    private var authenticateObj: Authenticate!
    private var unenrollObj: Unenroll!
    private var secureLogObj : SecureLogArchive!
    
    // IdCloud FIDO UI SDK provides a conformer to the necessary delegates of IdCloud FIDO SDK
    // providing integrators with a convenient way of exploring the use-cases available.
    let clientConformer = ClientConformer()

    override public func viewDidLoad() {
        super.viewDidLoad()

        //Init navigation bar to add action button for sending log files.
        initNavBar()
        
        view.backgroundColor = UIColor.extBackground
        
        authenticateButton.setTitle(NSLocalizedString("authenticate_button_title", comment: ""), for: .normal)
        authenticateButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        authenticateButton.addTarget(self, action: #selector(authenticate(_:)), for: .touchUpInside)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = NSLocalizedString("authenticate_instruction", comment: "")
        
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
    
    private func initNavBar() {
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareLogFiles))
        navigationItem.setRightBarButton(shareButton, animated: false)
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
    
    
    // MARK: IBActions
    
    @objc internal func authenticate(_ button: UIButton) {
        // Execute the authentication use-case.
        // Ensure that this use-case is first initiated on the server generate a scenario.

        
        // Initialize an instance of the Authenticate use-case, providing
        // (1) the pre-configured URL
        // (2) the uiDelegates
        authenticateObj = Authenticate(url: URL, uiDelegates: clientConformer)
        authenticateObj.execute { [weak self] (progress) in
            if let aView = self?.view {
                ProgressHud.showProgress(forView: aView, progress: progress)
            }
        } completion: { [weak self] (error) in
            // Remove all views displayed by the IdCloud FIDO UI SDK.
            self?.navigationController?.popToRootViewController(animated: true)
            
            if error == nil {
                // Display the result of the use-case and proceed accoridngly.
                self?.showAlert(withTitle: NSLocalizedString("authenticate_alert_title", comment: ""), message: NSLocalizedString("authenticate_alert_message", comment: ""), okAction: nil)
            } else {
                self?.showAlert(withTitle: NSLocalizedString("alert_error_title", comment: ""), message: error!.localizedDescription, okAction: nil)
            }
        }
    }
    
    @objc internal func unenroll(_ button: UIBarButtonItem) {
        // Execute the unenroll use-case.
        
        // Initialize an instance of the Unenroll use-case, providing
        // (1) the pre-configured URL
        unenrollObj = Unenroll(url: URL)
        unenrollObj.execute { [weak self] (error) in
            if error == nil {
                SamplePersistence.setEnrolled(false)
                self?.showAlert(withTitle: NSLocalizedString("unenroll_alert_title", comment: ""), message: NSLocalizedString("unenroll_alert_message", comment: "")) { (okAction) in
                    let vc = AppDelegate.enrollViewHierarchy()
                    AppDelegate.switchWindowRootViewController(vc)
                }
            } else {
                self?.showAlert(withTitle: NSLocalizedString("alert_error_title", comment: ""), message: error!.localizedDescription, okAction: nil)
            }
        }
    }
    
    // MARK: Convenience Methods
    
    private func showAlert(withTitle title: String, message: String, okAction: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("alert_ok", comment: ""), style: .default, handler: okAction))
        navigationController?.present(alertController, animated: true, completion: nil)
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
