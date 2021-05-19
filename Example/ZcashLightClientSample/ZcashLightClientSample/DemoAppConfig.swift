//
//  DemoAppConfig.swift
//  ZcashLightClientSample
//
//  Created by Francisco Gindre on 10/31/19.
//  Copyright © 2019 Electric Coin Company. All rights reserved.
//

import Foundation
import ZcashLightClientKit
import MnemonicSwift
struct DemoAppConfig {
    static var host = ZcashSDK.isMainnet ? "lightd.meshbits.io" : "lightwalletd.testnet.electriccoin.co"
    static var port: Int = 9067
    static var birthdayHeight: BlockHeight = ZcashSDK.isMainnet ? 139000 : 1396051
    static var network = ZcashSDK.isMainnet ? ZcashNetwork.mainNet : ZcashNetwork.testNet
    static var seed = ZcashSDK.isMainnet ? try! Mnemonic.deterministicSeedBytes(from: "eyebrow luggage boy enemy stamp lunch middle slab mother bacon confirm again tourist idea grain pink angle comic question rabbit pole train dragon grape") : Array("testreferencealicetestreferencealice".utf8)
    static var address: String {
        "\(host):\(port)"
    }
    
    static var processorConfig: CompactBlockProcessor.Configuration {
        var config = CompactBlockProcessor.Configuration(cacheDb: try! __cacheDbURL(), dataDb: try! __dataDbURL())
        config.walletBirthday = self.birthdayHeight
        return config
    }
    
    static var endpoint: LightWalletEndpoint {
        return LightWalletEndpoint(address: self.host, port: self.port, secure: true)
    }
}


enum ZcashNetwork {
    case mainNet
    case testNet
}

