//
//  SettingsViewController.swift
//  Advanced
//
//

import UIKit
import IdCloudClient

fileprivate typealias TapClosure = () -> ()

fileprivate struct Section {
    let name: String
    let rows: [Row]
}

fileprivate struct Row {
    let name: String
    var tapClosure: TapClosure?
}

class SettingsViewController: UIViewController {
    private var refreshPushTokenObj: RefreshPushToken!

    private let tableView = UITableView()
    private let reuseIdentifier = "UITableViewCell"
    private var dataSource: [Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.extBackground
        title = NSLocalizedString("settings_title", comment: "")

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()

        prepareDataSource()
        setupLayout()
    }

    
    // MARK: Layout
    
    private func setupLayout() {
        guard tableView.translatesAutoresizingMaskIntoConstraints
            else {
                return
        }
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    // MARK: Data Source
    
    private func prepareDataSource() {
        dataSource = [
            Section(name: NSLocalizedString("version_title", comment: ""),
                    rows: [
                        Row(name: IDCIdCloudClient.sdkVersion())
                    ]),
            Section(name: NSLocalizedString("push_notifications_title", comment: ""),
                    rows: [
                        Row(name: NSLocalizedString("refresh_push_title", comment: ""),
                            tapClosure: { [weak self] in
                                self?.registerPushNotifications()
                            })
                    ]),
            Section(name: NSLocalizedString("others_title", comment: ""),
                    rows: [
                        Row(name: NSLocalizedString("get_client_id_title", comment: ""),
                            tapClosure: { [weak self] in
                                self?.getClientID()
                            })
                    ]),
        ]
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = dataSource[indexPath.section].rows[indexPath.row]
        switch row.name {
        case NSLocalizedString("refresh_push_title", comment: ""):
            registerPushNotifications()
        case NSLocalizedString("get_client_id_title", comment: ""):
            getClientID()
        default:
            break
        }
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].name
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let row = dataSource[indexPath.section].rows[indexPath.row]
        
        cell.textLabel?.text = row.name
        
        return cell
    }
}

extension SettingsViewController {
    // MARK: Private Methods
    private func registerPushNotifications() {
        // Trigger a push notification registration via the app.
        // Listen to the respective notifications in order to receive the device token.
        // This ensures that the device push token remains in-sync for out-of-band scenarios.
        PushNotificationManager.registerForPushNotifications { [unowned self] enableRemoteNotifications in
            if enableRemoteNotifications {
                // Add observers to set up deviceToken prior to Enroll.
                NotificationCenter.default.addObserver(self, selector: #selector(refreshPushToken(_:)), name: PushNotificationConstants.didRegisterForRemoteNotificationsWithDeviceToken, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(refreshPushToken(_:)), name: PushNotificationConstants.didFailToRegisterForRemoteNotificationsWithError, object: nil)
            } else {
                // Show error alert
                DispatchQueue.main.async { [weak self] in
                    UIAlertController.showAlert(viewController: self?.navigationController,
                                                title: NSLocalizedString("alert_error_title", comment: ""),
                                                message: NSLocalizedString("enable_push_notification_from_settings_error", comment: ""))
                }
            }
        }
    }

    private func getClientID() {
        // Fetches the client ID of the enrolled credential.
        let idcloudclient = try? IDCIdCloudClient(url: URL, tenantId: TENANT_ID)
        
        guard let clientID = idcloudclient?.clientID() else {
            return
        }

        UIAlertController.showToast(viewController: navigationController,
                                    title: NSLocalizedString("client_id_title", comment: ""),
                                    message: clientID)
    }
    
    // MARK: Notification Observers
    
    @objc private func refreshPushToken(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: PushNotificationConstants.didRegisterForRemoteNotificationsWithDeviceToken, object: nil)
        NotificationCenter.default.removeObserver(self, name: PushNotificationConstants.didFailToRegisterForRemoteNotificationsWithError, object: nil)
        
        guard let devicePushToken = notification.object as? String else {
            UIAlertController.showAlert(viewController: navigationController,
                                        title: NSLocalizedString("alert_error_title", comment: ""),
                                        message: NSLocalizedString("enable_push_notification_from_settings_error", comment: ""))
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            // Initialize an instance of the Refresh Push Token use-case, providing
            // (1) the device push token
            self?.refreshPushTokenObj = RefreshPushToken()
            self?.refreshPushTokenObj.execute(devicePushToken: devicePushToken,
                                              progress: { [weak self] (progress) in
                if let aView = self?.view {
                    ProgressHud.showProgress(forView: aView, progress: progress)
                }
            }, completion: { [weak self] error in
                if error == nil {
                    // Display the result of the use-case and proceed accordingly.
                    UIAlertController.showToast(viewController: self?.navigationController,
                                                title: NSLocalizedString("refresh_push_title", comment: ""),
                                                message: NSLocalizedString("refresh_push_success", comment: ""))
                } else {
                    UIAlertController.showToast(viewController: self?.navigationController,
                                                title: NSLocalizedString("alert_error_title", comment: ""),
                                                message: NSLocalizedString("refresh_push_fail", comment: ""))
                }
            })
        }
    }
}
