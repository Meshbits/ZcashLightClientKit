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

// swiftlint:disable line_length force_try
enum DemoAppConfig {
    static var host = "lightd.pirate.black"
    static var port: Int = 443
    static var birthdayHeight: BlockHeight = 139000

    static var seed = try! Mnemonic.deterministicSeedBytes(from: "eyebrow luggage boy enemy stamp lunch middle slab mother bacon confirm again tourist idea grain pink angle comic question rabbit pole train dragon grape")
    static var address: String {
        "\(host):\(port)"
    }
    
    static var processorConfig: CompactBlockProcessor.Configuration  = {
        CompactBlockProcessor.Configuration(
            cacheDb: try! cacheDbURLHelper(),
            dataDb: try! dataDbURLHelper(),
            spendParamsURL: try! spendParamsURLHelper(),
            outputParamsURL: try! outputParamsURLHelper(),
            walletBirthday: Self.birthdayHeight,
            network: kZcashNetwork
        )
    }()
    
    static var endpoint: LightWalletEndpoint {
        return LightWalletEndpoint(address: self.host, port: self.port, secure: true, streamingCallTimeoutInMillis: 10 * 60 * 60 * 1000)
    }
}

extension ZcashSDK {
    static var isMainnet: Bool {
        switch kZcashNetwork.networkType {
        case .mainnet:  return true
        case .testnet:  return false
        }
    }
}
