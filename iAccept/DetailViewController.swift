//
//  DetailViewController.swift
//  iAccept
//
//  Created by TapFreaks on 1/21/16.
//  Copyright © 2016 Mohammad Asif. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var labeLoadingImage:UILabel!
    @IBOutlet var labelName:UILabel!
    @IBOutlet var labelPosition:UILabel!
    @IBOutlet var imageViewLarge:UIImageView!
    
    var dModel:dataModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "Detail"
        
        if dModel != nil {
            self.labelName.text = dModel.name
            self.labelPosition.text = dModel.position
            
            if self.dModel.imageLarge != nil {
                self.imageViewLarge.image = self.dModel.imageLarge
                self.labeLoadingImage.hidden = true
            } else {
                
                if self.dModel.imageSmall != nil {
                    self.imageViewLarge.image = self.dModel.imageSmall
                }
                
                let sifImg = SifImageCache()
                sifImg.baseURL = "imageURL"
                sifImg.getImage(dModel.lrgpic) { (image: UIImage) in
                    self.dModel.imageLarge = image
                    self.imageViewLarge.image = self.dModel.imageLarge
                    
                    let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
                    dispatch_after(delay, dispatch_get_main_queue(), {
                        self.labeLoadingImage.hidden = true
                    })
                }
                
                self.labeLoadingImage.hidden = false
            }
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
