//
//  ScanAction.swift
//  
//
//  Created by Michal Fousek on 05.05.2023.
//

import Foundation

final class ScanAction {
    enum Constants {
        static let reportDelay = 5
    }
    
    let configProvider: CompactBlockProcessor.ConfigProvider
    let blockScanner: BlockScanner
    let rustBackend: ZcashRustBackendWelding
    var latestBlocksDataProvider: LatestBlocksDataProvider
    let logger: Logger
    var progressReportReducer = 0

    init(container: DIContainer, configProvider: CompactBlockProcessor.ConfigProvider) {
        self.configProvider = configProvider
        blockScanner = container.resolve(BlockScanner.self)
        rustBackend = container.resolve(ZcashRustBackendWelding.self)
        latestBlocksDataProvider = container.resolve(LatestBlocksDataProvider.self)
        logger = container.resolve(Logger.self)
    }

    private func update(context: ActionContext) async -> ActionContext {
        await context.update(state: .clearAlreadyScannedBlocks)
        return context
    }
}


private extension ScanAction {
    func isContinuityError(_ errorMsg: String) -> Bool {
        errorMsg.contains("The parent hash of proposed block does not correspond to the block hash at height")
        || errorMsg.contains("Block height discontinuity at height")
        || errorMsg.contains("note commitment tree size provided by a compact block did not match the expected size at height")
    }
}
