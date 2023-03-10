//
//  Transaction.swift
// 
//  Created by Scott on 2022/5/18.
//  Copyright © 2022 portto. All rights reserved.
//

import Foundation
import Cadence
import CryptoSwift

/// A full transaction object containing a payload and signatures.
public struct Transaction: Equatable {

    /// The UTF-8 encoded Cadence source code that defines the execution logic for this transaction.
    public var script: Data

    /// A list of Cadence values passed into this transaction.
    /// Each argument is encoded as JSON-CDC bytes.
    public private(set) var arguments: [Data]

    /// A reference to the block used to calculate the expiry of this transaction.
    ///
    /// A transaction is considered expired if it is submitted to Flow after refBlock + N, where N
    /// is a constant defined by the network.
    ///
    /// For example, if a transaction references a block with height of X and the network limit is 10,
    /// a block with height X+10 is the last block that is allowed to include this transaction.
    public var referenceBlockId: Identifier

    /// The maximum number of computational units that can be used to execute this transaction.
    public var gasLimit: UInt64

    /// ProposalKey is the account key used to propose this transaction.
    ///
    /// A proposal key references a specific key on an account, along with an up-to-date
    /// sequence number for that key. This sequence number is used to prevent replay attacks.
    ///
    /// Find more information about sequence numbers here: https://docs.onflow.org/concepts/transaction-signing/#sequence-numbers
    public private(set) var proposalKey: ProposalKey

    /// The account that pays the fee for this transaction.
    ///
    /// Find more information about the payer role here: https://docs.onflow.org/concepts/transaction-signing/#signer-roles
    public private(set) var payer: Address

    /// A list of the accounts that are authorizing this transaction to
    /// mutate to their on-chain account state.
    ///
    /// Find more information about the authorizer role here: https://docs.onflow.org/concepts/transaction-signing/#signer-roles
    public var authorizers: [Address]

    /// A list of signatures generated by the proposer and authorizer roles.
    ///
    /// A payload signature is generated over the inner portion of the transaction (TransactionDomainTag + payload).
    ///
    /// You can find more information about transaction signatures here: https://docs.onflow.org/concepts/transaction-signing/#anatomy-of-a-transaction
    public private(set) var payloadSignatures: [Signature]

    /// A list of signatures generated by the payer role.
    ///
    /// An envelope signature is generated over the outer portion of the transaction (TransactionDomainTag + payload + payloadSignatures).
    ///
    /// Find more information about transaction signatures here: https://docs.onflow.org/concepts/transaction-signing/#anatomy-of-a-transaction
    public private(set) var envelopeSignatures: [Signature]

    /// The canonical SHA3-256 hash of this transaction.
    public var id: Identifier {
        let message = encode()
        let hash = message.sha3(.sha256)
        return Identifier(data: hash)
    }

    public init(
        script: Data,
        referenceBlockId: Identifier,
        gasLimit: UInt64 = 9999,
        proposalKey: ProposalKey,
        payer: Address,
        authorizers: [Address] = [],
        payloadSignatures: [Signature] = [],
        envelopeSignatures: [Signature] = []
    ) {
        self.script = script
        self.arguments = []
        self.referenceBlockId = referenceBlockId
        self.gasLimit = gasLimit
        self.proposalKey = proposalKey
        self.payer = payer
        self.authorizers = authorizers
        self.payloadSignatures = payloadSignatures
        self.envelopeSignatures = envelopeSignatures
    }

    public init(
        script: Data,
        arguments: [Cadence.Argument],
        referenceBlockId: Identifier,
        gasLimit: UInt64 = 9999,
        proposalKey: ProposalKey,
        payer: Address,
        authorizers: [Address] = [],
        payloadSignatures: [Signature] = [],
        envelopeSignatures: [Signature] = []
    ) throws {
        self.init(
            script: script,
            referenceBlockId: referenceBlockId,
            gasLimit: gasLimit,
            proposalKey: proposalKey,
            payer: payer,
            authorizers: authorizers,
            payloadSignatures: payloadSignatures,
            envelopeSignatures: envelopeSignatures)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        self.arguments = try arguments.map { try encoder.encode($0) }
    }

    init(_ value: Flow_Entities_Transaction) {
        self.script = value.script
        self.arguments = value.arguments
        self.referenceBlockId = Identifier(data: value.referenceBlockID)
        self.gasLimit = value.gasLimit
        self.proposalKey = ProposalKey(value.proposalKey)
        self.payer = Address(data: value.payer)
        self.authorizers = value.authorizers.map { Address(data: $0) }
        self.payloadSignatures = []
        self.envelopeSignatures = []
        value.payloadSignatures.forEach {
            addPayloadSignature(
                address: Address(data: $0.address),
                keyIndex: Int($0.keyID),
                signature: $0.signature)
        }
        value.envelopeSignatures.forEach {
            addEnvelopeSignature(
                address: Address(data: $0.address),
                keyIndex: Int($0.keyID),
                signature: $0.signature)
        }
    }

    public func getArugment(at index: Int) throws -> Cadence.Argument {
        return try JSONDecoder().decode(Cadence.Argument.self, from: arguments[index])
    }

    /// Adds a Cadence argument to this transaction.
    public mutating func addArgument(_ argument: Cadence.Argument) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        let data = try encoder.encode(argument)
        arguments.append(data)
    }

    /// Adds Cadence arguments to this transaction.
    public mutating func addArguments(_ arguments: [Cadence.Argument]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        let argumentDatas = try arguments.map { try encoder.encode($0) }
        self.arguments.append(contentsOf: argumentDatas)
    }

    /// Adds a raw JSON-CDC encoded argument to this transaction.
    public mutating func addRawArgument(_ argument: Data) {
        self.arguments.append(argument)
    }

    /// Adds raw JSON-CDC encoded arguments to this transaction.
    public mutating func addRawArguments(_ arguments: [Data]) {
        self.arguments = arguments
    }

    /// Sets the proposal key and sequence number for this transaction.
    ///
    /// The first two arguments specify the account key to be used, and the last argument is the sequence
    /// number being declared.
    public mutating func setProposalKey(address: Address, keyIndex: Int, sequenceNumber: UInt64) {
        proposalKey = ProposalKey(
            address: address,
            keyIndex: keyIndex,
            sequenceNumber: sequenceNumber)
        refreshSignerIndex()
    }

    /// Sets the payer account for this transaction.
    public mutating func setPayer(address: Address) {
        payer = address
        refreshSignerIndex()
    }

    /// Adds an authorizer account to this transaction.
    public mutating func addAuthorizer(address: Address) {
        self.authorizers.append(address)
        refreshSignerIndex()
    }

}

// MARK: - Signer
extension Transaction {

    /// signerList returns a list of unique accounts required to sign this transaction.
    ///
    /// The list is returned in the following order:
    /// 1. PROPOSER
    /// 2. PAYER
    /// 2. AUTHORIZERS (in insertion order)
    ///
    /// The only exception to the above ordering is for deduplication; if the same account
    /// is used in multiple signing roles, only the first occurrence is included in the list.
    private var signerList: [Address] {
        var signers: [Address] = []
        var seen = Set<Address>()

        if proposalKey.address != .emptyAddress,
           seen.contains(proposalKey.address) == false {
            signers.append(proposalKey.address)
            seen.insert(proposalKey.address)
        }
        if payer != .emptyAddress,
           seen.contains(payer) == false {
            signers.append(payer)
            seen.insert(payer)
        }
        authorizers.forEach {
            if seen.contains($0) == false {
                signers.append($0)
                seen.insert($0)
            }
        }
        return signers
    }

    private var signerMap: [Address: Int] {
        var signers: [Address: Int] = [:]
        for (index, signer) in signerList.enumerated() {
            signers[signer] = index
        }
        return signers
    }

    private mutating func refreshSignerIndex() {
        let signerMap = self.signerMap
        for (index, signature) in payloadSignatures.enumerated() {
            if let signerIndex = signerMap[signature.address] {
                payloadSignatures[index].signerIndex = signerIndex
            } else {
                payloadSignatures[index].signerIndex = -1
            }
        }
        for (index, signature) in envelopeSignatures.enumerated() {
            if let signerIndex = signerMap[signature.address] {
                envelopeSignatures[index].signerIndex = signerIndex
            } else {
                envelopeSignatures[index].signerIndex = -1
            }
        }
    }
}

// MARK: - Payload, Envelope
extension Transaction {

    /// Signs the transaction payload (TransactionDomainTag + payload)  with the specified account key.
    ///
    /// The resulting signature is combined with the account address and key index before
    /// being added to the transaction.
    ///
    /// This function returns an error if the signature cannot be generated.
    public mutating func signPayload(
        address: Address,
        keyIndex: Int,
        signer: Signer
    ) throws {
        let signature = try signer.sign(message: encodedPayload)
        addPayloadSignature(
            address: address,
            keyIndex: keyIndex,
            signature: signature)
    }

    /// Signs the full transaction (TransactionDomainTag + payload + payload signatures) with the specified account key.
    ///
    /// The resulting signature is combined with the account address and key index before
    /// being added to the transaction.
    ///
    /// This function returns an error if the signature cannot be generated.
    public mutating func signEnvelope(
        address: Address,
        keyIndex: Int,
        signer: Signer
    ) throws {
        let signature = try signer.sign(message: encodedEnvelope)
        addEnvelopeSignature(
            address: address,
            keyIndex: keyIndex,
            signature: signature)
    }

    /// Adds a payload signature to the transaction for the given address and key index.
    public mutating func addPayloadSignature(address: Address, keyIndex: Int, signature: Data) {
        let signature = createSignature(
            address: address,
            keyIndex: keyIndex,
            signature: signature)
        payloadSignatures.append(signature)
        payloadSignatures.sort(by: transactionAreInIncreasingOrder)
        refreshSignerIndex()
    }

    /// Adds an envelope signature to the transaction for the given address and key index.
    public mutating func addEnvelopeSignature(address: Address, keyIndex: Int, signature: Data) {
        let signature = createSignature(
            address: address,
            keyIndex: keyIndex,
            signature: signature)
        envelopeSignatures.append(signature)
        envelopeSignatures.sort(by: transactionAreInIncreasingOrder)
        refreshSignerIndex()
    }

    private func transactionAreInIncreasingOrder(
        left: Signature,
        right: Signature
    ) -> Bool {
        if left.signerIndex == right.signerIndex {
            return left.keyIndex < right.keyIndex
        } else {
            return left.signerIndex < right.signerIndex
        }
    }

    private func createSignature(
        address: Address,
        keyIndex: Int,
        signature: Data
    ) -> Signature {
        let signerIndex = signerMap[address] ?? -1
        return Signature(
            address: address,
            signerIndex: signerIndex,
            keyIndex: keyIndex,
            signature: signature)
    }

    public var payloadMessage: Data {
        payloadRLPList.rlpData
    }

    public var encodedPayload: Data {
        DomainTag.transaction.rightPaddedData + payloadMessage
    }

    public var payloadRLPList: RLPEncoableArray {
        [
            script,
            RLPEncoableArray(arguments),
            referenceBlockId.data,
            gasLimit,
            proposalKey.address.data,
            UInt(proposalKey.keyIndex),
            proposalKey.sequenceNumber,
            payer.data,
            RLPEncoableArray(authorizers.map { $0.data })
        ]
    }

    /// The signable message for the transaction envelope.
    ///
    /// This message is only signed by the payer account.
    public var envelopeMessage: Data {
        envelopeRLPList.rlpData
    }
    
    public var encodedEnvelope: Data {
        DomainTag.transaction.rightPaddedData + envelopeMessage
    }

    private var envelopeRLPList: RLPEncoableArray {
        [
            payloadRLPList,
            RLPEncoableArray(payloadSignatures.map { $0.rlpList })
        ]
    }
}

// MARK: - RLPDecodable

extension Transaction: RLPDecodable {

    public init(rlpItem: RLPItem) throws {
        let items = try rlpItem.getListItems()

        let payloadRLPListItemCount = 9
        let payloadRLPListItems: [RLPItem]
        let hasSignature: Bool
        switch items.count {
        case 3:
            hasSignature = true
            payloadRLPListItems = try items[0].getListItems()
        case payloadRLPListItemCount:
            hasSignature = false
            payloadRLPListItems = items
        default:
            throw RLPDecodingError.invalidType(rlpItem, type: Self.self)
        }

        // payload
        guard payloadRLPListItems.count == payloadRLPListItemCount else {
            throw RLPDecodingError.invalidType(rlpItem, type: Self.self)
        }
        self.script = try Data(rlpItem: payloadRLPListItems[0])
        self.arguments = try payloadRLPListItems[1].getListItems()
            .map { try Data(rlpItem: $0) }
        self.referenceBlockId = Identifier(data: try Data(rlpItem: payloadRLPListItems[2]))
        self.gasLimit = try UInt64(rlpItem: payloadRLPListItems[3])
        self.proposalKey = ProposalKey(
            address: Address(data: try Data(rlpItem: payloadRLPListItems[4])),
            keyIndex: Int(try UInt(rlpItem: payloadRLPListItems[5])),
            sequenceNumber: try UInt64(rlpItem: payloadRLPListItems[6]))
        self.payer = Address(data: try Data(rlpItem: payloadRLPListItems[7]))
        self.authorizers = try payloadRLPListItems[8].getListItems()
            .map { Address(data: try Data(rlpItem: $0)) }

        if hasSignature {
            // payloadSignatures & envelopeSignatures
            self.payloadSignatures = try items[1].getListItems()
                .map { try Transaction.Signature(rlpItem: $0) }
            self.envelopeSignatures = try items[2].getListItems()
                .map { try Transaction.Signature(rlpItem: $0) }

            for (index, payloadSignature) in payloadSignatures.enumerated() {
                guard payloadSignature.signerIndex < signerList.count else {
                    throw RLPDecodingError.invalidType(rlpItem, type: Self.self)
                }
                payloadSignatures[index].address = signerList[payloadSignature.signerIndex]
            }
            for (index, envelopeSignature) in envelopeSignatures.enumerated() {
                guard envelopeSignature.signerIndex < signerList.count else {
                    throw RLPDecodingError.invalidType(rlpItem, type: Self.self)
                }
                envelopeSignatures[index].address = signerList[envelopeSignature.signerIndex]
            }
        } else {
            self.payloadSignatures = []
            self.envelopeSignatures = []
        }
    }
}

// MARK: - Encode, Decode

extension Transaction {

    /// Encode serializes the full transaction data including the payload and all signatures.
    public func encode() -> Data {
        RLPEncoableArray([
            payloadRLPList,
            RLPEncoableArray(payloadSignatures.map { $0.rlpList }),
            RLPEncoableArray(envelopeSignatures.map { $0.rlpList })
        ]).rlpData
    }

    /// Decode serializeds the full transaction data including the payload and all signatures.
    public init(rlpData: Data) throws {
        let decoder = RLPDecoder()
        let items = try decoder.decodeRLPData(rlpData)
        try self.init(rlpItem: items)
    }

}
