//
//  CryptoBoxTests.swift
//  NaOH
//
//  Created by Drew Crawford on 8/16/15.
//  Copyright © 2015 DrewCrawfordApps. All rights reserved.
//  This file is part of NaOH.  It is subject to the license terms in the LICENSE
//  file found in the top level of this distribution
//  No part of NaOH, including this file, may be copied, modified,
//  propagated, or distributed except according to the terms contained
//  inthe LICENSE file.

import Foundation
import XCTest
@testable import NaOH

class CryptoBoxTests :XCTestCase {
    
    private let knownPlaintext : [UInt8] = [0,1,2]
    private let notVeryNonce : [UInt8] = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
    
    private let knownCiphertext : [UInt8] = [211, 170, 214, 228, 186, 238, 171, 198, 216, 148, 136, 65, 140, 6, 22, 100, 5, 32, 23]
    
    func aliceBob() -> (PublicKey, PublicKey) {
        let alicePath = NSBundle(forClass: CryptoBoxTests.self).pathForResource("alice", ofType: "key")!
        let bobPath = NSBundle(forClass: CryptoBoxTests.self).pathForResource("bob", ofType: "key")!
        
        //fix the permsisions on this key so we don't freak out the security goalie
        try! NSFileManager.defaultManager().setAttributes([NSFilePosixPermissions: NSNumber(short: 0o0600)], ofItemAtPath: alicePath)
        try! NSFileManager.defaultManager().setAttributes([NSFilePosixPermissions: NSNumber(short: 0o0600)], ofItemAtPath: bobPath)

        let alice = try! PublicKey(readFromFile: alicePath)
        let bob = try! PublicKey(readFromFile: bobPath)
        return (alice, bob)
    }
    
    func testCryptoBox() {
        let (alice, bob) = aliceBob()
        let cipher = try! crypto_box(knownPlaintext, to: alice, from: bob.secretKey!, nonce: notVeryNonce)
        print("\(cipher)")
        XCTAssert(cipher == knownCiphertext)
    }
    
    func testCryptoBoxOpen() {
        let (alice, bob) = aliceBob()
        let plain = try! crypto_box_open(knownCiphertext, to: alice.secretKey!, from: bob, nonce: notVeryNonce)
        XCTAssert(plain == knownPlaintext)
    }
    
}