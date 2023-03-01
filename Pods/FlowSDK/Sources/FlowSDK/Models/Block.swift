//
//  Block.swift
// 
//  Created by Scott on 2022/5/18.
//  Copyright © 2022 portto. All rights reserved.
//

import Foundation

/// Block is a set of state mutations applied to the Flow blockchain.
public struct Block: Equatable {

    public let blockHeader: BlockHeader

    public let blockPayload: BlockPayload

    public var id: Identifier {
        blockHeader.id
    }

    public init(blockHeader: BlockHeader, blockPayload: BlockPayload) {
        self.blockHeader = blockHeader
        self.blockPayload = blockPayload
    }

    init(_ value: Flow_Entities_Block) {
        self.blockHeader = BlockHeader(
            id: Identifier(data: value.id),
            parentId: Identifier(data: value.parentID),
            height: value.height,
            timestamp: value.hasTimestamp ? value.timestamp.date : nil)
        self.blockPayload = BlockPayload(
            collectionGuarantees: value.collectionGuarantees.map {
                CollectionGuarantee(collectionId: Identifier(data: $0.collectionID))
            },
            seals: value.blockSeals.map {
                BlockSeal(
                    blockID: Identifier(data: $0.blockID),
                    executionReceiptID: Identifier(data: $0.executionReceiptID))
            })
    }
}

/// BlockHeader is a summary of a full block.
public struct BlockHeader: Equatable {

    public let id: Identifier

    public let parentId: Identifier

    public let height: UInt64

    public let timestamp: Date?

    public init(
        id: Identifier,
        parentId: Identifier,
        height: UInt64,
        timestamp: Date?
    ) {
        self.id = id
        self.parentId = parentId
        self.height = height
        self.timestamp = timestamp
    }

    init(_ value: Flow_Entities_BlockHeader) {
        self.id = Identifier(data: value.id)
        self.parentId = Identifier(data: value.parentID)
        self.height = value.height
        self.timestamp = value.hasTimestamp ? value.timestamp.date : nil
    }

}

/// BlockPayload is the full contents of a block.
///
/// A payload contains the collection guarantees and seals for a block.
public struct BlockPayload: Equatable {
    public let collectionGuarantees: [CollectionGuarantee]
    public let seals: [BlockSeal]
}

/// BlockSeal is the attestation by verification nodes that the transactions in a previously
/// executed block have been verified.
public struct BlockSeal: Equatable {

    /// The ID of the block this Seal refers to (which will be of lower height than this block)
    public let blockID: Identifier

    /// The ID of the execution receipt generated by the Verifier nodes; the work of verifying a
    /// block produces the same receipt among all verifying nodes
    public let executionReceiptID: Identifier
}
