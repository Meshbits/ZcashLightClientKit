//
//  ProcessSuggestedScanRangesAction.swift
//  
//
//  Created by Lukáš Korba on 02.08.2023.
//

import Foundation

final class ProcessSuggestedScanRangesAction {
    let rustBackend: ZcashRustBackendWelding
    let service: LightWalletService
    let logger: Logger
    
    init(container: DIContainer) {
        service = container.resolve(LightWalletService.self)
        rustBackend = container.resolve(ZcashRustBackendWelding.self)
        logger = container.resolve(Logger.self)
    }
}

extension ProcessSuggestedScanRangesAction: Action {
    var removeBlocksCacheWhenFailed: Bool { false }

    func run(with context: ActionContext, didUpdate: @escaping (CompactBlockProcessor.Event) async -> Void) async throws -> ActionContext {
        logger.info("Getting the suggested scan ranges from the wallet database.")
        let scanRanges = try await rustBackend.suggestScanRanges()

        if let firstRange = scanRanges.first {
            let rangeStartExclusive = firstRange.range.lowerBound - 1
            let rangeEndInclusive = firstRange.range.upperBound - 1
            
            let syncControlData = SyncControlData(
                latestBlockHeight: rangeEndInclusive,
                latestScannedHeight: rangeStartExclusive,
                firstUnenhancedHeight: rangeStartExclusive + 1
            )
            
            logger.debug("""
                Init numbers:
                latestBlockHeight [BC]:         \(rangeEndInclusive)
                latestScannedHeight [DB]:       \(rangeStartExclusive)
                firstUnenhancedHeight [DB]:     \(rangeStartExclusive + 1)
                """)

            await context.update(lastScannedHeight: rangeStartExclusive)
            await context.update(lastDownloadedHeight: rangeStartExclusive)
            await context.update(syncControlData: syncControlData)

            // the total progress range is computed only for the first time
            // as a sum of all ranges
            let totalProgressRange = await context.totalProgressRange
            if totalProgressRange.lowerBound == 0 && totalProgressRange.upperBound == 0 {
                var minHeight = Int.max
                var maxHeight = 0
                scanRanges.forEach { range in
                    if range.range.lowerBound < minHeight { minHeight = range.range.lowerBound }
                    if range.range.upperBound > maxHeight { maxHeight = range.range.upperBound }
                }
                
                logger.info("Setting the total range for Spend before Sync to \(minHeight...maxHeight).")
                await context.update(totalProgressRange: minHeight...maxHeight)
            }

            // If there is a range of blocks that needs to be verified, it will always
            // be returned as the first element of the vector of suggested ranges.
            if firstRange.priority == .verify {
                await context.update(requestedRewindHeight: rangeStartExclusive + 1)
                await context.update(state: .rewind)
            } else {
                await context.update(state: .download)
            }
        } else {
            await context.update(state: .finished)
        }
        
        return context
    }

    func stop() async { }
}
