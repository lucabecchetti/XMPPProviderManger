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
    open func getExtensions(fromMessage message : XMPPMessage, type : XMPPProviderExtension.Type? = nil) -> [XMPPProviderExtension]{
     
        var extensions = [XMPPProviderExtension]()
        
        for ext in _extensions.filter({ (ext) -> Bool in
            guard let type = type else { return true }
            return ext == type
        }){
            
            /// Build array of node name and aliases
            var name = [ext.nodename]
            ext.aliasName?.forEach({ (alias) in
                name.append(alias)
            })
            /// Iterate names and look for extensions
            for nm in name{
                for element in message.elements(forName: nm){
                    let mes = XMPPMessage(from: element)
                    if let extesionParsed = ext.parse(node: mes, parentNode: message){
                        extesionParsed.providerNode = mes
                        extensions.append(extesionParsed)
                    }
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
    static open func find(attributes : inout [String : String?], inNode node : XMPPMessage) throws {
        
        for (key,_) in attributes{
            
            if let value: String = node.attribute(forName: key)?.stringValue {
                attributes[key] = value
            }else{
                throw CustomError.RuntimeError("Missing attribute '\(key)' while parsing <\(node.name!)> node")
            }
            
        }
        
    }
    
    internal enum CustomError : Error {
        case RuntimeError(String)
    }
    
}
