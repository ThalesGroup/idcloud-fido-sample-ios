//
//  QRScannerViewController.swift
//  idcloudclientsample
//

import UIKit
import AVFoundation

class QRScannerViewController: UIViewController {
    typealias CompletionHandler = ((String?) -> ())
    
    private let captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var qrCodeFrameView = UIView()
    private var qrString: String?
    
    var completionHandler: CompletionHandler?

    init(completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupQr()
        
        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView.layer.borderWidth = 2
        
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
        
    
    // MARK: Setup
    
    private func setupQr() {
        guard let captureDevice = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: captureDevice),
            captureSession.canAddInput(input) else {
            return
        }
        
        captureSession.addInput(input)
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(captureMetadataOutput) == false {
            return
        }
        
        captureSession.addOutput(captureMetadataOutput)
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [.qr] // Simplified syntax

        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
    }
    
    private func setupLayout() {
        guard qrCodeFrameView.translatesAutoresizingMaskIntoConstraints else {
            return
        }
        
        view.addSubview(qrCodeFrameView)
        view.bringSubviewToFront(qrCodeFrameView)
        qrCodeFrameView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            qrCodeFrameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            qrCodeFrameView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            qrCodeFrameView.heightAnchor.constraint(equalTo: qrCodeFrameView.widthAnchor),
            qrCodeFrameView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75)
        ])
        
    }
}

extension QRScannerViewController : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        guard let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let barCodeObject = videoPreviewLayer.transformedMetadataObject(for: metadataObj),
            metadataObj.type == .qr else {
                return
        }
        qrCodeFrameView.frame = barCodeObject.bounds
        qrString = metadataObj.stringValue
        completionHandler?(qrString)
    }
}
