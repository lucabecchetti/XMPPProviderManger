//
//  ProviderItem.swift
//  frind
//
//  Created by Luca Becchetti on 06/12/17.
//  Copyright © 2017 brokenice. All rights reserved.
//

import Foundation
import XMPPFramework

/// Struct returned by parser
public struct ProviderItem{
    
    /// Message parsed from provider
    var node        : XMPPMessage
    
    /// Founded extensions
    var extensions  : [XMPPProviderExtension]
    
}

