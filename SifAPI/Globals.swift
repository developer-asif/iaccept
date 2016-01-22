//
//  Globals.swift
//  Paid App
//
//  Created by IOS Developer on 12/28/14.
//  Copyright (c) 2014 TapFreaks.NeT. All rights reserved.
//

// Variables
import UIKit
import Foundation

public var selectedLanguage = 0

public var appName  = "Cherry Q8"
public var appNameAr = "چیری کویت"
public var appCategories:NSArray?

// Functions
public func langSlug() -> String    {
    var rString = "_en"
    switch selectedLanguage {
    case 0:
        rString = "_en";
        break
    case 1:
        rString = "_ar";
        break
    case 2:
        rString = "_fr";
        break
    case 3:
        rString = "_hn";
        break
    case 4:
        rString = "_ur";
        break
    case 5:
        rString = "_ba";
        break
    case 6:
        rString = "_ph";
        break
    default:
        rString = "_en";
        break
    }
    return rString;
}
public func device() -> Float       {
    
    /*
    
    if UIDevice().userInterfaceIdiom == .Phone {
    switch UIScreen.mainScreen().nativeBounds.height {
    case 480:
    //print("iPhone Classic")
    return 3
    case 960:
    //print("iPhone 4 or 4S")
    return 4
    case 1136:
    //print("iPhone 5 or 5S or 5C")
    return 5
    case 1334:
    //print("iPhone 6 or 6S")
    return 6
    case 2208:
    //print("iPhone 6+ or 6S+")
    return 7
    default:
    //print("unknown")
    return 0
    }
    }
    */
    
    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {
        
        let height = UIScreen.mainScreen().bounds.height
        
        switch height {
            
        case 736.0: // 6+, 6S+
            return 6.5
            
        case 667.0: // 6, 6S
            return 6.0
            
        case 568.0: // 5, 5S, 5C
            return 5.0
            
        case 480.0: // 4, 4S
            return 4.0
            
        default:
            break
        }
        
    } else {
        
    }
    
    return 0
}
public func alert(title title:String, message:String) {
    let theAlert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Ok")
    theAlert.show()
}

//extension String {
//    func isEmail() -> Bool {
//        let regex = NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive, error: nil)
//        return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, count(self))) != nil
//    }
//}

public func isValidEmail(testStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let range = testStr.rangeOfString(emailRegEx, options:.RegularExpressionSearch)
    let result = range != nil ? true : false
    return result
}
