//
//  KeyTests.swift
//  SwiftSodium
//
//  Created by Drew Crawford on 8/15/15.
//  Copyright © 2015 DrewCrawfordApps. All rights reserved.
//  This file is part of NaOH.  It is subject to the license terms in the LICENSE
//  file found inthe top level of this distribution
//  No part of NaOH, including this file, may be copied, modified,
//  propagated, or distributed except according to the terms contained
//  inthe LICENSE file.

import Foundation
import XCTest
@testable import NaOH

class KeyTests : XCTestCase {
    func testKey() {
        let k = try! Key(password: "My password", salt: "My salt is 32 characters   sjej")
        XCTAssert(k.hash == "C2D877E295C0070384F1486F18CE136C72B050EFAB71D2830260F2A062B9E2AC")
    }
    
    func testZeroImport() {
        var k : [UInt8] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]
        let key = Key(zeroingMemory: &k)
        XCTAssert(k == [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])
    }
}

