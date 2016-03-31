//  This file is part of NaOH.  It is subject to the license terms in the LICENSE
//  file found in the top level of this distribution
//  No part of NaOH, including this file, may be copied, modified,
//  propagated, or distributed except according to the terms contained
//  in the LICENSE file.

import Foundation

public struct CryptoSigningSecretKey: SecretKey  {
    public let keyImpl_: KeyImplProtocol_
    public let publicKey: CryptoSigningPublicKey
    public init() {
        let localKeyImpl = KeyImpl(uninitializedSize: crypto_sign_secretkeybytes())
        defer { try! localKeyImpl.lock() }
        self.keyImpl_ = localKeyImpl
        var publicKeyBytes = [UInt8](repeating: 0, count: Int(crypto_sign_publickeybytes()))
        publicKeyBytes.withUnsafeMutableBufferPointer { (inout ptr: UnsafeMutableBufferPointer<UInt8>) -> () in
            if crypto_sign_keypair(ptr.baseAddress, localKeyImpl.addr) != 0 {
                preconditionFailure("Can't generate keypair")
            }
        }
        self.publicKey = CryptoSigningPublicKey(bytes: publicKeyBytes)
    }
    public func saveToFile(file: String) throws {
        try self._saveToFile(file, userData: publicKey.bytes)
    }
    public init(readFromFile file: String) throws {
        var userData: [UInt8] = []
        self.keyImpl_ = try KeyImpl(readFromFile: file, userDataBytes: crypto_sign_publickeybytes(), userData: &userData)
        precondition(userData.count == crypto_sign_publickeybytes())
        self.publicKey = CryptoSigningPublicKey(bytes: userData)
        precondition(self.keyImpl__.size == crypto_sign_secretkeybytes())
    }
}

public struct CryptoSigningPublicKey: PublicKey {
    public let bytes: [UInt8]
    public init(humanReadableString: String) {
        let data = NSData(base64EncodedString: humanReadableString, options: NSDataBase64DecodingOptions())!
        var array = [UInt8](repeating: 0, count: data.length)
        data.getBytes(&array,length:data.length)
        self.init(bytes: array)
    }
    public init(bytes: [UInt8]) {
        self.bytes = bytes
    }
}

public func crypto_sign_detached(message: [UInt8], key: CryptoSigningSecretKey) -> [UInt8] {
    var sig = [UInt8](repeating: 0, count: Int(crypto_sign_bytes()))
    //crypto_sign_detached(<#T##sig: UnsafeMutablePointer<UInt8>##UnsafeMutablePointer<UInt8>#>, <#T##siglen_p: UnsafeMutablePointer<UInt64>##UnsafeMutablePointer<UInt64>#>, <#T##m: UnsafePointer<UInt8>##UnsafePointer<UInt8>#>, <#T##mlen: UInt64##UInt64#>, <#T##sk: UnsafePointer<UInt8>##UnsafePointer<UInt8>#>)
    try! key.keyImpl__.unlock()
    defer { try! key.keyImpl__.lock() }
    let result = crypto_sign_detached(&sig, UnsafeMutablePointer(nil), message, UInt64(message.count), key.keyImpl__.addr)
    precondition(result == 0)
    return sig
}

public func crypto_sign_verify_detached(signature signature: [UInt8], message: [UInt8], key: CryptoSigningPublicKey) throws {
    precondition(key.bytes.count == Int(crypto_sign_PUBLICKEYBYTES))
    let result = crypto_sign_verify_detached(signature, message, UInt64(message.count), key.bytes)
    if result != 0 { throw NaOHError.CryptoSignError }
}