//
//  CustomAppClientConformer.swift
//  Advanced
//
//

import UIKit
import IdCloudClient
import IdCloudClientUi

class CustomAppClientConformer: ClientConformer {
    override func idCloudClient(_ idCloudClient: IDCIdCloudClient, transactionConfirmation: IDCTransactionContext, proceedHandler: @escaping () -> Void, cancelHandler: @escaping () -> Void) {
        let transactionDetails = transactionConfirmation.transactionDetails
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
