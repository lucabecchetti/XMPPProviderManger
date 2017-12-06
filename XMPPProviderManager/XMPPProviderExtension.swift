//
//  XMPPProviderExtension.swift
//  frind
//
//  Created by Luca Becchetti on 06/12/17.
//  Copyright © 2017 brokenice. All rights reserved.
//

import Foundation
import XMPPFramework

/// Protocol to define an extension
@objc public protocol XMPPProviderExtension {
    
    /// Name for node <nodename>
    static var nodename  : String {get set}
    
    /// Namespace <nodename xmlns="namespace">
    static var namespace : String {get set}
    
    /// Alternative alias name
    @objc optional static var aliasName : [String] {get set}
    
    /// Message used to parse extension
    var providerNode : XMPPMessage? {get set}
    
    /// Sender jid for extensions
    var fromJid      : XMPPJID? {get set}
    
    /// Parse method to return an XML
    ///
    /// - Returns: XMPPProviderProtocol
    static func parse(node:XMPPMessage, parentNode parent : XMPPMessage?) -> XMPPProviderExtension?
    
    /// Return XML representation for this protocol
    ///
    /// - Returns: DDXMLElement
    func toXML() -> XMPPMessage
    
}
