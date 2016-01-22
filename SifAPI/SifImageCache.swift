//
//  SifImageCache.swift
//  Paid App
//
//  Created by IOS Developer on 1/3/15.
//  Copyright (c) 2015 TapFreaks.NeT. All rights reserved.
//  Author : Mohammad Asif
//  Enjoye :)
//

import UIKit
private let _sharedCache:SifImageCache = SifImageCache()
class SifImageCache: NSObject {
    
    private var handler: ((image:UIImage) -> Void)?
    private var imgName:NSString
    
    var baseURL:NSString
    var indexPath:NSIndexPath
    var tag:Int
    var cache:Bool
    
    override init() {
        baseURL = NSString()
        imgName = NSString()
        indexPath = NSIndexPath()
        tag = Int()
        cache = true
    }
    
    class var sharedSifImageCache:SifImageCache {
        return _sharedCache
    }
    
    // Public Section
    func getImage(var imageName:NSString, handler:((image:UIImage) -> Void)) {
        
        if imageName == "" {
            return
        }
        
        self.handler = handler
        imageName = imageName.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        // New Logic
        
        if  imageName.rangeOfString("http://").location != NSNotFound ||
            imageName.rangeOfString("https://").location != NSNotFound {
                baseURL = imageName.stringByReplacingOccurrencesOfString(imageName.lastPathComponent, withString: "")
                imageName = imageName.lastPathComponent
        }
        
        self.imgName = imageName
        self.imgName = self.imgName.stringByReplacingOccurrencesOfString("/",
            withString: "_")
        
        if  baseURL.rangeOfString("http:").location == NSNotFound &&
            baseURL.rangeOfString("https:").location == NSNotFound {
                if let uri = Prefs.valueForKey(baseURL as String)! as? String {
                    baseURL = uri
                }
        }
        
        baseURL = baseURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        if NSFileManager.defaultManager()
            .fileExistsAtPath(self.getDocumentPath() + (imgName as String)) {
                // println("Loading from cache.")
                let imgFromFile = UIImage(contentsOfFile: self.getDocumentPath() + (imgName as String))
                handler(image: imgFromFile!)
        } else {
            // println("Loading from internet.")
            self.downloadImage(NSURL(string:(baseURL as String) + (imageName as String))!)
        }
    }
    
    // Private Section
    private func downloadImage(url: NSURL)      {
        
        let imageRequest: NSURLRequest = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(imageRequest,
            queue: NSOperationQueue.mainQueue(),
            completionHandler:{response, data, error in
                
                if error == nil {
                    
                    if UIImage(data: data!) != nil {
                        let downloadedImage = UIImage(data: data!)!
                        if self.cache {
                            self.cacheImage(downloadedImage)
                        }
                        self.handler!(image: downloadedImage)
                    }
                    
                } else {
                    print(error)
                }
                
            })
    }
    private func getDocumentPath() -> String    {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)[0] as NSString as String
    }
    private func cacheImage(image:UIImage)      {
        var saveToPath = self.getDocumentPath()
        saveToPath += self.imgName as String
        
        if self.imgName.rangeOfString(".png", options:
            NSStringCompareOptions.CaseInsensitiveSearch).location != NSNotFound {
            UIImagePNGRepresentation(image)!.writeToFile(saveToPath, atomically:true)
        }
        
        if self.imgName.rangeOfString(".jpg", options:
            NSStringCompareOptions.CaseInsensitiveSearch).location != NSNotFound {
                UIImageJPEGRepresentation(image, 100)!.writeToFile(saveToPath, atomically:true)
        }
        
        if self.imgName.rangeOfString(".jpeg", options:
            NSStringCompareOptions.CaseInsensitiveSearch).location != NSNotFound {
                UIImageJPEGRepresentation(image, 100)!.writeToFile(saveToPath, atomically:true)
        }
        
    }
}
