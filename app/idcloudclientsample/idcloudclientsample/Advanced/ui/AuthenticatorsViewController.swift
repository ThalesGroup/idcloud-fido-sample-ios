//
//  AuthenticatorsViewController.swift
//  Advanced
//

import UIKit
import IdCloudClient
import IdCloudClientUi

class AuthenticatorsViewController: UIViewController {
    private let tableView: UITableView = UITableView()
    private var authenticators: [IDCAuthenticator] = []
    private var activatedAuthenticatorsObj: ActivatedAuthenticators!
    
    private let reuseIdentifier = "UITableViewCell"
    private var addAuthenticatorObj: AddAuthenticator!
    private var removeAuthenticatorObj: RemoveAuthenticator!
    private var changePinObj:ChangePin!
    
    // IdCloud FIDO UI SDK provides a conformer to the necessary delegates of IdCloud FIDO SDK
    // providing integrators with a convenient way of exploring the use-cases available.
    let clientConformer = ClientConformer()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.extBackground
        title = NSLocalizedString("authenticators_title", comment: "")
        
        // Set up an instance of the ActivatedAuthenticators use-case to retreive a list of registered authenticators.
        activatedAuthenticatorsObj = ActivatedAuthenticators(url: URL)
        // Retreive a list of registered authenticators.
        authenticators = activatedAuthenticatorsObj.execute()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        
        let addAuthenticatorButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAuthenticator(_:)))
        navigationItem.setRightBarButton(addAuthenticatorButton, animated: false)
        
        toggleLeftBarButton(isEdit: true)
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
    
    @objc internal func addAuthenticator(_ button: UIBarButtonItem) {
        // Execute the add authenticator use-case.
        
        // Initialize an instance of the Add Authenticate use-case, providing
        // (1) the pre-configured URL
        // (2) the uiDelegates
        addAuthenticatorObj = AddAuthenticator(url: URL, uiDelegates: clientConformer)
        addAuthenticatorObj.execute(progress: { [weak self] (progress) in
            if let aView = self?.view {
                ProgressHud.showProgress(forView: aView, progress: progress)
            }
        }, completion: { [weak self] (error) in
            // Remove all views displayed by the IdCloud FIDO UI SDK.
            self?.navigationController?.popToRootViewController(animated: true)
            
            if error == nil {
                // Refresh Authenticators table view
                self?.refreshAuthenticatorsTable()
                
                // Display the result of the use-case and proceed accoridngly.
                UIAlertController.showToast(viewController: self?.navigationController,
                                            title: NSLocalizedString("addauthenticator_alert_title", comment: ""),
                                            message: NSLocalizedString("addauthenticator_alert_message", comment: ""))
            } else {
                UIAlertController.showErrorAlert(viewController: self?.navigationController,
                                                 error: error!)
            }
        })
    }
    
    @objc internal func edit(_ button: UIBarButtonItem) {
        toggleLeftBarButton(isEdit: false)
        tableView.setEditing(true, animated: true)
    }
    
    @objc internal func cancel(_ button: UIBarButtonItem) {
        toggleLeftBarButton(isEdit: true)
        tableView.setEditing(false, animated: true)
    }
    
    // MARK: Private Methods
    
    private func removeAuthenticator(authenticator: IDCAuthenticator) {
        // Execute the remove authenticator use-case.
        
        // Initialize an instance of the Remove Authenticate use-case, providing
        // (1) the pre-configured URL
        // (2) the authenticaor to be removed
        removeAuthenticatorObj = RemoveAuthenticator(url: URL, authenticator: authenticator)
        removeAuthenticatorObj.execute(progress: { [weak self] (progress) in
            if let aView = self?.view {
                ProgressHud.showProgress(forView: aView, progress: progress)
            }
        }, completion: {  [weak self] (error) in
            // Remove all views displayed by the IdCloud FIDO UI SDK.
            self?.navigationController?.popToRootViewController(animated: true)
            
            if error == nil {
                // Display the result of the use-case and proceed accoridngly.
                UIAlertController.showToast(viewController: self?.navigationController,
                                            title: NSLocalizedString("removeauthenticator_alert_title", comment: ""),
                                            message: NSLocalizedString("removeauthenticator_alert_message", comment: ""))
            } else {
                UIAlertController.showErrorAlert(viewController: self?.navigationController,
                                                 error: error!) { (okAction) in
                    // Refresh Authenticators table view
                    self?.refreshAuthenticatorsTable()
                }
            }
        })
    }
    
    private func changePin() {
        // Execute the change PIN use-case.
        
        // Initialize an instance of the Add Authenticate use-case, providing
        // (1) the pre-configured URL
        // (2) the pinPadUiDelegate
        changePinObj = ChangePin(url: URL, pinPadUiDelegate: clientConformer as IDCSecurePinPadUiDelegate)
        changePinObj.execute(progress: { [weak self] (progress) in
            if let aView = self?.view {
                ProgressHud.showProgress(forView: aView, progress: progress)
            }
        }, completion: { [weak self] (error) in
            // Remove all views displayed by the IdCloud FIDO UI SDK.
            self?.navigationController?.popToRootViewController(animated: true)
            
            if error == nil {
                // Display the result of the use-case and proceed accoridngly.
                UIAlertController.showToast(viewController: self?.navigationController,
                                            title: NSLocalizedString("changepin_alert_title", comment: ""),
                                            message: NSLocalizedString("changepin_alert_message", comment: ""))
            } else {
                UIAlertController.showErrorAlert(viewController: self?.navigationController,
                                                 error: error!)
            }
        })
    }
    
    // MARK: Helper Methods
    
    private func toggleLeftBarButton(isEdit: Bool) {
        var button: UIBarButtonItem
        if isEdit {
            button = UIBarButtonItem(title: NSLocalizedString("edit_button_title", comment: ""),
                                     style: .plain,
                                     target: self,
                                     action: #selector(edit(_:)))
        } else {
            button = UIBarButtonItem(title: NSLocalizedString("cancel_button_title", comment: ""),
                                     style: .plain,
                                     target: self,
                                     action: #selector(cancel(_:)))
        }
        navigationItem.leftBarButtonItem = button
    }
    
    private func refreshAuthenticatorsTable() {
        authenticators = activatedAuthenticatorsObj.execute()
        tableView.reloadData()
    }
    
    // MARK: Layout
    
    private func setupLayout() {
        guard tableView.translatesAutoresizingMaskIntoConstraints else {
            return
        }
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension AuthenticatorsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let authenticator = authenticators[indexPath.row]
        var actions: [UIAlertAction] = []
        switch authenticator.type {
        case .pin:
            let changePinAction = UIAlertAction(title: NSLocalizedString("actionsheet_change_pin", comment: ""), style: .default) { [weak self](action) in
                // Execute the change PIN use-case.
                self?.changePin()
            }
            actions.append(changePinAction)
        default:
            break
        }
        
        if actions.count == 0 {
            return
        }
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for action in actions {
            actionSheet.addAction(action)
        }
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("actionsheet_cancel", comment: ""), style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Execute remove authenticator and row deletion
            let authenticator = authenticators[indexPath.row]
            removeAuthenticator(authenticator: authenticator)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.tableView.setEditing(false, animated: true)
                self?.toggleLeftBarButton(isEdit: true)
                
                self?.authenticators.remove(at: indexPath.row)
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

extension AuthenticatorsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authenticators.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        let authenticator = authenticators[indexPath.row]
        
        var title: String!
        var image: UIImage!
        switch authenticator.type {
        case .biometric:
            title = NSLocalizedString("biometric_authenticator_title", comment: "")
            image = #imageLiteral(resourceName: "authenticator_biometric")
        case .pin:
            title = NSLocalizedString("pin_authenticator_title", comment: "")
            image = #imageLiteral(resourceName: "authenticator_pin")
        @unknown default:
            fatalError("Unsupported authenticator")
        }
        
        cell.textLabel?.text = title
        cell.imageView?.image = image
        
        return cell
    }
}
