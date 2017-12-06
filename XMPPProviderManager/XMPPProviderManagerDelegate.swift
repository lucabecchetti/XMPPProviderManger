//
//  XMPPProviderManagerDelegate.swift
//  frind
//
//  Created by Luca Becchetti on 06/12/17.
//  Copyright © 2017 brokenice. All rights reserved.
//

import Foundation
import XMPPFramework

/// Delegate for provider managaer
public protocol XMPPProviderManagerDelegate{
    
    /// Notifies the delegate that new item did parsed
    ///
    /// - Parameters:
    ///   - manager: XMPPProviderManager
    ///   - item: ProviderItem
    func xmppProviderManager(_ manager : XMPPProviderManager!, didParse item : ProviderItem)
    
}
