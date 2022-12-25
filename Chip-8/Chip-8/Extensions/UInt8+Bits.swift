//
//  UInt8+Bits.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/27/22.
//

import Foundation

extension UInt8 {
    @inlinable var leastSigBit: Byte {
        return Byte(self & 0x01)
    }

    @inlinable var mostSigBit: Byte {
        return Byte((self & 0x80) >> 7)
    }
}
