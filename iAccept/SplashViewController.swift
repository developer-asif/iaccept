//
//  ViewController.swift
//  iAccept
//
//  Created by TapFreaks on 1/21/16.
//  Copyright © 2016 Mohammad Asif. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet var labelAppTitle:UILabel!
    @IBOutlet var labelAppSubTitle:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.performSelector("animateView", withObject: nil, afterDelay: 1.2)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func animateView()  {
        UIView.animateWithDuration(0.5, animations: {
            self.labelAppTitle.alpha = 0.1
            self.labelAppSubTitle.alpha = 0.1
        }, completion: { (completed:Bool) in
            UIView.animateWithDuration(0.5, animations: {
                
                self.labelAppTitle.alpha = 1
                self.labelAppSubTitle.alpha = 1
                self.labelAppTitle.textColor = UIColor.redColor()

                }, completion: { (completed:Bool) in
                    
                    let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC)))
                    dispatch_after(delay, dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("toListNav", sender: self)
                    })
            })
        })
    }
    
}

