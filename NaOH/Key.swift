//
//  Key.swift
//  SwiftSodium
//
//  Created by Drew Crawford on 8/15/15.
//  Copyright © 2015 DrewCrawfordApps. All rights reserved.
//  This file is part of NaOH.  It is subject to the license terms in the LICENSE
//  file found in the top level of this distribution
//  No part of NaOH, including this file, may be copied, modified,
//  propagated, or distributed except according to the terms contained
//  in the LICENSE file.

import Foundation
/**A secure key storage class.

You should use this because:

1.  It can't be swapped to disk.
2.  There's a guard page making it more difficult for a C-like bug to access this key.
3.  It zeroes the memory upon delete
4.  It can only be read or written to when unlocked by SwiftSodium, not for other purposes.
*/
public final class Key {
    let addr : UnsafeMutablePointer<UInt8>
    var addrAsVoid : UnsafeMutablePointer<Void> {
        get {
            return unsafeBitCast(addr, UnsafeMutablePointer<Void>.self)
        }
    }
    
    let size: Int
    internal init(uninitializedSize: Int) {
        sodium_init_wrap()
        self.size = uninitializedSize
        addr = UnsafeMutablePointer<UInt8>(sodium_malloc(size))
    }
    
    deinit {
        sodium_free(addrAsVoid)
    }
    
    func lock() throws {
        if sodium_mprotect_noaccess(addrAsVoid) != 0 {
            throw NaOHError.ProtectionError
        }
    }
    
    func unlock() throws {
        if sodium_mprotect_readwrite(addrAsVoid) != 0 {
            throw NaOHError.ProtectionError
        }
    }
    
    /**Generates a unique hash of the key */
    var hash: String {
        get {
            try! unlock()
            defer { try! lock() }
            var hash = [UInt8](count: Int(crypto_generichash_BYTES), repeatedValue: 0)
            if crypto_generichash(&hash, hash.count, addr, UInt64(size), UnsafePointer(nil), 0) != 0 {
                preconditionFailure("Hash error")
            }
            var str = ""
            for char in hash {
                str += NSString(format: "%02X", char) as String
            }
            return str
        }
    }
}


extension Key: CustomStringConvertible {
    public var description: String {
        get {
            return "<SwiftSodium.Key hash: \(hash) >"
        }
    }
}

extension Key {
    public convenience init(password: String, salt: String) throws  {
        sodium_init_wrap()
        var saltBytes = salt.cStringUsingEncoding(NSUTF8StringEncoding)!
        assert(saltBytes.count == Int(crypto_pwhash_scryptsalsa208sha256_SALTBYTES))
        
        var bytes = password.cStringUsingEncoding(NSUTF8StringEncoding)!
        
        
        self.init(uninitializedSize: Int(crypto_box_SEEDBYTES))
        let saltPtr = saltBytes.withUnsafeBufferPointer { (saltPtr) -> UnsafePointer<UInt8> in
            return unsafeBitCast(saltPtr.baseAddress, UnsafePointer<UInt8>.self)
        }
        
        if crypto_pwhash_scryptsalsa208sha256(addr, UInt64(size), &bytes, UInt64(bytes.count - 1), saltPtr, crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_INTERACTIVE, Int(crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_INTERACTIVE)) != 0 {
            throw NaOHError.OOM
        }
        try lock()
    }
    
    /**Generates a random key */
    public convenience init(randomSize: Int) {
        sodium_init_wrap()
        self.init(uninitializedSize: randomSize)
        randombytes_buf(self.addrAsVoid, randomSize)
        try! lock()
    }
    
    public convenience init(forSecretBox _: Bool) {
        self.init(randomSize: Int(crypto_secretbox_KEYBYTES))
    }
}
