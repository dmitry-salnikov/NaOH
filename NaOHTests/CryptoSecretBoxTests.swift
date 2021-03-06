//
//  CryptoSecretBoxTests.swift
//  SwiftSodium
//
//  Created by Drew Crawford on 8/15/15.
//  Copyright © 2015 DrewCrawfordApps. All rights reserved.
//  This file is part of NaOH.  It is subject to the license terms in the LICENSE
//  file found in the top level of this distribution
//  No part of NaOH, including this file, may be copied, modified,
//propagated, or distributed except according to the terms contained
//  in the LICENSE file.
import CarolineCore
@testable import NaOH


private let NotReallyNonce = Integer192Bit(array: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24])
private let known_ciphertext: [UInt8] = [238,208,130,110,75,188,8,14,80,51,115,51,112,13,233,240,85,118,104]
private let known_plaintext: [UInt8] = [0,1,2]

class EncryptTest: CarolineTest {
    func test() {
        let k = try! CryptoSecretBoxSecretKey(password: "My password", salt: "My salt is 32 characters   sjej", keySize: KeySizes.crypto_secretbox)
        let result = try! crypto_secretbox_open(known_ciphertext, key: k, nonce: NotReallyNonce)
        self.assert(result, equals: known_plaintext)
    }
}

class DecryptTest: CarolineTest {
    func test() {
        let k = try! CryptoSecretBoxSecretKey(password: "My password", salt: "My salt is 32 characters   sjej", keySize: KeySizes.crypto_secretbox)
        let result = try! crypto_secretbox_open(known_ciphertext, key: k, nonce: NotReallyNonce)
        self.assert(result, equals: known_plaintext)
    }
}

class BadDecrypt: CarolineTest {
    func test() {
        let k = try! CryptoSecretBoxSecretKey(password: "My password", salt: "My salt is 32 characters   sjej", keySize: KeySizes.crypto_secretbox)
        var badCipher = known_ciphertext
        badCipher[3] = 2
        do {
            let _ = try crypto_secretbox_open(badCipher, key: k, nonce: NotReallyNonce)
            self.fail()
        }
        catch NaOHError.CryptoSecretBoxError { /* */ }
        catch { self.fail("\(error)") }
    }
}
