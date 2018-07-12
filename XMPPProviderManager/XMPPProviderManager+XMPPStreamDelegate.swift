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
        
        /// Parse message
        let parsedExt = parseReceivedMessage(sender, didReceive: message)
        
        /// If we found extensions, notifies the delegate
        if parsedExt.count > 0{
            delegateQueue?.async {
                self.delegate?.xmppProviderManager(self, didParse: ProviderItem(node: message, extensions: parsedExt))
            }
        }
        
    }
    
    /// Function to parse a received message
    ///
    /// - Parameters:
    ///   - sender: XMPPStream
    ///   - message: XMPPMessage
    /// - Returns: [XMPPProviderExtension]
    public func parseReceivedMessage(_ sender: XMPPStream, didReceive message: XMPPMessage) -> [XMPPProviderExtension]{
        /// Array to store parsed extensions
        var parsedExt : [XMPPProviderExtension] = [XMPPProviderExtension]()
        
        /// For pub sub check for message inside items
        if message.elements(forName: "event").count > 0, message.elements(forXmlns: XMLNS_PUBSUB_EVENT).count > 0{
            
            if let event = message.forName("event"), let items: DDXMLElement = event.forName("items"), let children = items.children {
                
                /// Find <message> node inside event -> items -> item
                for child in children{
                    if let messageChild = child.children?.filter({ (childnode) -> Bool in
                        return childnode.name == "message"
                    }){
                        /// Iterate all children
                        for ch in messageChild{
                            
                            /// Build message
                            if let msg = XMPPMessage.init(from: ch as! DDXMLElement){
                        
                                if !XMPPProviderManager.downloadMyMessagesForNodes.contains(items.attribute(forName: "node")!.stringValue!){
                                    /// Make sure i'm not sender
                                    guard !isMine(message: msg, sender: sender) else{
                                        continue
                                    }
                                }
                                
                                if let ex = getExt(fromMessage: msg){
                                    ex.forEach({ (_ext) in
                                        _ext.providerNode = XMPPMessage.init(from: items)
                                        parsedExt.append(_ext)
                                    })
                                }
                            }
                            
                        }
                    }
                }
            }
            
        }else{
            
            /// Make sure i'm not sender
            guard !isMine(message: message, sender: sender) else{
                return []
            }
            
            if let ex = getExt(fromMessage: message){
                ex.forEach({ (_ext) in
                    parsedExt.append(_ext)
                })
            }
            
        }
        return parsedExt
    }
    
    /// Check if i am a sender of message, usefull for pubsub message that are sent to sender
    ///
    /// - Parameters:
    ///   - message: XMPPMessage
    ///   - sender: XMPPStream
    /// - Returns: Bool
    fileprivate func isMine(message:XMPPMessage, sender : XMPPStream) -> Bool{
        
        guard let my = sender.myJID?.user, message.from() != nil, var send = message.from().user else {
            return false
        }
        /// For conference message (MUC), from attribute has this form:
        /// 18261@conference.node0.frind.it/419938e9-767c-11e6-9755-0e27c70eabb1@node0.frind.it
        /// the real sender is the resource of JID, the string after /
        if let _ = message.from().full().range(of: "@conference"){
            if let resource = message.from().resource{
                send = resource
            }
        }
        
        
        return my == send
    }
    
    /// Find all extension in passed message
    ///
    /// - Parameter message: XMPPMessage
    /// - Returns: XMPPProviderExtension
    fileprivate func getExt(fromMessage message : XMPPMessage) -> [XMPPProviderExtension]?{
        
        /// Check if we are receiving an error, we do not want to parse it
        guard !message.isErrorMessage() else{
            return nil
        }
        
        /// Array of extesions
        var foundExt = [XMPPProviderExtension]()
        
        /// Iterate all children of <message> node and try to parse registered extensions
        if let children = message.children{
            
            
            for child in children{
                
                /// Get extension if exists
                let ext = _extensions.first{ (type) -> Bool in
                    return type.nodename == child.name! || (type.aliasName != nil && type.aliasName!.contains(child.name!))
                }
                
                /// Parse extesion
                let elementChild = XMPPMessage.init(from: child as! DDXMLElement)
                if let extesionParsed = ext?.parse(node: elementChild!, parentNode: message){
                    
                    extesionParsed.fromJid = message.from()
                    extesionParsed.providerNode = elementChild
                    
                    foundExt.append(extesionParsed)
                    
                }
            }
            
        }
        
        return foundExt
        
    }
    
}
