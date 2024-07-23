//
//  ServiceHelper.swift
//  gRPC-PoC
//
//  Created by Francisco Gindre on 29/08/2019.
//  Copyright © 2019 Electric Coin Company. All rights reserved.
//

import Foundation
import GRPC
import NIO
import NIOHPACK
import NIOTransportServices

typealias Channel = GRPC.GRPCChannel

extension LightdInfo: LightWalletdInfo {}
extension SendResponse: LightWalletServiceResponse {}

/**
Swift GRPC implementation of Lightwalletd service
*/
enum GRPCResult: Equatable {
    case success
    case error(_ error: LightWalletServiceError)
}

protocol CancellableCall {
    func cancel()
}

extension ServerStreamingCall: CancellableCall {
    func cancel() {
        self.cancel(promise: self.eventLoop.makePromise(of: Void.self))
    }
}

protocol LatestBlockHeightProvider {
    func latestBlockHeight(streamer: CompactTxStreamerAsyncClient) async throws -> BlockHeight
}

class LiveLatestBlockHeightProvider: LatestBlockHeightProvider {
    func latestBlockHeight(streamer: CompactTxStreamerAsyncClient) async throws -> BlockHeight {
        do {
            let blockID = try await streamer.getLatestBlock(ChainSpec())
            guard let blockHeight = Int(exactly: blockID.height) else {
                throw LightWalletServiceError.generalError(message: "error creating blockheight from BlockID \(blockID)")
            }
            return blockHeight
        } catch {
            let serviceError = error.mapToServiceError()
            throw ZcashError.serviceLatestBlockHeightFailed(serviceError)
        }
    }
}

protocol LatestLiteWalletGroupProvider {
    func liteWalletGroup(streamer: CompactTxStreamerAsyncClient, height: BlockHeight) async throws -> BlockHeight
}

class LiveLiteWalletGroupProvider: LatestLiteWalletGroupProvider {
    func liteWalletGroup(streamer: CompactTxStreamerAsyncClient, height: BlockHeight) async throws -> BlockHeight {
        do {
            let currentBlockID = BlockID(height: height)
            let returnBlockID = try await streamer.getLiteWalletBlockGroup(currentBlockID)
            guard let blockHeight = Int(exactly: returnBlockID.height) else {
                throw LightWalletServiceError.generalError(message: "error creating blockheight from BlockID \(returnBlockID)")
            }
            return blockHeight
        } catch {
            let serviceError = error.mapToServiceError()
            throw ZcashError.serviceLatestBlockHeightFailed(serviceError)
        }
    }
}

class LightWalletGRPCService {
    let channel: Channel
    let connectionManager: ConnectionStatusManager
    let compactTxStreamer: CompactTxStreamerAsyncClient
    let singleCallTimeout: TimeLimit
    let streamingCallTimeout: TimeLimit
    var latestBlockHeightProvider: LatestBlockHeightProvider = LiveLatestBlockHeightProvider()
    var latestLiteWalletGroupProvider: LatestLiteWalletGroupProvider = LiveLiteWalletGroupProvider()

    var connectionStateChange: ((_ from: ConnectionState, _ to: ConnectionState) -> Void)? {
        get { connectionManager.connectionStateChange }
        set { connectionManager.connectionStateChange = newValue }
    }

    let queue: DispatchQueue
    
    convenience init(endpoint: LightWalletEndpoint) {
        self.init(
            host: endpoint.host,
            port: endpoint.port,
            secure: endpoint.secure,
            singleCallTimeout: endpoint.singleCallTimeoutInMillis,
            streamingCallTimeout: endpoint.streamingCallTimeoutInMillis
        )
    }

    /// Inits a connection to a Lightwalletd service to the given
    /// - Parameters:
    ///  - host: the hostname of the lightwalletd server
    ///  - port: port of the server. Default is 9067
    ///  - secure: whether this server is TLS or plaintext. default True (TLS)
    ///  - singleCallTimeout: Timeout for unary calls in milliseconds.
    ///  - streamingCallTimeout: Timeout for streaming calls in milliseconds.
    init(
        host: String,
        port: Int = 9067,
        secure: Bool = true,
        singleCallTimeout: Int64,
        streamingCallTimeout: Int64
    ) {
        self.connectionManager = ConnectionStatusManager()
        self.queue = DispatchQueue.init(label: "LightWalletGRPCService")
        self.streamingCallTimeout = TimeLimit.timeout(.milliseconds(streamingCallTimeout))
        self.singleCallTimeout = TimeLimit.timeout(.milliseconds(singleCallTimeout))

        let connectionBuilder = secure ?
        ClientConnection.usingPlatformAppropriateTLS(for: NIOTSEventLoopGroup(loopCount: 1, defaultQoS: .default)) :
        ClientConnection.insecure(group: NIOTSEventLoopGroup(loopCount: 1, defaultQoS: .default))

        let channel = connectionBuilder
            .withConnectivityStateDelegate(connectionManager, executingOn: queue)
            .connect(host: host, port: port)

        self.channel = channel
        
        compactTxStreamer = CompactTxStreamerAsyncClient(
            channel: self.channel,
            defaultCallOptions: Self.callOptions(
                timeLimit: self.singleCallTimeout
            )
        )
    }

    deinit {
        _ = channel.close()
        _ = compactTxStreamer.channel.close()
    }

    func stop() {
        _ = channel.close()
    }

    func latestBlock() async throws -> BlockID {
        do {
            return try await compactTxStreamer.getLatestBlock(ChainSpec())
        } catch {
            let serviceError = error.mapToServiceError()
            throw ZcashError.serviceLatestBlockFailed(serviceError)
        }
    }

    static func callOptions(timeLimit: TimeLimit) -> CallOptions {
        CallOptions(
            customMetadata: HPACKHeaders(),
            timeLimit: timeLimit,
            messageEncoding: .disabled,
            requestIDProvider: .autogenerated,
            requestIDHeader: nil,
            cacheable: false
        )
    }
}

// MARK: - LightWalletService

extension LightWalletGRPCService: LightWalletService {
    
    func getLiteWalletBlockGroup(height: BlockHeight) async throws -> BlockHeight {
        try await latestLiteWalletGroupProvider.liteWalletGroup(streamer: compactTxStreamer, height: height)
    }
    
    func getInfo() async throws -> LightWalletdInfo {
        do {
            return try await compactTxStreamer.getLightdInfo(Empty())
        } catch {
            let serviceError = error.mapToServiceError()
            throw ZcashError.serviceGetInfoFailed(serviceError)
        }
    }
    
    func latestBlockHeight() async throws -> BlockHeight {
        try await latestBlockHeightProvider.latestBlockHeight(streamer: compactTxStreamer)
    }
    
    func blockRange(_ range: CompactBlockRange) -> AsyncThrowingStream<ZcashCompactBlock, Error> {
        let stream = compactTxStreamer.getBlockRange(range.blockRange())
        var iterator = stream.makeAsyncIterator()
        
        return AsyncThrowingStream() {
            do {
                guard let block = try await iterator.next() else { return nil }
                return ZcashCompactBlock(compactBlock: block)
            } catch {
                let serviceError = error.mapToServiceError()
                throw ZcashError.serviceBlockRangeFailed(serviceError)
            }
        }
    }
    
    func submit(spendTransaction: Data) async throws -> LightWalletServiceResponse {
        do {
            let transaction = RawTransaction.with { $0.data = spendTransaction }
            return try await compactTxStreamer.sendTransaction(transaction)
        } catch {
            let serviceError = error.mapToServiceError()
            throw ZcashError.serviceSubmitFailed(serviceError)
        }
    }
    
    func fetchTransaction(txId: Data) async throws -> ZcashTransaction.Fetched {
        var txFilter = TxFilter()
        txFilter.hash = txId
        
        do {
            let rawTx = try await compactTxStreamer.getTransaction(txFilter)
            return ZcashTransaction.Fetched(rawID: txId, minedHeight: BlockHeight(rawTx.height), raw: rawTx.data)
        } catch {
            let serviceError = error.mapToServiceError()
            throw ZcashError.serviceFetchTransactionFailed(serviceError)
        }
    }

    func fetchUTXOs(for tAddress: String, height: BlockHeight) -> AsyncThrowingStream<UnspentTransactionOutputEntity, Error> {
        return fetchUTXOs(for: [tAddress], height: height)
    }

    func fetchUTXOs(
        for tAddresses: [String],
        height: BlockHeight
    ) -> AsyncThrowingStream<UnspentTransactionOutputEntity, Error> {
        guard !tAddresses.isEmpty else {
            return AsyncThrowingStream { continuation in continuation.finish() }
        }
        
        let args = GetAddressUtxosArg.with { utxoArgs in
            utxoArgs.addresses = tAddresses
            utxoArgs.startHeight = UInt64(height)
        }
        let stream = compactTxStreamer.getAddressUtxosStream(args)
        var iterator = stream.makeAsyncIterator()

        return AsyncThrowingStream() {
            do {
                guard let reply = try await iterator.next() else { return nil }
                return UTXO(
                    address: reply.address,
                    prevoutTxId: reply.txid,
                    prevoutIndex: Int(reply.index),
                    script: reply.script,
                    valueZat: Int(reply.valueZat),
                    height: Int(reply.height)
                )
            } catch {
                let serviceError = error.mapToServiceError()
                throw ZcashError.serviceFetchUTXOsFailed(serviceError)
            }
        }
    }
    
    func blockStream(
        startHeight: BlockHeight,
        endHeight: BlockHeight
    ) -> AsyncThrowingStream<ZcashCompactBlock, Error> {
        let stream = compactTxStreamer.getBlockRange(
            BlockRange(
                startHeight: startHeight,
                endHeight: endHeight
            ),
            callOptions: Self.callOptions(timeLimit: self.streamingCallTimeout)
        )
        var iterator = stream.makeAsyncIterator()

        return AsyncThrowingStream() {
            do {
                guard let compactBlock = try await iterator.next() else { return nil }
                return ZcashCompactBlock(compactBlock: compactBlock)
            } catch {
                let serviceError = error.mapToServiceError()
                throw ZcashError.serviceBlockStreamFailed(serviceError)
            }
        }
    }
    
    func getSubtreeRoots(_ request: GetSubtreeRootsArg) -> AsyncThrowingStream<SubtreeRoot, Error> {
        let stream = compactTxStreamer.getSubtreeRoots(request)
        var iterator = stream.makeAsyncIterator()
        
        return AsyncThrowingStream() {
            do {
                guard let subtreeRoot = try await iterator.next() else { return nil }
                return subtreeRoot
            } catch {
                let serviceError = error.mapToServiceError()
                throw ZcashError.serviceSubtreeRootsStreamFailed(serviceError)
            }
        }
    }

    func getTreeState(_ id: BlockID) async throws -> TreeState {
        try await compactTxStreamer.getTreeState(id)
    }

    func closeConnection() {
        _ = channel.close()
    }
}

// MARK: - Extensions

extension ConnectivityState {
    func toConnectionState() -> ConnectionState {
        switch self {
        case .connecting:
            return .connecting
        case .idle:
            return .idle
        case .ready:
            return .online
        case .shutdown:
            return .shutdown
        case .transientFailure:
            return .reconnecting
        }
    }
}

extension TimeAmount {
    static let singleCallTimeout = TimeAmount.seconds(30)
    static let streamingCallTimeout = TimeAmount.minutes(10)
}

extension CallOptions {
    static var lwdCall: CallOptions {
        CallOptions(
            customMetadata: HPACKHeaders(),
            timeLimit: .timeout(.singleCallTimeout),
            messageEncoding: .disabled,
            requestIDProvider: .autogenerated,
            requestIDHeader: nil,
            cacheable: false
        )
    }
}

extension Error {
    func mapToServiceError() -> LightWalletServiceError {
        guard let grpcError = self as? GRPCStatusTransformable else {
            return LightWalletServiceError.genericError(error: self)
        }
        
        return LightWalletServiceError.mapCode(grpcError.makeGRPCStatus())
    }
}

extension LightWalletServiceError {
    static func mapCode(_ status: GRPCStatus) -> LightWalletServiceError {
        switch status.code {
        case .ok:
            return LightWalletServiceError.unknown
        case .cancelled:
            return LightWalletServiceError.userCancelled
        case .unknown:
            return LightWalletServiceError.generalError(message: status.message ?? "GRPC unknown error contains no message")
        case .deadlineExceeded:
            return LightWalletServiceError.timeOut
        default:
            return LightWalletServiceError.genericError(error: status)
        }
    }
}

class ConnectionStatusManager: ConnectivityStateDelegate {
    var connectionStateChange: ((_ from: ConnectionState, _ to: ConnectionState) -> Void)?
    init() { }

    func connectivityStateDidChange(from oldState: ConnectivityState, to newState: ConnectivityState) {
        connectionStateChange?(oldState.toConnectionState(), newState.toConnectionState())
    }
}
