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

// swiftlint:disable force_try line_length
enum DemoAppConfig {
    struct SynchronizerInitData {
        let alias: ZcashSynchronizerAlias
        let birthday: BlockHeight
        let seed: [UInt8]
    }

    static let host = "lightd1.pirate.black"
    static let port: Int = 443

    static let defaultBirthdayHeight: BlockHeight = 139000

//    static let defaultSeed = try! Mnemonic.deterministicSeedBytes(from: """
//        wish puppy smile loan doll curve hole maze file ginger hair nose key relax knife witness cannon grab despair throw review deal slush frame
//        """)

    static let defaultSeed = try! Mnemonic.deterministicSeedBytes(from: "eyebrow luggage boy enemy stamp lunch middle slab mother bacon confirm again tourist idea grain pink angle comic question rabbit pole train dragon grape")

    static let otherSynchronizers: [SynchronizerInitData] = [
        SynchronizerInitData(
            alias: .custom("alt-sync-1"),
            birthday: 2270000,
            seed: try! Mnemonic.deterministicSeedBytes(from: "eyebrow luggage boy enemy stamp lunch middle slab mother bacon confirm again tourist idea grain pink angle comic question rabbit pole train dragon grape")
        ),
        SynchronizerInitData(
            alias: .custom("alt-sync-2"),
            birthday: 2270000,
            seed: try! Mnemonic.deterministicSeedBytes(from: "eyebrow luggage boy enemy stamp lunch middle slab mother bacon confirm again tourist idea grain pink angle comic question rabbit pole train dragon grape")
        )
    ]

    static var address: String {
        "\(host):\(port)"
    }

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
