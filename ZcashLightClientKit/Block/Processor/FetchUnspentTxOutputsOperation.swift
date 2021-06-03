//
//  FetchUnspentTxOutputsOperation.swift
//  ZcashLightClientKit
//
//  Created by Francisco Gindre on 6/2/21.
//

import Foundation
class FetchUnspentTxOutputsOperation: ZcashOperation {
    
    enum FetchUTXOError: Error {
        case clearingFailed(_ error: Error?)
        case fetchFailed(error: Error)
    }
    override var isConcurrent: Bool { false }
    
    override var isAsynchronous: Bool { false }
    
    var fetchedUTXOsHandler: ((RefreshedUTXOs) -> Void)?
    
    private var accountRepository: AccountRepository
    private var downloader: CompactBlockDownloading
    private var rustbackend: ZcashRustBackendWelding.Type
    private var startHeight: BlockHeight
    private var dataDb: URL
    
    init(accountRepository: AccountRepository,  
         downloader: CompactBlockDownloading,
         rustbackend: ZcashRustBackendWelding.Type,
         dataDb: URL,
         startHeight: BlockHeight) {
        self.dataDb = dataDb
        self.accountRepository = accountRepository
        self.downloader = downloader
        self.rustbackend = rustbackend
        self.startHeight = startHeight
    }
    
    override func main() {
        guard !shouldCancel() else {
            cancel()
            return
        }
        
      
        do {
            let tAddresses = try accountRepository.getAll().map({ $0.transparentAddress })
            do {
                for tAddress in tAddresses {
                    guard try self.rustbackend.clearUtxos(dbData: dataDb, address: tAddress, sinceHeight: startHeight - 1) >= 0 else {
                        let rustError = rustbackend.lastError() ?? RustWeldingError.genericError(message: "attempted to clear utxos but -1 was returned")
                        
                        throw rustError
                    }
                }
            } catch {
                throw FetchUTXOError.clearingFailed(error)
            }
            
            let utxos = try downloader.fetchUnspentTransactionOutputs(tAddresses: tAddresses, startHeight: startHeight)
            
            let result = storeUTXOs(utxos, in: dataDb)
            
            self.fetchedUTXOsHandler?(result)
            
        } catch {
            self.fail(error: error)
        }
        
    }
    
    fileprivate func storeUTXOs(_ utxos: [UnspentTransactionOutputEntity], in dataDb: URL) -> RefreshedUTXOs {
        var refreshed = [UnspentTransactionOutputEntity]()
        var skipped = [UnspentTransactionOutputEntity]()
        for utxo in utxos {
            do {
                try self.rustbackend.putUnspentTransparentOutput(
                    dbData: dataDb,
                    address: utxo.address,
                    txid: utxo.txid.bytes,
                    index: utxo.index,
                    script: utxo.script.bytes,
                    value: Int64(utxo.valueZat),
                    height: utxo.height) ? refreshed.append(utxo) : skipped.append(utxo)
            } catch {
                LoggerProxy.error("failed to put utxo - error: \(error)")
                skipped.append(utxo)
            }
        }
        return (inserted: refreshed, skipped: skipped)
    }
}
