//
//
// Copyright © 2020-2022 THALES. All rights reserved.
//

//
//  EnrollViewController.swift
//  idcloudclientsample
//

import UIKit
import IdCloudClientUi
import IdCloudClient

class EnrollViewController: UIViewController {
    private let enrollButton: UIButton = UIButton(type: .system)
    private let descriptionLabel: UILabel = UILabel()
    private var enrollObj: Enroll!
    private var secureLogObj : SecureLogArchive!
    
    let semaphore = DispatchSemaphore(value: 0)

    // IdCloud FIDO UI SDK provides a conformer to the necessary delegates of IdCloud FIDO SDK
    // providing integrators with a convenient way of exploring the use-cases available.
    let clientConformer = ClientConformer()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //Init navigation bar to add action button for sending log files.
        initNavBar()
        
        view.backgroundColor = UIColor.extBackground
        
        enrollButton.setTitle(NSLocalizedString("enroll_button_title", comment: ""), for: .normal)
        enrollButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        enrollButton.addTarget(self, action: #selector(enroll(_:)), for: .touchUpInside)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = NSLocalizedString("enroll_instruction", comment: "")
        
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(self.handleUserActivityEnroll(_:)), name: AppLinksConstants.didContinueUserActivity, object: nil)
        
        if !SamplePersistence.isEulaAccepted {
            showEulaPrompt()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: AppLinksConstants.didContinueUserActivity, object: nil)
        super.viewWillDisappear(animated)
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

    @objc internal func enroll(_ button: UIButton) {
        // Execute the enrollment use-case.
        // Ensure that this use-case is first initiated on the server to have a QR code ready.
        
        // A dispatch semaphore pattern is used to enable a simple chaining of interdependent
        // asynchronous calls.
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var qrCode: String?
            var error: IDCError?
            var qrVC: QRScannerViewController!
            
            DispatchQueue.main.async {
                // For convenience, a QR Scanner is provided to retrieve the enrollmentToken.
                qrVC = QRScannerViewController { (aCode) in
                    qrCode = aCode
                    self?.semaphore.signal()
                }
                self?.present(qrVC, animated: true, completion: nil)
            }
            self?.semaphore.wait()
            
            guard let clientConformer = self?.clientConformer,
                  let enrollmentToken = qrCode else {
                return
            }
            
            // Initialize an instance of the Enroll use-case, providing
            // (1) the retrieved code
            // (2) the uiDelegates
#if GETTING_STARTED
            self?.enrollObj = Enroll(code: enrollmentToken, uiDelegates: clientConformer)
#elseif ADVANCED
            self?.enrollObj = EnrollWithPush(code: enrollmentToken, uiDelegates: clientConformer)
#endif

            self?.enrollObj.execute(progress: { (progress) in
                if let aView = self?.view {
                    ProgressHud.showProgress(forView: aView, progress: progress)
                }
            }, completion: { (anError) in
                error = anError
                self?.semaphore.signal()
            })
            self?.semaphore.wait()

            DispatchQueue.main.async {
                self?.completeEnrollment(error: error)
            }
        }
    }

    @objc internal func handleUserActivityEnroll(_ notification: Notification) {
        guard let enrollmentToken = notification.object as? String,
              !SamplePersistence.isEnrolled else {
            return
        }
        // Initialize an instance of the Enroll use-case, providing
        // (1) the retrieved code
        // (2) the uiDelegates
#if GETTING_STARTED
        enrollObj = Enroll(code: enrollmentToken, uiDelegates: clientConformer)
#elseif ADVANCED
        enrollObj = EnrollWithPush(code: enrollmentToken, uiDelegates: clientConformer)
#endif

        enrollObj.execute(progress: { [weak self] (progress) in
            if let aView = self?.view {
                ProgressHud.showProgress(forView: aView, progress: progress)
            }
        }, completion: { [weak self] (error) in
            self?.completeEnrollment(error: error)
        })
    }

    // MARK: Convenience Methods
    
    private func showSuccessFlow() {
        let vc = AppDelegate.mainViewHierarchy()
        AppDelegate.switchWindowRootViewController(vc)
    }

    private func completeEnrollment(error: IDCError?) {
        // Remove all views displayed by the IdCloud FIDO UI SDK.
        navigationController?.popViewController(animated: true)
        if let error = error {
            UIAlertController.showErrorAlert(viewController: navigationController,
                                             error: error)
        } else {
            // A simple caching mecahnism for future app cycles to determine if the user was
            // previously enrolled.
            // This should be properly managed and stored.
            SamplePersistence.setEnrolled(true)

            // Display the result of the use-case and proceed accoridngly.
            UIAlertController.showToast(viewController: navigationController,
                                        title: NSLocalizedString("enroll_alert_title", comment: ""),
                                        message: NSLocalizedString("enroll_alert_message", comment: "")) { [weak self] in
                self?.showSuccessFlow()
            }
        }
    }
    
    private func showEulaPrompt() {
        let alertController = UIAlertController(title: NSLocalizedString("eula_title", comment: ""),
                                                message: NSLocalizedString("eula_message", comment: ""),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("alert_cancel", comment: ""), style: .destructive) { _ in
            fatalError()
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("eula_proceed", comment: ""), style: .default) { _ in
            SamplePersistence.setEulaAccepted(true)
            let url = URL(string: EULA_URL)!
            UIApplication.shared.open(url)
        })
                                  
        present(alertController, animated: true, completion: nil)
    }

    
    // MARK: Layout
    
    private func setupLayout() {
        guard enrollButton.translatesAutoresizingMaskIntoConstraints,
              descriptionLabel.translatesAutoresizingMaskIntoConstraints else {
            return
        }
                
        view.addSubview(enrollButton)
        enrollButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            enrollButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enrollButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -8.0)
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
