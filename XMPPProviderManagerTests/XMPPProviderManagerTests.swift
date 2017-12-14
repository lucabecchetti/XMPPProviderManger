//
//  XMPPProviderManagerTests.swift
//  XMPPProviderManagerTests
//
//  Created by Luca Becchetti on 14/12/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import XCTest
import XMPPFramework
import XMPPProviderManager

class XMPPProviderManagerTests: XCTestCase {
    
    var xmppStream      : XMPPStream?
    var providerManager : XMPPProviderManager?
    var xmlDictionary   : [String : XMPPMessage] = [String : XMPPMessage]()
    
    override func setUp() {
        super.setUp()
       
        /// Initialize XMPPStream
        xmppStream = XMPPStream()
        
        /// Initialize XMPPProviderManager
        providerManager = XMPPProviderManager()
        
        /// Register extensions
        providerManager?.registerExtension(withClass: TimeExt.self)
        providerManager?.registerExtension(withClass: UserdataExt.self)
        
        /// Create dictionary
        do{
            xmlDictionary["right_message"] = try XMPPMessage.init(xmlString: """
                <message id="xxx" type="chat" from="xxx@node0.frind.it" to="yyy@node0.frind.it">
                    <time xmlns="urn:xmpp:time">
                        <tzo>+00:00</tzo>
                        <utc>2017-12-11T16:28:25Z</utc>
                    </time>
                    <userdata phone="+1111111" picUrl="http://www.pic.com" displayName="ProviderTest"></userdata>
                </message>
            """)
            xmlDictionary["wrong_message"] = try XMPPMessage.init(xmlString: """
                <message id="xxx" type="chat" from="xxx@node0.frind.it" to="yyy@node0.frind.it">
                    <time xmlns="urn:xmpp:time">
                        <tzo>+01:00</tzo>
                        <utc>2017-12-11T16:28:25Z</utc>
                    </time>
                    <userdata picUrl="http://www.pic.com" displayName="ProviderTest"></userdata>
                </message>
            """)
        }catch{
            XCTFail("Unable to parse XML")
        }

    }
    
    func testActivation(){
        
        providerManager?.activate(xmppStream: xmppStream!, delegateQueue: DispatchQueue.main)
        
        XCTAssert(providerManager!.delegateQueue == DispatchQueue.main, "Error setting delegate queue")
    }

    /// Test testParseReceivedMessage method
    func testParseReceivedMessage() {
       
        /// Check extensions from parseReceivedMessage method
        var _extensions = providerManager!.parseReceivedMessage(xmppStream!, didReceive: xmlDictionary["right_message"]!)
        
        XCTAssert(_extensions.count == 2, "Founded less than 2 extensions")
        
        let (t, u) = self._checExt(extensions: _extensions)
        guard let time = t, let userdata = u else {
            return
        }
        
        _checkTime(time: time)
        _checkUserdata(userdata: userdata)
        
        /// Check wrong extensions from parseReceivedMessage method
        _extensions = providerManager!.parseReceivedMessage(xmppStream!, didReceive: xmlDictionary["wrong_message"]!)
        
        XCTAssert(_extensions.count > 1, "Founded too much extensions")
        
        XCTAssert(_extensions.first(where: { (ext) -> Bool in return ext is UserdataExt }) != nil , "[UserdataExt] has been parsed from incorrect XML Source")
    
    }
    
    /// Test getExtensions method
    func testGetExtensions(){
        
        /// Check getExtensions method
        let _getExts = providerManager!.getExtensions(fromMessage: xmlDictionary["right_message"]!)
        
        XCTAssert(_getExts.count == 2, "Founded less than 2 extensions")
        
        /// Check extensions for all types
        let (t1, u1) = self._checExt(extensions: _getExts)
        
        _checkTime(time: t1)
        _checkUserdata(userdata: u1)
        
        /// Check extensions for single type
        let _getExtsUd = providerManager!.getExtensions(fromMessage: xmlDictionary["right_message"]!, type: UserdataExt.self)
        
        XCTAssert(_getExtsUd.count == 1, "Founded less or more than 1 extensions")
        
        guard let userdata1 = _getExtsUd.first(where: { (ext) -> Bool in return ext is UserdataExt }) as? UserdataExt else {
            XCTFail("Extension UserdataExt is not been parsed")
            return
        }
        
        _checkUserdata(userdata: userdata1)

    }
    
    func testGet(){
        
        /// Check getExtensions method
        let _udExt = providerManager!.get(extension: UserdataExt.self, fromMessage: xmlDictionary["right_message"]!)
        
        XCTAssert(_udExt != nil && _udExt! is UserdataExt, "Error while getting extension")
        
        _checkUserdata(userdata: _udExt as? UserdataExt)
        
    }
    
    /// Test find method
    func testFind(){
        
        /// Needed fields
        var fields : [String : String?] = ["phone" : nil, "picUrl" : nil, "displayName" : nil]
        
        /// Read all attributes that are present
        do{
            
            let node = try XMPPMessage.init(xmlString: "<userdata phone=\"+1111111\" displayName=\"ProviderTest\" picUrl=\"http://www.pic.com\"></userdata>")
            try XMPPProviderManager.find(attributes: &fields, inNode: node)
            
            XCTAssert(fields["phone"]!! == "+1111111","Error getting phone number")
            XCTAssert(fields["displayName"]!! == "ProviderTest","Error getting displayName")
            XCTAssert(fields["picUrl"]!! == "http://www.pic.com","Error getting picUrl")
            
        }catch{
            XCTFail("Error parsing attributes with find methods")
        }
        
        /// Try to read all attributes from wrong node where phone is missing
        let nodeWrong = try! XMPPMessage.init(xmlString: "<userdata displayName=\"ProviderTest\" picUrl=\"http://www.pic.com\"></userdata>")
        
        var errorCatch = false
        do{
            try XMPPProviderManager.find(attributes: &fields, inNode: nodeWrong)
        }catch{
            errorCatch = true
        }
        XCTAssert(errorCatch, "Missing required field phone, but no error is throwed")
        
    }
    
    /// Check correct data for UserdataExt
    ///
    /// - Parameter userdata: UserdataExt
    internal func _checkUserdata(userdata : UserdataExt?){
        
        guard let ud = userdata else { return }

        XCTAssert(ud.displayName != nil, "[UserdataExt] displayName parsed wrong")
        XCTAssert(ud.displayName! == "ProviderTest", "[UserdataExt] displayName parsed wrong")
        
        XCTAssert(ud.phone != nil, "[UserdataExt] phone parsed wrong")
        XCTAssert(ud.phone! == "+1111111", "[UserdataExt] phone parsed wrong")
        
        XCTAssert(ud.picUrl != nil, "[UserdataExt] picUrl parsed wrong")
        XCTAssert(ud.picUrl! == "http://www.pic.com", "[UserdataExt] picUrl parsed wrong")
        print(String(describing: ud.toXML()))
        
        /// Test generated XML
        XCTAssert("\(String(describing: ud.toXML()))" == "<userdata phone=\"+1111111\" displayName=\"ProviderTest\" picUrl=\"http://www.pic.com\"></userdata>", "Error generating XML")
        
    }
    
    /// Check correct data for TimeExt
    ///
    /// - Parameter time: TimeExt
    internal func _checkTime(time : TimeExt?){
        
        guard let tm = time else { return }

        let formatter = DateFormatter()
        let dateString = "2017-12-11T16:28:25Z"
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
        
        guard let dateFromString = formatter.date(from: dateString) else{
            XCTFail("[TimeExt] Unable to generate date from string")
            return
        }
        
        guard let dateP = tm.dateParsed else{
            XCTFail("[TimeExt] Parsed TimeExt do not contains valid date")
            return
        }
        
        XCTAssert(dateFromString == dateP, "[TimeExt] Date parsed wrong")
        
        /// Test generated XML
        XCTAssert("\(String(describing: tm.toXML()))" == "<time xmlns=\"urn:xmpp:time\"><tzo>+01:00</tzo><utc>2017-12-11T16:28:25Z</utc></time>", "Error generating XML")
        
    }
    
    /// Check presense of TimeExt and UserdataExt extensions
    ///
    /// - Parameter extensions: [XMPPProviderExtension]
    /// - Returns: (TimeExt?, UserdataExt?)
    internal func _checExt(extensions: [XMPPProviderExtension]) -> (TimeExt?, UserdataExt?){
        
        /// Check for parsed Extensions
        guard let time = extensions.first(where: { (ext) -> Bool in return ext is TimeExt }) as? TimeExt else {
            XCTFail("Extension TimeExt is not been parsed")
            return (nil,nil)
        }
        
        guard let userdata = extensions.first(where: { (ext) -> Bool in return ext is UserdataExt }) as? UserdataExt else {
            XCTFail("Extension UserdataExt is not been parsed")
            return (nil,nil)
        }
        
        return (time, userdata)
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        xmppStream = nil
    }
    
    
}
