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
    
    
    var photo: Data?
    var previewPhoto: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showPreview()
        
        for i in 1...50{
            let button = UIButton()
            button.setBackgroundImage(UIImage(named: "TestButton"), for: .normal)
            button.setBackgroundImage(UIImage(named: "TestButtonChecked"), for: .highlighted)
           
            //button.frame.size = CGSize(width: 100, height: 100)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
