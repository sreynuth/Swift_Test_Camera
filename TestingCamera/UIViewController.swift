//
//  UIViewController.swift
//  TestingCamera
//
//  Created by Nin Sreynuth on 12/2/24.
//

import UIKit
import AVFoundation
import Photos

typealias Completion                = ()                -> Void
typealias Completion_Int            = (Int)             -> Void
typealias Completion_Bool           = (Bool)            -> Void
typealias Completion_NSError        = (NSError?)        -> Void
typealias Completion_String         = (String)          -> Void
typealias Completion_String_String  = (String, String)  -> Void

typealias Completion_String_Error   = (String, Error?)  -> Void

extension UIViewController {
    
    func showImageSourceOption(camera:(()->Void)?, gallery:(()->Void)?) {
        let vc = PopupVC(storyboard: "PopUpSB", identifier: "PopUpVC") as! PopUpVC
        
        // when user choose to Take a photo
        vc.draftDocumentCompletion = { [weak self] in
            self?.openCamera {
                camera?()
            }
        }
        
        // when user chosse to select image from Gallery
        vc.attachmentCompletion = { [weak self] in
            self?.openAlbum {
                gallery?()
            }
        }
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func PopupVC(storyboard: String, identifier: String) -> UIViewController {
        let vc = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: identifier)
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.providesPresentationContextTransitionStyle = true
        vc.definesPresentationContext = true
        
        return vc
    }
    
    func openCamera(cameraBlock:(()->Void)?) {
        let MESSAGE_CAMERA      = "unable_to_take_a_photo"
        
        if(UIImagePickerController.isSourceTypeAvailable(.camera))
        {
            self.checkAllowCameraPermission { (status) in
                if status {
                    cameraBlock?()
                }
                else {
                    self.alertYesNo(title: "", message: MESSAGE_CAMERA, nobtn: "close", yesbtn: "confirm") { (yes) in
                        if yes {
                            self.openCamera(cameraBlock: cameraBlock)
                        }
                    }
                }
            }
            
        }
    }
    
    func openAlbum(albumBlock:(()->Void)?) {
        
        let MESSAGE_PHOTO_ALBUM = "unable_to_attach_an_image"
        
        self.checkAllowPhotoPermission { (status) in
            if status {
                albumBlock?()
            }
            else {
                self.alertYesNo(title: "", message: MESSAGE_PHOTO_ALBUM, nobtn: "close", yesbtn: "confirm") { (yes) in
                    if yes {
                        self.gotoAppSettings()
                    }
                }
            }
        }
    }
    
    
    func checkAllowPhotoPermission(completion: @escaping Completion_Bool) {
        if (PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized) {
            DispatchQueue.main.async {
                completion(true)
            }
        }
        else if (PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.notDetermined) {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            })
        }
        else {
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
    
    
    func checkAllowCameraPermission(completion: @escaping Completion_Bool) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            DispatchQueue.main.async {
                completion(true)
            }
        default:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) -> Void in
                DispatchQueue.main.async {
                    completion(granted)
                }
            })
        }
    }
    
    func alertYesNo(title: String, message: String, nobtn: String = "NO".capitalized, yesbtn: String = "YES".capitalized
                    , completion: @escaping Completion_Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(title: yesbtn, style: .default, handler: { (action) -> Void in
                completion(true)
            })
        )
        alert.addAction(
            UIAlertAction(title: nobtn, style: .cancel)
        )
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func gotoAppSettings() {
        if #available(iOS 10.0, *) {
            DispatchQueue.main.async {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    func VC(sbName: String, identifier: String) -> UIViewController {
        return UIStoryboard(name: sbName, bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    
}
