//
//  PopUpVC.swift
//  TestingCamera
//
//  Created by Nin Sreynuth on 7/2/24.
//

import UIKit
import PhotosUI



class PopUpVC: UIViewController{
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    
    var draftDocumentCompletion     = { }
    var externalDocumentCompletion  = { }
    var attachmentCompletion        = { }
    
    var arrayMenu                   = [String]()
    var arrayIconImage              = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        arrayMenu = ["Choose from allary", "Take a photo"]
        arrayIconImage = ["gallery_ico_sheet","camera_ico_sheet"]
        
        tableView.delegate      = self
        tableView.dataSource    = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.tableViewBottom.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func dismissButtonClicked(_ sender: Any) {
        self.back()
    }
}
extension PopUpVC{
    func back(completion: @escaping Completion = { }) {
        UIView.animate(withDuration: 0.2, animations: {
            let countMenu = CGFloat(self.arrayMenu.count)
            self.tableViewBottom.constant = -(50 * countMenu + 56)
            self.view.layoutIfNeeded()
        }) { _ in
            self.dismiss(animated: true)
            completion()
        }
    }
}

extension PopUpVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectOptionTVC", for: indexPath) as! selectOptionTVC
        cell.img.image = UIImage(named: arrayIconImage[indexPath.row])
        cell.titleText.text = arrayMenu[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! selectOptionTVC
        cell.contentView.backgroundColor = .white
        switch indexPath.row {
        case 0:
            self.back {
                self.attachmentCompletion()
            }
        case 1:
            self.back {
                self.draftDocumentCompletion()
            }
        default:
            break
        }

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let selectedCell = tableView.dequeueReusableCell(withIdentifier: "selectOptionTVC", for: indexPath) as! selectOptionTVC
        selectedCell.contentView.backgroundColor    = .white
        selectedCell.titleText.textColor           = .red
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! selectOptionTVC
        selectedCell.contentView.backgroundColor    = .white
        selectedCell.titleText.textColor           = .gray
    }
}

