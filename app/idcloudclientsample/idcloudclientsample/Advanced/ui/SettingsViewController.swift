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
                    self?.showAlert(withTitle: NSLocalizedString("alert_error_title", comment: ""),
                                    message: NSLocalizedString("enable_push_notification_from_settings_error", comment: ""),
                                    okAction: nil)
                }
            }
        }
    }
    
    // MARK: Notification Observers
    
    @objc private func refreshPushToken(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: PushNotificationConstants.didRegisterForRemoteNotificationsWithDeviceToken, object: nil)
        NotificationCenter.default.removeObserver(self, name: PushNotificationConstants.didFailToRegisterForRemoteNotificationsWithError, object: nil)
        
        guard let devicePushToken = notification.object as? String else {
            showAlert(withTitle: NSLocalizedString("alert_error_title", comment: ""),
                      message: NSLocalizedString("enable_push_notification_from_settings_error", comment: ""),
                      okAction: nil)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            // Initialize an instance of the Refresh Push Token use-case, providing
            // (1) the pre-configured URL
            // (2) the device push token
            self?.refreshPushTokenObj = RefreshPushToken(url: URL)
            self?.refreshPushTokenObj.execute(devicePushToken: devicePushToken,
                                              progress: { [weak self] (progress) in
                if let aView = self?.view {
                    ProgressHud.showProgress(forView: aView, progress: progress)
                }
            }, completion: { [weak self] error in
                if error == nil {
                    // Display the result of the use-case and proceed accordingly.
                    self?.showAlert(withTitle: NSLocalizedString("refresh_push_title", comment: ""),
                              message: NSLocalizedString("refresh_push_success", comment: ""),
                              okAction: nil)
                } else {
                    self?.showAlert(withTitle: NSLocalizedString("alert_error_title", comment: ""),
                              message: NSLocalizedString("refresh_push_fail", comment: ""),
                              okAction: nil)
                }
            })
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
}
