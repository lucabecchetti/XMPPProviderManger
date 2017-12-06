//
//  XMPPProviderManager.swift
//  frind
//
//  Created by Luca Becchetti on 04/12/17.
//  Copyright © 2017 brokenice. All rights reserved.
//

import Foundation
import XMPPFramework

open class XMPPProviderManager : NSObject{
    
    /// Tag for logging
    private let TAG     : String = "[XMPPProviderManager]"
    
    /// Delegate for provider
    public var delegage : XMPPProviderManagerDelegate?
    
    /// Quueue dispatch for delegate
    internal var delegateQueue : DispatchQueue?
    
    /// Extensions queue
    internal var _extensions : [XMPPProviderExtension.Type] = [XMPPProviderExtension.Type]()
    
    /// Activate provider by register a delegate in XMPPStream
    ///
    /// - Parameters:
    ///   - stream: XMPPStream
    ///   - queue: DispatchQueue
    public func activate(xmppStream stream : XMPPStream, delegateQueue queue: DispatchQueue){
        
        self.delegateQueue = queue
        stream.addDelegate(self, delegateQueue: queue)
        
    }
    
    /// Function to register an extension node
    ///
    /// - Parameter class: XMPPProviderExtension
    public func registerExtension(withClass ext : XMPPProviderExtension.Type){
        
        _extensions.append(ext)
        print("\(TAG) extensions: \(String(describing: type(of:ext))) registered and now managed!")
        
    }
    
    /// Get extension from a passed node
    ///
    /// - Parameters:
    ///   - ext: XMPPProviderExtension.Type
    ///   - message: XMPPMessage
    /// - Returns: XMPPProviderExtension?
    public func get(extension ext : XMPPProviderExtension.Type, fromMessage message : XMPPMessage) -> XMPPProviderExtension?{
        
        /// Check node extesion inside passed node
        if let nodeExt = message.forName(ext.nodename){
            
            return ext.parse(node: XMPPMessage.init(from: nodeExt), parentNode: message)
            
        }
        
        return nil
    }
    
    /// Get all extensions on a passed message
    ///
    /// - Parameter message: XMPPMessage
    /// - Returns: [XMPPProviderExtension]
    public func getExtensions(fromMessage message : XMPPMessage, type : XMPPProviderExtension.Type? = nil) -> [XMPPProviderExtension]{
     
        var extensions = [XMPPProviderExtension]()
        
        if let children = message.children{
            for child in children{
                
                /// Check all type or only required type
                let ext = (type != nil) ? _extensions.first{ (type) -> Bool in
                    return type.nodename == child.name! || (type.aliasName != nil && type.aliasName!.contains(child.name!))
                } : type
                
                let node = XMPPMessage.init(from: child as! DDXMLElement)
                if let extesionParsed = ext?.parse(node: node, parentNode: message){
                    extesionParsed.providerNode = node
                    extensions.append(extesionParsed)
                }
                
            }
        }
        
        return extensions
        
    }
    
    /// Find passed attributes inside passed node
    ///
    /// - Parameters:
    ///   - attributes: [String : String?]
    ///   - node: XMPPMessage
    /// - Throws
    static func find(attributes : inout [String : String?], inNode node : XMPPMessage) throws {
        
        for (key,_) in attributes{
            
            if let value: String = node.attribute(forName: key)?.stringValue {
                attributes[key] = value
            }else{
                throw CustomError.RuntimeError("Missing attribute '\(key)' while parsing <media> node")
            }
            
        }
        
    }
    
    internal enum CustomError : Error {
        case RuntimeError(String)
    }
    
}
