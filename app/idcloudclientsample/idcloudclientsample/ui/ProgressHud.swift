//
//
// Copyright © 2020 THALES. All rights reserved.
//

//
//  ProgressHud.swift
//  idcloudclientsample
//
//

import UIKit
import IdCloudClient

class ProgressHud {
    static private var progressHudView: ProgressHudView?

    static func showProgress(forView view: UIView, progress: IDCProgress) {
        progressHudView?.removeFromSuperview()
        progressHudView = ProgressHudView(text: ProgressHud.stringForProgress(progress))
        if progressHudView != nil {
            view.addSubview(progressHudView!)
        }
        
        if progress == .end {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                hide()
            }
        }
    }

    static func hide() {
        progressHudView?.removeFromSuperview()
    }
    
    private static func stringForProgress(_ progress: IDCProgress) -> String {
        switch progress {
        case .start:
            return NSLocalizedString("progress_start", comment: "")
        case .sendingRequest:
            return NSLocalizedString("progress_sending_request", comment: "")
        case .retrievingRequest:
            return NSLocalizedString("progress_retrieving_request", comment: "")
        case .processingRequest:
            return NSLocalizedString("progress_processing_request", comment: "")
        case .validatingAuthentication:
            return NSLocalizedString("progress_validating_authentication", comment: "")
        case .end:
            return NSLocalizedString("progress_end", comment: "")
        @unknown default:
            fatalError("unsupported progress")
        }
    }
}

class ProgressHudView: UIVisualEffectView {
    private var text: String? {
        set {
            label.text = newValue
        }
        get {
            return label.text
        }
    }
    
    private let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    private let label: UILabel = UILabel()
    private let blurEffect = UIBlurEffect(style: .light)
    private let vibrancyView: UIVisualEffectView
    
    init(text: String) {
        vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.text = text
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)
        text = ""
        setup()
    }
    
    private func setup() {
        contentView.addSubview(vibrancyView)
        contentView.addSubview(activityIndictor)
        contentView.addSubview(label)
        activityIndictor.startAnimating()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = superview {
            let height: CGFloat = 80.0
            
            let activityIndicatorSize: CGFloat = 40
            activityIndictor.frame = CGRect(x: 5,
                                            y: height / 2 - activityIndicatorSize / 2,
                                            width: activityIndicatorSize,
                                            height: activityIndicatorSize)
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            label.text = text
            label.textAlignment = NSTextAlignment.center
            label.textColor = UIColor.gray
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.sizeToFit()
            label.frame = CGRect(x: activityIndicatorSize + 5,
                                 y: 0,
                                 width: label.frame.width,
                                 height: height)
            let width =  5 + activityIndicatorSize + 5 + label.frame.width + 5
            frame = CGRect(x: superview.frame.size.width / 2 - width / 2,
                           y: superview.frame.height / 2 - height / 2,
                           width: width,
                           height: height)
            vibrancyView.frame = bounds
        }
    }
    
    func show() {
        isHidden = false
    }
    
    func hide() {
        isHidden = true
    }
}
