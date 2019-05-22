//
//  TakePhotoViewController.swift
//  CustomCamera
//
//  Created by Stephen Bassett on 5/18/19.
//  Copyright © 2019 Stephen Bassett. All rights reserved.
//

import AVFoundation
import UIKit

class TakePhotoViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet private var camPreview: UIView!
    @IBOutlet var takePhotoButton: UIButton!
    @IBOutlet var imageThumbnailButton: UIButton!
    
    // MARK: Variables
    
    let captureSession = AVCaptureSession()
    var photoOutput = AVCapturePhotoOutput()
    var activeInput: AVCaptureDeviceInput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var capturedImage: Data?
    var isSessionSetup = false
    
    // MARK: App Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isSessionSetup {
            if setupSession() {
                self.setupPreview()
                self.startSession()
            }
        } else {
            if !captureSession.isRunning {
                self.startSession()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.captureSession.isRunning {
            self.stopSession()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.takePhotoButton.layer.cornerRadius = self.takePhotoButton.frame.width / 2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCapturedImage" {
            let destinationVC = segue.destination as! CapturedImageViewController
            destinationVC.capturedImage = sender as? Data
        }
    }
    
    // MARK: Actions

    @IBAction func takePhotoButtonTapped(_ sender: Any) {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = AVCaptureDevice.FlashMode.auto
        self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @IBAction func imageThumbnailButtonTapped(_ sender: Any) {
        guard let capturedImage = self.capturedImage else { return }
        performSegue(withIdentifier: "toCapturedImage", sender: capturedImage)
    }

    // MARK: Private Functions
    
    private func startSession() {
        DispatchQueue.main.async {
            self.captureSession.startRunning()
        }
    }
    
    private func stopSession() {
        DispatchQueue.main.async {
            self.captureSession.stopRunning()
        }
    }
    
    private func setupSession() -> Bool {
        self.captureSession.beginConfiguration()
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let camera = AVCaptureDevice.default(for: AVMediaType.video)!
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
                self.activeInput = input
            } else {
                print("was not able to add input device")
                self.captureSession.commitConfiguration()
                return false
            }
        } catch {
            print("was not able to add input device")
            self.captureSession.commitConfiguration()
            return false
        }
        
        if self.captureSession.canAddOutput(self.photoOutput) {
            self.captureSession.addOutput(self.photoOutput)
            self.photoOutput.isHighResolutionCaptureEnabled = true
        } else {
            print("failed to create photo output")
            self.captureSession.commitConfiguration()
            return false
        }
        
        self.captureSession.commitConfiguration()
        self.isSessionSetup = true
        
        return true
    }
    
    private func setupPreview() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer.frame = self.camPreview.bounds
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.camPreview.layer.addSublayer(self.previewLayer)
    }
}

extension TakePhotoViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Error in capture process: \(String(describing: error))")
            return
        }
        guard let imageData = photo.fileDataRepresentation() else {
            print("Unable to create image data")
            return
        }
        self.capturedImage = imageData
        self.imageThumbnailButton.setBackgroundImage(UIImage(data: imageData), for: .normal)
        
    }
    
}
