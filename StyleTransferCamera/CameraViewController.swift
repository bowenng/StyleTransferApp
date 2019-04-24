//
//  ViewController.swift
//  CameraTutorial
//
//  Created by 吴博闻 on 4/21/19.
//  Copyright © 2019 None. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    @IBOutlet weak var previewView: PreviewView!
    
    @IBAction func capturePhoto(_ sender: UIButton) {
        //align output orientation to that of preview
        let videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection?.videoOrientation
        
        if let photoOutputConnection = self.photoOutput.connection(with: .video) {
            photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
        }
        
        var photoSettings = AVCapturePhotoSettings()
        
        //change to jpeg format, if availale
        if photoOutput.availablePhotoCodecTypes.contains(.jpeg){
            print("Contains jpg")
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])
        }
        
        photoSettings.flashMode = .auto
        
        if !photoSettings.availablePreviewPhotoPixelFormatTypes.isEmpty{
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String : photoSettings.availablePreviewPhotoPixelFormatTypes.first!]
        } else {
            print("Empty Preview")
        }
        
//        let photoCaptureProcessor = PhotoCaptureProcessor(willCaptureAnimation: {
//            // Flash the screen to signal that AVCam took a photo.
//            DispatchQueue.main.async {
//                self.previewView.videoPreviewLayer.opacity = 0
//                UIView.animate(withDuration: 0.25) {
//                    self.previewView.videoPreviewLayer.opacity = 1
//                }
//            }
//        }, finishCaptureSegue: {DispatchQueue.main.async {
//            self.performSegue(withIdentifier: "toImageView", sender: self)
//            }})
        
        
        
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        
        print("Here")
       
        
        if let previewPhoto = self.previewPhoto {
            print("Preview Found")
            self.previewPhoto = previewPhoto
        }
        
        if let photo = self.photo {
            print("Photo Found")
            self.photo = photo
        }
        
        //performSegue(withIdentifier: "toImageView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toImageView":
            print("Success Prepare")
            let imageViewController = segue.destination as! ImageViewController
            if let photo = self.photo{
                imageViewController.photo = photo
            }
            if let previewPhoto = self.previewPhoto{
                imageViewController.previewPhoto = previewPhoto
            }
        default:
            print("Failed To Perform Segue!")
        }
    }
    
    @IBOutlet weak var shootButton: UIButton!
    
    private var photo: Data?
    private var previewPhoto: UIImage?
    
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    
    private let sessionQueue = DispatchQueue(label: "session queue") // Communicate with the session and other session objects on this queue.
    
    private var setupResult: SessionSetupResult = .success
    
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    private let photoOutput = AVCapturePhotoOutput()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        disableButtons()
        setuptPreview()
        checkAuthorization()
        
        sessionQueue.async {
            if self.setupResult == .success{
                self.configureCamera()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sessionQueue.async {
            //try to start the program, fail if setupResult != .success
            self.startCamera()
            DispatchQueue.main.async {
                self.enableButtons()
            }
        }
    }
    
    
    private func configureCamera(){

            session.beginConfiguration()
            
            
            setupInputs()
            setupOutput()
            
            session.commitConfiguration()
        
    }
    
    private func setupInputs(){
        //Input
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video, position: .unspecified)
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            session.canAddInput(videoDeviceInput)
            else { return }
        self.videoDeviceInput = videoDeviceInput
        session.addInput(videoDeviceInput)
    }
    
    private func setupOutput(){
        //output
        session.sessionPreset = .medium
        guard session.canAddOutput(photoOutput) else {
            print("Unable to add output!")
            return
            
        }
        
        session.addOutput(photoOutput)
    }
    
    private func setuptPreview(){
        previewView.session = session
        previewView.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }
    
    private func disableButtons(){
        self.shootButton.isEnabled = false
    }
    
    private func enableButtons(){
        self.shootButton.isEnabled = true
    }
    
    private func checkAuthorization(){
        //check Authorization
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
        
        
    }
    
    private func startCamera(){
        switch self.setupResult {
        case .success:
            // Only setup observers and start the session running if setup succeeded.
            //self.addObservers()
            self.session.startRunning()
            self.isSessionRunning = self.session.isRunning
            
        case .notAuthorized:
            DispatchQueue.main.async {
                let changePrivacySetting = "AVCam doesn't have permission to use the camera, please change privacy settings"
                let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                        style: .cancel,
                                                        handler: nil))
                
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                                        style: .`default`,
                                                        handler: { _ in
                                                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                                                                      options: [:],
                                                                                      completionHandler: nil)
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
            
        case .configurationFailed:
            DispatchQueue.main.async {
                let alertMsg = "Alert message when something goes wrong during capture session configuration"
                let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                        style: .cancel,
                                                        handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

enum SessionSetupResult {
    case success
    case notAuthorized
    case configurationFailed
}


extension CameraViewController: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("animated")
        
            // Flash the screen to signal that AVCam took a photo.
            DispatchQueue.main.async {
                self.previewView.videoPreviewLayer.opacity = 0
                UIView.animate(withDuration: 0.25) {
                    self.previewView.videoPreviewLayer.opacity = 1
                }
            }
            
        
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let e = error{
            print("\(e.localizedDescription)")
        }
        
        if let previewBuffer = photo.previewPixelBuffer{
            let previewCIImage = CIImage(cvPixelBuffer: previewBuffer)
            self.previewPhoto = UIImage(ciImage: previewCIImage)
            
            print("Did finish processing preview")
        }
        self.photo = photo.fileDataRepresentation()
        print("Did finish processsing photo")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toImageView", sender: self)
        }
    }
}
