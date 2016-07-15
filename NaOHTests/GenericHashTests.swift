//
//  GenericHashTests.swift
//  NaOH
//
//  Created by Drew Crawford on 12/12/15.
//  Copyright © 2015 DrewCrawfordApps. All rights reserved.
//  This file is part of NaOH.  It is subject to the license terms in the LICENSE
//  file found in the top level of this distribution
//  No part of NaOH, including this file, may be copied, modified,
//  propagated, or distributed except according to the terms contained
//  in the LICENSE file.

import Foundation

import CarolineCore
@testable import NaOH

class GenericHash: CarolineTest {
    func test() {
        let a: [UInt8] = [0,1,2]
        let hash1 = a.genericHash
        let hash2 = a.genericHash
        self.assert(hash1, equals: hash2)
        self.assert(hash1, notEqual: ([0,1,3] as [UInt8]).genericHash)
        self.assert(hash1, notEqual: ([0,1,2,3] as [UInt8]).genericHash)
    }
}
