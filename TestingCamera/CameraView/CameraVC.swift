//
//  CameraVC.swift
//  TestingCamera
//
//  Created by Nin Sreynuth on 9/2/24.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController{
    
    var captureSession  = AVCaptureSession()
    var cameraOutput    = AVCapturePhotoOutput()
    var previewLayer    = AVCaptureVideoPreviewLayer()
    
    var input: AVCaptureDeviceInput?
    
    weak var viewController : ViewController?

    @IBOutlet weak var cancleBtn: UIButton!
    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var captureImageViews: UIImageView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let deviceSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        do {
            input = try AVCaptureDeviceInput(device: deviceSession.devices[0])
            if (captureSession.canAddInput(input!)) {
                captureSession.addInput(input!)
                captureSession.sessionPreset = AVCaptureSession.Preset.photo
                if (captureSession.canAddOutput(cameraOutput)) {
                    captureSession.addOutput(cameraOutput)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer.frame = uiView.bounds
                    previewLayer.videoGravity = .resizeAspect
                    uiView.layer.addSublayer(previewLayer)
                    captureSession.startRunning()
                }
            } else {
                #if DEBUG
                print("issue here : captureSesssion.canAddInput")
                #endif
            }
        } catch let avError {
            #if DEBUG
            print(avError)
            #endif
        }
        captureImageViews.isExclusiveTouch = true
        
        uiView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(tapOnCameraView(_:)))
        )
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cancleBtn.setTitle("Cancel", for: .normal)
        captureSession.startRunning()
        
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isStatusBarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = uiView.bounds
    }
    
    @objc func tapOnCameraView(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: self.uiView)
        let screenSize = uiView.bounds.size
        let focusPoint = CGPoint(x: touchPoint.y / screenSize.height, y: 1.0 - touchPoint.x / screenSize.width)

        if let device = input?.device {
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode            = AVCaptureDevice.FocusMode.autoFocus
                }
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest  = focusPoint
                    device.exposureMode             = AVCaptureDevice.ExposureMode.autoExpose
                }
                device.unlockForConfiguration()

            } catch {
                // Handle errors here
            }
        }
    }
    
    func didTapGestureImageView() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.__availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: captureImageViews.frame.width,
            kCVPixelBufferHeightKey as String: captureImageViews.frame.height
        ] as [String : Any]
        settings.previewPhotoFormat = previewFormat
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func captureDidTap(_ sender: UIButton) {
        didTapGestureImageView()
    }
    
    @IBAction func cancleButton(_ sender: Any) {
        captureSession.stopRunning()
        dismiss(animated: true, completion: nil)
    }
}
extension CameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            #if DEBUG
            print("error occure : \(error.localizedDescription)")
            #endif
        }
        
        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
            
            let vc = UIStoryboard(name: "CameraViewSB", bundle: nil).instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
            vc.tempImage = image
            
            if self.viewController != nil {
                vc.delegate = self.viewController
            }
            
            present(vc, animated: false, completion: nil)
            
        } else {
            #if DEBUG
            print("some error here") 
            #endif
        }
    }
}
