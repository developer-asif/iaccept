//
//  Preferences.swift
//  Paid App
//
//  Created by IOS Developer on 12/27/14.
//  Copyright (c) 2014 TapFreaks.NeT. All rights reserved.
//

import Foundation
class Prefs:NSObject {
    
    class var baseURL:String {
        return "http://s3-us-west-2.amazonaws.com/wirestorm/assets/"
    }
    
    class var imageURL:String {
        // Change this to requirements ....
        return "http://tapfreaks.net/logo_scan/uploads/"
    }
    
    class var qrURL:String {
        return "http://tapfreaks.net/logo_scan/QR_Code/"
    }
    
}


