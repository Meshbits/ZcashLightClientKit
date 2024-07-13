//
//  TransactionRepository.swift
//  PirateLightClientKit
//
//  Created by Francisco Gindre on 11/16/19.
//

import Foundation
import SQLite

protocol TransactionRepository {
    func closeDBConnection()
    func countAll() async throws -> Int
    func countUnmined() async throws -> Int
    func blockForHeight(_ height: BlockHeight) async throws -> Block?
    func lastScannedHeight() async throws -> BlockHeight
    func lastScannedBlock() async throws -> Block?
    func isInitialized() async throws -> Bool
    func find(id: Int) async throws -> ZcashTransaction.Overview
    func find(rawID: Data) async throws -> ZcashTransaction.Overview
    func find(offset: Int, limit: Int, kind: TransactionKind) async throws -> [ZcashTransaction.Overview]
    func find(in range: CompactBlockRange, limit: Int, kind: TransactionKind) async throws -> [ZcashTransaction.Overview]
    func find(from: ZcashTransaction.Overview, limit: Int, kind: TransactionKind) async throws -> [ZcashTransaction.Overview]
    func findPendingTransactions(latestHeight: BlockHeight, offset: Int, limit: Int) async throws -> [ZcashTransaction.Overview]
    func findReceived(offset: Int, limit: Int) async throws -> [ZcashTransaction.Overview]
    func findSent(offset: Int, limit: Int) async throws -> [ZcashTransaction.Overview]
    func findMemos(for transaction: ZcashTransaction.Overview) async throws -> [Memo]
    func getRecipients(for id: Int) async throws -> [TransactionRecipient]
    func getTransactionOutputs(for id: Int) async throws -> [ZcashTransaction.Output]
}


protocol BlockDao {
    func latestBlockHeight() throws -> BlockHeight
    func latestBlock() throws -> Block?
    func block(at height: BlockHeight) throws -> Block?
}

struct Block: Codable {
    enum CodingKeys: String, CodingKey {
        case height
        case hash
        case time
        case saplingTree = "sapling_tree"
    }

    enum TableStructure {
        static let height = Expression<Int>(Block.CodingKeys.height.rawValue)
        static let hash = Expression<Blob>(Block.CodingKeys.hash.rawValue)
        static let time = Expression<Int>(Block.CodingKeys.time.rawValue)
        static let saplingTree = Expression<Blob>(Block.CodingKeys.saplingTree.rawValue)
    }

    let height: BlockHeight
    let hash: Data
    let time: Int
    let saplingTree: Data
    
    static let table = Table("blocks")
}

class BlockSQLDAO: BlockDao {
    let dbProvider: ConnectionProvider
    let table: Table
    let height = Expression<Int>("height")

    init(dbProvider: ConnectionProvider) {
        self.dbProvider = dbProvider
        self.table = Table("Blocks")
    }

    /// - Throws:
    ///     - `blockDAOCantDecode` if block data loaded from DB can't be decoded to `Block` object.
    ///     - `blockDAOBlock` if sqlite query to load block metadata failed.
    func block(at height: BlockHeight) throws -> Block? {
        do {
            return try dbProvider
                .connection()
                .prepare(Block.table.filter(Block.TableStructure.height == height).limit(1))
                .map {
                    do {
                        return try $0.decode()
                    } catch {
                        throw ZcashError.blockDAOCantDecode(error)
                    }
                }
                .first
        } catch {
            if let error = error as? ZcashError {
                throw error
            } else {
                throw ZcashError.blockDAOBlock(error)
            }
        }
    }

    /// - Throws: `blockDAOLatestBlockHeight` if sqlite to fetch height fails.
    func latestBlockHeight() throws -> BlockHeight {
        do {
            return try dbProvider.connection().scalar(table.select(height.max)) ?? BlockHeight.empty()
        } catch {
            throw ZcashError.blockDAOLatestBlockHeight(error)
        }
    }
    
    func latestBlock() throws -> Block? {
        do {
            return try dbProvider
                .connection()
                .prepare(Block.table.order(height.desc).limit(1))
                .map {
                    do {
                        return try $0.decode()
                    } catch {
                        throw ZcashError.blockDAOLatestBlockCantDecode(error)
                    }
                }
                .first
        } catch {
            if let error = error as? ZcashError {
                throw error
            } else {
                throw ZcashError.blockDAOLatestBlock(error)
            }
        }
    }
}

extension BlockSQLDAO: BlockRepository {
    func lastScannedBlockHeight() -> BlockHeight {
        (try? self.latestBlockHeight()) ?? BlockHeight.empty()
    }
}
