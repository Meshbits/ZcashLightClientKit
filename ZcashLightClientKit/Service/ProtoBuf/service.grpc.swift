//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: service.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import GRPC
import NIO
import SwiftProtobuf


/// Usage: instantiate CompactTxStreamerClient, then call methods of this protocol to make API calls.
internal protocol CompactTxStreamerClientProtocol: GRPCClient {
  func getLatestBlock(
    _ request: ChainSpec,
    callOptions: CallOptions?
  ) -> UnaryCall<ChainSpec, BlockID>

  func getBlock(
    _ request: BlockID,
    callOptions: CallOptions?
  ) -> UnaryCall<BlockID, CompactBlock>

  func getBlockRange(
    _ request: BlockRange,
    callOptions: CallOptions?,
    handler: @escaping (CompactBlock) -> Void
  ) -> ServerStreamingCall<BlockRange, CompactBlock>

  func getTransaction(
    _ request: TxFilter,
    callOptions: CallOptions?
  ) -> UnaryCall<TxFilter, RawTransaction>

  func sendTransaction(
    _ request: RawTransaction,
    callOptions: CallOptions?
  ) -> UnaryCall<RawTransaction, SendResponse>

  func getTaddressTxids(
    _ request: TransparentAddressBlockFilter,
    callOptions: CallOptions?,
    handler: @escaping (RawTransaction) -> Void
  ) -> ServerStreamingCall<TransparentAddressBlockFilter, RawTransaction>

  func getTaddressBalance(
    _ request: AddressList,
    callOptions: CallOptions?
  ) -> UnaryCall<AddressList, Balance>

  func getTaddressBalanceStream(
    callOptions: CallOptions?
  ) -> ClientStreamingCall<Address, Balance>

  func getMempoolTx(
    _ request: Exclude,
    callOptions: CallOptions?,
    handler: @escaping (CompactTx) -> Void
  ) -> ServerStreamingCall<Exclude, CompactTx>

  func getTreeState(
    _ request: BlockID,
    callOptions: CallOptions?
  ) -> UnaryCall<BlockID, TreeState>

  func getAddressUtxos(
    _ request: GetAddressUtxosArg,
    callOptions: CallOptions?
  ) -> UnaryCall<GetAddressUtxosArg, GetAddressUtxosReplyList>

  func getAddressUtxosStream(
    _ request: GetAddressUtxosArg,
    callOptions: CallOptions?,
    handler: @escaping (GetAddressUtxosReply) -> Void
  ) -> ServerStreamingCall<GetAddressUtxosArg, GetAddressUtxosReply>

  func getLightdInfo(
    _ request: Empty,
    callOptions: CallOptions?
  ) -> UnaryCall<Empty, LightdInfo>

  func ping(
    _ request: Duration,
    callOptions: CallOptions?
  ) -> UnaryCall<Duration, PingResponse>

}

extension CompactTxStreamerClientProtocol {

  /// Return the height of the tip of the best chain
  ///
  /// - Parameters:
  ///   - request: Request to send to GetLatestBlock.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getLatestBlock(
    _ request: ChainSpec,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<ChainSpec, BlockID> {
    return self.makeUnaryCall(
      path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetLatestBlock",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions
    )
  }

  /// Return the compact block corresponding to the given block identifier
  ///
  /// - Parameters:
  ///   - request: Request to send to GetBlock.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getBlock(
    _ request: BlockID,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<BlockID, CompactBlock> {
    return self.makeUnaryCall(
      path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetBlock",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions
    )
  }

  /// Return a list of consecutive compact blocks
  ///
  /// - Parameters:
  ///   - request: Request to send to GetBlockRange.
  ///   - callOptions: Call options.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
  internal func getBlockRange(
    _ request: BlockRange,
    callOptions: CallOptions? = nil,
    handler: @escaping (CompactBlock) -> Void
  ) -> ServerStreamingCall<BlockRange, CompactBlock> {
    return self.makeServerStreamingCall(
      path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetBlockRange",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      handler: handler
    )
  }

  /// Return the requested full (not compact) transaction (as from zcashd)
  ///
  /// - Parameters:
  ///   - request: Request to send to GetTransaction.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getTransaction(
    _ request: TxFilter,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<TxFilter, RawTransaction> {
    return self.makeUnaryCall(
      path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetTransaction",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions
    )
  }

  /// Submit the given transaction to the Zcash network
  ///
  /// - Parameters:
  ///   - request: Request to send to SendTransaction.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func sendTransaction(
    _ request: RawTransaction,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<RawTransaction, SendResponse> {
    return self.makeUnaryCall(
      path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/SendTransaction",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions
    )
  }

  /// Return the txids corresponding to the given t-address within the given block range
  ///
  /// - Parameters:
  ///   - request: Request to send to GetTaddressTxids.
  ///   - callOptions: Call options.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
  internal func getTaddressTxids(
    _ request: TransparentAddressBlockFilter,
    callOptions: CallOptions? = nil,
    handler: @escaping (RawTransaction) -> Void
  ) -> ServerStreamingCall<TransparentAddressBlockFilter, RawTransaction> {
    return self.makeServerStreamingCall(
      path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetTaddressTxids",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      handler: handler
    )
  }

  /// Unary call to GetTaddressBalance
  ///
  /// - Parameters:
  ///   - request: Request to send to GetTaddressBalance.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getTaddressBalance(
    _ request: AddressList,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<AddressList, Balance> {
    return self.makeUnaryCall(
      path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetTaddressBalance",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions
    )
  }

  /// Client streaming call to GetTaddressBalanceStream
  ///
  /// Callers should use the `send` method on the returned object to send messages
  /// to the server. The caller should send an `.end` after the final message has been sent.
  ///
  /// - Parameters:
  ///   - callOptions: Call options.
  /// - Returns: A `ClientStreamingCall` with futures for the metadata, status and response.
  internal func getTaddressBalanceStream(
    callOptions: CallOptions? = nil
  ) -> ClientStreamingCall<Address, Balance> {
    return self.makeClientStreamingCall(
      path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetTaddressBalanceStream",
      callOptions: callOptions ?? self.defaultCallOptions
    )
  }

  /// Return the compact transactions currently in the mempool; the results
  /// can be a few seconds out of date. If the Exclude list is empty, return
  /// all transactions; otherwise return all *except* those in the Exclude list
  /// (if any); this allows the client to avoid receiving transactions that it
  /// already has (from an earlier call to this rpc). The transaction IDs in the
  /// Exclude list can be shortened to any number of bytes to make the request
  /// more bandwidth-efficient; if two or more transactions in the mempool
  /// match a shortened txid, they are all sent (none is excluded). Transactions
  /// in the exclude list that don't exist in the mempool are ignored.
  ///
  /// - Parameters:
  ///   - request: Request to send to GetMempoolTx.
  ///   - callOptions: Call options.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
  internal func getMempoolTx(
    _ request: Exclude,
    callOptions: CallOptions? = nil,
    handler: @escaping (CompactTx) -> Void
  ) -> ServerStreamingCall<Exclude, CompactTx> {
    return self.makeServerStreamingCall(
      path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetMempoolTx",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      handler: handler
    )
  }

  /// GetTreeState returns the note commitment tree state corresponding to the given block.
  /// See section 3.7 of the Zcash protocol specification. It returns several other useful
  /// values also (even though they can be obtained using GetBlock).
  /// The block can be specified by either height or hash.
  ///
  /// - Parameters:
  ///   - request: Request to send to GetTreeState.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getTreeState(
    _ request: BlockID,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<BlockID, TreeState> {
    return self.makeUnaryCall(
      path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetTreeState",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions
    )
  }

  /// Unary call to GetAddressUtxos
  ///
  /// - Parameters:
  ///   - request: Request to send to GetAddressUtxos.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getAddressUtxos(
    _ request: GetAddressUtxosArg,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<GetAddressUtxosArg, GetAddressUtxosReplyList> {
    return self.makeUnaryCall(
      path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetAddressUtxos",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions
    )
  }

  /// Server streaming call to GetAddressUtxosStream
  ///
  /// - Parameters:
  ///   - request: Request to send to GetAddressUtxosStream.
  ///   - callOptions: Call options.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
  internal func getAddressUtxosStream(
    _ request: GetAddressUtxosArg,
    callOptions: CallOptions? = nil,
    handler: @escaping (GetAddressUtxosReply) -> Void
  ) -> ServerStreamingCall<GetAddressUtxosArg, GetAddressUtxosReply> {
    return self.makeServerStreamingCall(
      path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetAddressUtxosStream",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      handler: handler
    )
  }

  /// Return information about this lightwalletd instance and the blockchain
  ///
  /// - Parameters:
  ///   - request: Request to send to GetLightdInfo.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getLightdInfo(
    _ request: Empty,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Empty, LightdInfo> {
    return self.makeUnaryCall(
      path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetLightdInfo",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions
    )
  }

  /// Testing-only
  ///
  /// - Parameters:
  ///   - request: Request to send to Ping.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func ping(
    _ request: Duration,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Duration, PingResponse> {
    return self.makeUnaryCall(
      path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/Ping",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions
    )
  }
}

internal final class CompactTxStreamerClient: CompactTxStreamerClientProtocol {
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions

  /// Creates a client for the cash.z.wallet.sdk.rpc.CompactTxStreamer service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  internal init(channel: GRPCChannel, defaultCallOptions: CallOptions = CallOptions()) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
  }
}

