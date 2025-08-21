//
//  ViewController.swift
//  TestingCamera
//
//  Created by Nin Sreynuth on 6/2/24.
//

import UIKit
import AVFoundation
import PhotosUI

class ViewController: UIViewController{
    
    var imagePicker                     : Completion        = {}
    var deleteImage                     : DeleteImage       = {}
    var imageView                       : UIImage?
    var photo                           : [UIImage]         = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.dataSource   = self
        collectionView.delegate     = self
    }

    @IBAction func cameraBtn(_ sender: Any) {
        self.selectImage()
    }
    

}

extension ViewController{
    func openCamera() {
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let vc = self.VC(sbName: "CameraViewSB", identifier: "CameraVC") as! CameraVC
                vc.viewController = self
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func pickUp(){
        var config = PHPickerConfiguration()
        config.selectionLimit = 10
        
        let phPicker = PHPickerViewController(configuration: config)
        phPicker.delegate = self
        self.present(phPicker, animated: true)
    }
    
    func openGallery() {
        pickUp()
    }
    func selectImage() {
        self.showImageSourceOption(camera: {
            self.openCamera()
        }) {
            self.openGallery()
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCVC", for: indexPath) as! ImageCVC
        let image = self.photo[indexPath.row] // Assuming photo array holds the images
        cell.configure(with: image)
        cell.deleteImage = { [weak self] in
            self?.photo.remove(at: indexPath.row)
            collectionView.reloadData()
        }
        return cell
    }
}

extension ViewController : SelectedImageDelegate{
    
    
    func didFinishSelectionImage(imageData: Data) {
        
        let imgData = UIImage(data: imageData)?.jpegData(compressionQuality: 0.8)
        self.imageView = UIImage(data: imgData!)
    }
}

extension ViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage{
                    self.photo.append(image)
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

