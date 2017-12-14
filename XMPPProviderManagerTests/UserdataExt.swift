//
//  UserdataExt.swift
//  XMPPProviderManagerTests
//
//  Created by Luca Becchetti on 14/12/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Foundation
import XMPPFramework
import XMPPProviderManager
class UserdataExt : NSObject, XMPPProviderExtension{
    
    static var nodename     : String     = "userdata"
    static var namespace    : String    = ""
    var providerNode        : XMPPMessage?
    var fromJid             : XMPPJID?
    
    /// Fields to describe user data
    var phone       : String?
    var displayName : String?
    var picUrl      : String?
    
    /// Initialize provider
    ///
    /// - Parameters:
    ///   - phone: User phone number
    ///   - displayName: User displayName
    ///   - picUrl: User picUrl
    public init(phone:String?, displayName : String?, picUrl : String?){
        
        super.init()
        self.phone          = phone
        self.displayName    = displayName
        self.picUrl         = picUrl
        
    }
    
    static func parse(node: XMPPMessage, parentNode parent: XMPPMessage?) -> XMPPProviderExtension? {
        
        guard node.name! == UserdataExt.nodename else {
            print("Missing node <userdata> while parsing")
            return nil
        }
        
        var phoneNumber = ""
        var displayName = "unknown"
        var picUrl      = ""
        
        if let phn: String = node.attribute(forName: "phone")?.stringValue {
            phoneNumber = phn
        }
        if let dispname: String = node.attribute(forName: "displayName")?.stringValue {
            displayName = dispname
        }
        if let pi: String = node.attribute(forName: "picUrl")?.stringValue {
            picUrl = pi
        }
        
        return UserdataExt(phone: phoneNumber, displayName: displayName, picUrl: picUrl)
        
    }
    
    func toXML() -> XMPPMessage {
        
        let userdata = DDXMLElement(name: UserdataExt.nodename)
        userdata.addAttribute(withName: "phone", objectValue: phone ?? "")
        userdata.addAttribute(withName: "displayName", objectValue: displayName ?? "")
        userdata.addAttribute(withName: "picUrl", objectValue: picUrl ?? "")
        
        return XMPPMessage.init(from: userdata)
        
    }
    
    
}
