//
//  TimeExt.swift
//  TimeExt
//
//  Created by Luca Becchetti on 14/12/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Foundation
import XMPPFramework
import XMPPProviderManager

/// Class to parse xmpptime
/// <time xmlns="urn:xmpp:time"><tzo>+01:00</tzo><utc>2017-12-05T09:30:56Z</utc></time>
/// @see https://xmpp.org/extensions/xep-0202.html
class TimeExt : XMPPProviderExtension{
    
    static var nodename     : String    = "time"
    static var namespace    : String    = "urn:xmpp:time"
    var providerNode        : XMPPMessage?
    var fromJid             : XMPPJID?
    
    /// Parsed date
    public var dateParsed   : Date?
    
    /// Initialize provider
    init(){
        self.dateParsed = Date()
    }
    
    /// Initialize provider from date
    ///
    /// - Parameter date: Date
    init(fromDate date : Date){
        self.dateParsed = date
    }
    
    static func parse(node: XMPPMessage, parentNode parent : XMPPMessage?) -> XMPPProviderExtension? {
        
        guard node.name == TimeExt.nodename else {
            print("Missing node <time> while parsing")
            return nil
        }
        
        if let utc = node.forName("utc")?.stringValue {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
            if let dateFromString = formatter.date(from: utc) {
                return TimeExt(fromDate: dateFromString)
            }
            return nil
            
        }else{
            
            print("Ricevuto un messaggio di testo senza il nodo time, utilizzo ora di arrivo di sistema")
            return nil
            
        }
        
    }
    
    func toXML() -> XMPPMessage {
        return XMPPMessage.init(from: XMPPTime.timeElement(from: dateParsed!))
    }
    
}

