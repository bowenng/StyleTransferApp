//
//  ImageViewController.swift
//  CameraTutorial
//
//  Created by 吴博闻 on 4/22/19.
//  Copyright © 2019 None. All rights reserved.
//

import UIKit
import AVFoundation

class ImageViewController: UIViewController {

    
    @IBOutlet weak var imagePreview: UIImageView!
    
    @IBOutlet weak var styleStackView: UIStackView!
    @IBAction func goToCamera(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    let styles = ImageData()
    
    var photo: Data?
    var previewPhoto: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showPreview()
        
        for i in 1...50{
            let button = UIButton()
            button.setImage(UIImage(named: "image640"), for: .normal)
            
            button.setImage(UIImage(named: "TestButtonChecked"), for: .selected)
            button.tag = i
            button.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            //button.frame.size = CGSize(width: 100, height: 100)
            button.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
            button.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
            
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
            button.layer.shadowOpacity = 1.0
            button.layer.shadowRadius = 10
            button.layer.masksToBounds = false
            button.layer.cornerRadius = 10.0
            
            
            button.addTarget(self, action: #selector(self.selectStyle(_:)), for: .touchUpInside)
            

            styleStackView.addArrangedSubview(button)
        }
        
    }
    
    private func showPreview() {
        guard let photo = self.photo else {
            print("No available preview.")
            return
        }
        
        self.imagePreview.image = UIImage(data: photo)
    }
    
    @objc private func selectStyle(_ sender: UIButton){
        print(sender.tag)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
