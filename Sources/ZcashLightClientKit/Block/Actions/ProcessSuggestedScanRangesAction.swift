//
//  ProcessSuggestedScanRangesAction.swift
//  
//
//  Created by Lukáš Korba on 02.08.2023.
//

import Foundation

final class ProcessSuggestedScanRangesAction {
    let rustBackend: ZcashRustBackendWelding
    var service: LightWalletService
    let logger: Logger
    let metrics: SDKMetrics
    
    init(container: DIContainer) {
        service = container.resolve(LightWalletService.self)
        rustBackend = container.resolve(ZcashRustBackendWelding.self)
        logger = container.resolve(Logger.self)
        metrics = container.resolve(SDKMetrics.self)
    }
}

