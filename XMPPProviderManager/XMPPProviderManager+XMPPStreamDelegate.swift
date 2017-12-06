//
//  XMPPProviderManager+XMPPStreamDelegate.swift
//  frind
//
//  Created by Luca Becchetti on 06/12/17.
//  Copyright © 2017 brokenice. All rights reserved.
//

import Foundation
import XMPPFramework

// MARK: - XMPPStreamDelegate
extension XMPPProviderManager : XMPPStreamDelegate {
    
    public func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        
        /// Array to store parsed extensions
        var parsedExt : [XMPPProviderExtension] = [XMPPProviderExtension]()
        
        /// Check if we are receiving an error, we do not want to parse it
        guard !message.isErrorMessage else{
            return
        }
        
        /// Iterate all children of <message> node and try to parse registered extensions
        if let children = message.children{
            for child in children{
                
                /// Get extension if exists
                let ext = _extensions.first{ (type) -> Bool in
                    return type.nodename == child.name! || (type.aliasName != nil && type.aliasName!.contains(child.name!))
                }
                
                /// Parse extesion
                let elementChild = XMPPMessage.init(from: child as! DDXMLElement)
                if let extesionParsed = ext?.parse(node: elementChild, parentNode: message){
                    
                    /// Get sender JID
                    if let from: String = message.attribute(forName: "from")?.stringValue, let jid = XMPPJID.init(string: from) {
                        extesionParsed.fromJid = jid
                    }
                    
                    extesionParsed.providerNode = elementChild
                    parsedExt.append(extesionParsed)
                }
            }
        }
        
        /// If we found extensions, notifies the delegate
        if parsedExt.count > 0{
            delegateQueue?.async {
                self.delegage?.xmppProviderManager(self, didParse: ProviderItem(node: message, extensions: parsedExt))
            }
        }
        
    }
    
}
