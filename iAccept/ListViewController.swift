//
//  ListViewController.swift
//  iAccept
//
//  Created by TapFreaks on 1/21/16.
//  Copyright © 2016 Mohammad Asif. All rights reserved.
//

import UIKit

class ListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableList:UITableView!
    
    var selectedIndex = -1
    
    // Loading
    var loadingView:UIView = UIView()
    var loadingSpiner:UIActivityIndicatorView =
    UIActivityIndicatorView()
    
    var arrayData = [dataModel]()
    
    func startLoading() {
        loadingView = UIView()
        loadingView.bounds = self.view.bounds
        loadingView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        loadingView.center = self.view.center
        self.view.addSubview(loadingView)
        loadingSpiner = UIActivityIndicatorView(activityIndicatorStyle:
            UIActivityIndicatorViewStyle.White)
        loadingSpiner.center = loadingView.center
        loadingSpiner.startAnimating()
        loadingView.addSubview(loadingSpiner)
    }
    func stopLoading()  {
        loadingSpiner.stopAnimating()
        loadingSpiner.removeFromSuperview()
        loadingView.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "List"
        
        self.tableList.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        self.tableList.dataSource = self
        self.tableList.delegate = self
        
        self.callData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toDetail" {
            if self.selectedIndex != -1 {
                let dModel = self.arrayData[self.selectedIndex]
                let dView = segue.destinationViewController as! DetailViewController
                dView.dModel = dModel
            }
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayData.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")

        
        let dModel = self.arrayData[indexPath.item]
        
        cell.textLabel?.text = dModel.name
        cell.detailTextLabel?.text = dModel.position
        
        cell.imageView?.image = UIImage(named: "no-image.png")
        
        if dModel.imageSmall != nil {
            cell.imageView?.image = dModel.imageSmall
        } else {
            
            let sifImg = SifImageCache()
                sifImg.baseURL = "imageURL"
                sifImg.getImage(dModel.smallpic) { (image: UIImage) in
                    dModel.imageSmall = image
                    cell.imageView?.image = dModel.imageSmall
            }
        }
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.selectedIndex = indexPath.item
        self.performSegueWithIdentifier("toDetail", sender: self)
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func callData() {
        let sifAPI = SifAPI.shareSifAPI
        sifAPI.method = "GET" // Requesting method POST or GET
        sifAPI.action = "response.json" // Action would be added at the end of your base URL
        //sifAPI.fromKey = "" //Extract information from a particular from returning JSON
        sifAPI.model = "dataModel" // Map a NSObject class with returning JSON
        
        sifAPI.Debug = true
        
        self.startLoading()
        
        sifAPI.syncDataRequest() { (response:AnyObject) in
            
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
            dispatch_after(delay, dispatch_get_main_queue(), {
                
                self.arrayData = response as! [dataModel]
                
                self.stopLoading()
                self.tableList.reloadData()
            })
        }
    }
    
}
