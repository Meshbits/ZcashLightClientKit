//
//  TxResubmissionAction.swift
//
//
//  Created by Lukas Korba on 06-17-2024.
//

import Foundation

final class TxResubmissionAction {
    private enum Constants {
        static let thresholdToTrigger = TimeInterval(300.0)
    }
    
    var latestResolvedTime: TimeInterval = 0
    let transactionRepository: TransactionRepository
    let transactionEncoder: TransactionEncoder
    let logger: Logger

    init(container: DIContainer) {
        transactionRepository = container.resolve(TransactionRepository.self)
        transactionEncoder = container.resolve(TransactionEncoder.self)
        logger = container.resolve(Logger.self)
    }
}

