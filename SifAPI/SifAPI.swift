//
//  SifAPI.swift
//  Paid App
//
//  Created by IOS Developer on 12/26/14.
//  Copyright (c) 2014 TapFreaks.NeT. All rights reserved.
//  Author : Mohammad Asif
//  Enjoye :)
//

import Foundation
import UIKit
private let _shareSifAPI:SifAPI = SifAPI()

class SifAPI:NSObject {
    
    class var shareSifAPI:SifAPI {
        
        _shareSifAPI.params = [(key:String, value:String)]()
        _shareSifAPI.model = ""
        _shareSifAPI.fromKey = ""
        _shareSifAPI.method = ""
        _shareSifAPI.action = ""
        _shareSifAPI.baseURI = ""
        _shareSifAPI.json = NSDictionary()
        _shareSifAPI.cacheTime = 0
        _shareSifAPI.timeOut = 0
        _shareSifAPI.cache = false
        _shareSifAPI.Debug = false
        _shareSifAPI.DebugLevel = 0
        
        return _shareSifAPI
    }
    
    var url:NSURL
    var method:String
    var timeOut:Double
    var params:[(key:String, value:String)]
    var cache:Bool
    var cacheTime:Int
    var action:String
    var baseURI:String
    var json:NSDictionary
    
    var model:String
    var fromKey:String
    var Debug:Bool
    var DebugLevel:Int
    
    private var modelKeys:[String]
    
    override init() {
        self.url = NSURL()
        self.method = NSString() as String
        self.params = []
        self.timeOut = 0
        self.cache = false
        self.action = String()
        self.model = String()
        self.fromKey = String()
        self.modelKeys = []
        self.cacheTime = 60 // Seconds - by default
        self.baseURI = String() // If you need any other baseURL, defined in Preferences
        self.Debug = false
        self.json = NSDictionary()
        self.DebugLevel = 0
    }
    
    // Public Section
    func syncDataRequest(completionHandler:(response:AnyObject) -> ()) {
        
        
        var oURL:String = String()
        
        if baseURI.utf16.count > 0 {
            if Prefs.respondsToSelector(NSSelectorFromString(baseURI)) {
                oURL = "\(Prefs.valueForKey(baseURI)!)\(action)"
            } else {
                
                if self.Debug {
                    print("Sif API : Debug = TRUE")
                    print("URI not found in Preferences.swift")
                    print("---++++---")
                }
                
                return
            }
        } else {
            oURL = Prefs.baseURL + action
        }
        
        //NSCharacterSet.URLQueryAllowedCharacterSet
        
        oURL = oURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let request = NSMutableURLRequest(URL: NSURL(string: oURL )!)
        let session = NSURLSession.sharedSession()
        
        if self.method.utf16.count > 0 {
            request.HTTPMethod = method
        } else {
            request.HTTPMethod = "GET"
        }
        
        let _: NSError?
        if self.params.count > 0 {
            if self.method == "POST" {
                var bodyData:String = String()
                for item in self.params {
                    bodyData = bodyData + item.key + "=" + item.value + "&"
                }
                bodyData = bodyData.substringToIndex(bodyData.endIndex.predecessor())
                request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding,
                    allowLossyConversion: false)
            } else {
                
                var x = 0
                for item in self.params {
                    if x == 0 {
                        oURL = oURL + "?" + item.key + "=" + item.value
                    } else {
                        oURL = oURL + "&" + item.key + "=" + item.value
                    }
                    x++
                }
                oURL = oURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                request.URL = NSURL(string: oURL)
            }
        }
        
        //request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        //request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            
//            let datastring: String = NSString(data:data!, encoding:NSUTF8StringEncoding)! as String
//            print(datastring)
            
            if data!.length == 0 {
                
                if self.Debug {
                    print("Sif API : Debug = TRUE")
                    print("Nothing recieved !")
                    print("---++++---")
                }
                
                completionHandler(response: false)
                return ;
            }
            if self.cache {
                self.cacheResponse(request.URL!.absoluteString, response: data!)
            }
            
            // Edit 6 Oct 2015 -> Beside the mapping, set returning json to json key
            let _: NSError?
            if let JSONData = data {
                
                do {
                    
                    let jsn: AnyObject = try NSJSONSerialization.JSONObjectWithData(JSONData, options: [])
                    
                    if let _ = jsn as? NSDictionary {
                        self.json = jsn as! NSDictionary
                    }
                    
                } catch {
                    //fatalError()
                }
            }
            
            let assRes:AnyObject = self.assembleResponse(data!)
            completionHandler(response: assRes)
            
        })
        
        if self.timeOut != 0 {
            request.timeoutInterval = timeOut
        }
        if self.cache {
            let (time, isValid) = self.hasValidCache(request.URL!.absoluteString)
            if isValid {
                
                if self.Debug && self.DebugLevel == 1 {
                    print("Sif API : Debug = TRUE")
                    print("Valid caching found, with \(time) secs remaining")
                    print("---++++---")
                }
                
                let cacheObj = self.getCacheObject(request.URL!.absoluteString)
                let assRes:AnyObject = self.assembleResponse(cacheObj)
                completionHandler(response: assRes)
                
            } else {
                
                if self.Debug && self.DebugLevel == 1 {
                    print("Sif API : Debug = TRUE")
                    print("Invalid caching found !")
                    print("---++++---")
                }
                
                
                task.resume()
            }
        } else {
            task.resume()
        }
        
        if self.Debug {
            if self.method == "POST" {
                print("Sif API : Debug = TRUE")
                print("Type Request POST:")
                print(request.URL!.absoluteString)
                print("Request Params:")
                for item in self.params {
                    print("Key: \(item.key), Value: \(item.value)")
                }
                print("---++++---")
            } else {
                print("Sif API : Debug = TRUE")
                print("Type Request GET:")
                print(request.URL!.absoluteString)
                print("---++++---")
            }
            
        }
    }
    func testParse() {
        self.extractModelKeys()
    }
    
    // Private Section
    private func assembleResponse(let data:NSData) -> AnyObject         {
        
        if self.model.utf16.count > 0 {
            
            self.extractModelKeys()
            
            var err: NSError?
            do {
                try NSJSONSerialization.JSONObjectWithData(data, options:[])
            } catch let error as NSError {
                err = error
            }
            if err != nil {
                print("Invalid JSON")
                return false
            }
            
            do  {
                
                if self.fromKey.utf16.count > 0 {
                    
                    let json:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                    
                    if json.valueForKey(self.fromKey) != nil {
                        
                        if let jsonArr = json.valueForKey(self.fromKey)! as? NSArray {
                            let genArray = self.mapArrayToModel(jsonArr as [AnyObject])
                            return genArray
                        } else {
                            let dict = json.valueForKey(self.fromKey)! as! NSDictionary
                            let mappedObj:AnyObject = self.mapObjectToModel(dict)
                            return mappedObj
                        }
                        
                    } else {
                        print("Key \(self.fromKey) not found in JSON")
                    }
                    
                } else {
                    
                    if let json:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary {
                        let mappedObj:AnyObject = self.mapObjectToModel(json)
                        return mappedObj
                        
                    }
                    
                    if let jsonArray:NSArray = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSArray {
                        let genArray = self.mapArrayToModel(jsonArray as [AnyObject])
                        return genArray
                    }
                }
            } catch {
                
            }
            
            
            
        } else {
            if self.fromKey.utf16.count > 0 {
                
                var err: NSError?
                do {
                    try NSJSONSerialization.JSONObjectWithData(data, options:[])
                } catch let error as NSError {
                    err = error
                }
                if err != nil {
                    print("Invalid JSON")
                    return false
                }
                
                do {
                    
                    let json:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                    
                    if json.valueForKey(self.fromKey) != nil {
                        return json.valueForKey(self.fromKey)!
                    } else {
                        print("Key \(self.fromKey) not found in JSON")
                    }
                    
                } catch {
                    
                }
                
                
            } else {
                return data
            }
        }
        return false
    }
    
    // Cache Functions
    private func getCacheObject(request:String) -> NSData               {
        let Dataproxy = NSUserDefaults.standardUserDefaults()
        
        if Dataproxy.valueForKey(request) != nil {
            var cachObj = Dataproxy.valueForKey(request)! as! [String:AnyObject]
            let cache:NSData = cachObj["response"]! as! NSData
            return cache
        }
        
        return NSData()
    }
    private func hasValidCache(request:String) -> (Int, Bool)           {
        let Dataproxy = NSUserDefaults.standardUserDefaults()
        //let date = NSDate()
        
        if Dataproxy.valueForKey(request) != nil {
            var cachObj = Dataproxy.valueForKey(request)! as! [String:AnyObject]
            let cacheTime:NSDate = cachObj["time"]! as! NSDate
            let now:NSDate = NSDate()
            let compare = now.compare(cacheTime) == NSComparisonResult.OrderedAscending
            var remainingCacheTime = 0
            if compare {
                remainingCacheTime = Int(cacheTime.timeIntervalSinceDate(now))
            }
            return (remainingCacheTime, compare)
        }
        
        Dataproxy.synchronize()
        return (0, false)
    }
    private func cacheResponse(request:String, response:NSData)         {
        let Dataproxy = NSUserDefaults.standardUserDefaults()
        var date = NSDate()
        date = date.dateByAddingTimeInterval(Double(self.cacheTime))
        let cachObj:[String:AnyObject] = ["time": date, "response": response]
        Dataproxy.setObject(cachObj, forKey: request)
        Dataproxy.synchronize()
    }
    
    // Mapping Functions
    private func extractModelKeys() {
        
        if self.model.utf16.count == 0 {
            return
        }
        
        if  var appName: String? = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String? {
            
            appName = appName!.stringByReplacingOccurrencesOfString(" ", withString: "_",
                options: [], range: nil)
            let validModelName = "\(appName!).\(self.model)"
            
            var count: UInt32 = 0
            let properties = class_copyPropertyList(NSClassFromString(validModelName) , &count)
            if count > 0 {
                
                self.modelKeys.removeAll(keepCapacity: false)
                
                for var i = 0; i < Int(count); ++i {
                    let property: objc_property_t = properties[i]
                    let name:String = NSString(CString:
                        property_getName(property), encoding: NSUTF8StringEncoding)! as String
                    self.modelKeys.append(name)
                }
            }
        }
    }
    private func underscoreToCamelCase(string: String) -> String        {
        let items: [String] = string.componentsSeparatedByString("_")
        var camelCase = ""
        var isFirst = true
        for item: String in items {
            if isFirst == true {
                isFirst = false
                camelCase += item
            } else {
                camelCase += item.capitalizedString
            }
        }
        return camelCase
    }
    private func mapArrayToModel(arr:[AnyObject]) -> [AnyObject]        {
        
        var modelArray:[AnyObject] = Array()
        
        for item in arr {
            if let dict = item as? NSDictionary {
                let mappedObj:AnyObject = self.mapObjectToModel(dict)
                modelArray.append(mappedObj)
            }
        }
        
        return modelArray
    }
    private func mapObjectToModel(let dict:NSDictionary) -> AnyObject   {
        
        if  var appName: String? = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String? {
            
            appName = appName!.stringByReplacingOccurrencesOfString(" ", withString: "_", options: [], range: nil)
            let validModelName = "\(appName!).\(self.model)"
            
            let anyobjectype : AnyObject.Type = NSClassFromString(validModelName)!
            let nsobjectype : NSObject.Type = anyobjectype as! NSObject.Type
            let modelObj: AnyObject = nsobjectype.init()
            
            for key in self.modelKeys {
                if dict.valueForKey(key) != nil {
                    
                    
                    let ObjkeyValue:AnyObject = modelObj.valueForKey(key)!
                    let JsnkeyValue:AnyObject = dict.valueForKey(key)!
                    
                    if ObjkeyValue.isKindOfClass(JsnkeyValue.classForCoder) {
                        modelObj.setValue(dict.valueForKey(key)!, forKey: key)
                    } else {
                        
                        if self.Debug && self.DebugLevel == 1 {
                            let mdlClass = object_getClassName(ObjkeyValue)
                            let jsnClass = object_getClassName(JsnkeyValue)
                            let clsNameMdl = String.fromCString(mdlClass)
                            let clsNameJsn = String.fromCString(jsnClass)
                            print("Sif API : Debug = TRUE")
                            print("\(key):\(clsNameMdl!) unable to set \(clsNameJsn!) value")
                            print("---++++---")
                        }
                    }
                    
                } else {
                    if self.Debug && self.DebugLevel == 1 {
                        print("Sif API : Debug = TRUE")
                        print("Key \(key) not found !")
                        print("---++++---")
                    }
                }
            }
            return modelObj
        }
        
        return ""
    }
    
    
    func mapObjectToDictonary(let object:AnyObject, let dict:NSDictionary)   {
        
        var count: UInt32 = 0
        let properties = class_copyPropertyList(object.classForCoder , &count)
        if count > 0 {
            
            for var i = 0; i < Int(count); ++i {
                let property: objc_property_t = properties[i]
                let name:String = NSString(CString:
                    property_getName(property), encoding: NSUTF8StringEncoding)! as String
                
                for key in self.modelKeys {
                    if dict.valueForKey(key) != nil {
                        
                        
                        let ObjkeyValue:AnyObject = object.valueForKey(name)!
                        let JsnkeyValue:AnyObject = dict.valueForKey(name)!
                        
                        if ObjkeyValue.isKindOfClass(JsnkeyValue.classForCoder) {
                            object.setValue(dict.valueForKey(name)!, forKey: name)
                        } else {
                            
                            if self.Debug && self.DebugLevel == 1 {
                                let mdlClass = object_getClassName(ObjkeyValue)
                                let jsnClass = object_getClassName(JsnkeyValue)
                                let clsNameMdl = String.fromCString(mdlClass)
                                let clsNameJsn = String.fromCString(jsnClass)
                                print("Sif API : Debug = TRUE")
                                print("\(name):\(clsNameMdl!) unable to set \(clsNameJsn!) value")
                                print("---++++---")
                            }
                        }
                        
                    } else {
                        if self.Debug && self.DebugLevel == 1 {
                            print("Sif API : Debug = TRUE")
                            print("Key \(name) not found !")
                            print("---++++---")
                        }
                    }
                }
            }
        }
        
    }
    
}
