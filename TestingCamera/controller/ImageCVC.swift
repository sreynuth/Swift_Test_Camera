//
//  ImageCVC.swift
//  TestingCamera
//
//  Created by Nin Sreynuth on 7/2/24.
//

import UIKit

typealias DeleteImage = ()-> Void
class ImageCVC: UICollectionViewCell {
    var imagePicker: Completion        = {}
    var deleteImage: DeleteImage       = {}
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var cancleBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    func configure(with image: UIImage) {
        img.image = image
    }
    
    @IBAction func deleteImage(_ sender: Any) {
        deleteImage()
    }
    
}
