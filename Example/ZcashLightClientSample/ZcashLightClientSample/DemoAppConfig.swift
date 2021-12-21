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
    static var host = "lightd.pirate.black"
    static var port: Int = 443
    static var birthdayHeight: BlockHeight = 139000
    static var network = ZcashNetwork.mainNet
    static var seed = try! Mnemonic.deterministicSeedBytes(from: "eyebrow luggage boy enemy stamp lunch middle slab mother bacon confirm again tourist idea grain pink angle comic question rabbit pole train dragon grape")
    static var address: String {
        "\(host):\(port)"
    }
    
    static var processorConfig: CompactBlockProcessor.Configuration  = {
        CompactBlockProcessor.Configuration(cacheDb: try! __cacheDbURL(), dataDb: try! __dataDbURL(), walletBirthday: Self.birthdayHeight, network: ZCASH_NETWORK)
    }()
    
    static var endpoint: LightWalletEndpoint {
        return LightWalletEndpoint(address: self.host, port: self.port, secure: true)
    }
}


extension ZcashSDK {
    static var isMainnet: Bool {
        switch ZCASH_NETWORK.networkType {
        case .mainnet:
            return true
        case .testnet:
            return false
        }
    }
}
