//
//  PreviewVC.swift
//  TestingCamera
//
//  Created by Nin Sreynuth on 9/2/24.
//

import UIKit

protocol SelectedImageDelegate : AnyObject{
    func didFinishSelectionImage(imageData: Data) -> Void
}
class PreviewVC: UIViewController {
    
    var tempImage = UIImage()
    
    var isFirst = true
    
    var delegate: SelectedImageDelegate?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = tempImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retakeButton.setTitle("Retake", for: .normal)
        confirmButton.setTitle("Confirm", for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate = nil
    }
    
    @IBAction func reTalk(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func rotate(_ sender: Any) {
        isFirst = false
        imageView.image = imageView.image?.fixedOrientation().rotate(degrees: isFirst ? 180 : 90)
    }
    
    @IBAction func doneBtn(_ sender: Any) {
        if let sourceImage = imageView.image {
            var normalizeImage: UIImage?
            if (sourceImage.imageOrientation == .up ) {
                normalizeImage = sourceImage
            }
            else {
                UIGraphicsBeginImageContextWithOptions(sourceImage.size, false, (sourceImage.scale))
                sourceImage.draw(in: CGRect(x: 0, y: 0, width: (sourceImage.size.width), height: (sourceImage.size.height)))
                let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                normalizeImage = normalizedImage
            }
            
            let img = normalizeImage!.fixedOrientation()
            
            // resize image
            let resizeImage = UIImage.resizingImage(image: img, toType: .SD)
            
            // compress SD image size by 50%
            let imageData = resizeImage.jpegData(compressionQuality: 0.5)!
            
            self.delegate?.didFinishSelectionImage(imageData: imageData)
        }
        
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)

    }
    
    
}
extension UIImage {
    public func rotate(degrees: CGFloat) -> UIImage {
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        
        UIGraphicsBeginImageContext(rotatedSize)
        
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }

}
