//
//  UInt16+Bits.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/25/22.
//

import Foundation

extension UInt16 {
    @inlinable var mostSigNibble: Byte {
        return Byte((self & 0xF000) >> 12)
    }

    @inlinable var leastSigNibble: Byte {
        return Byte(self & 0x000F)
    }

    @inlinable var mostSigByte: Byte {
        return Byte((self & 0xFF00) >> 8)
    }

    @inlinable var leastSigByte: Byte {
        return Byte(self & 0x00FF)
    }

    @inlinable var lowNibbleOfMostSigByte: Byte {
        return Byte((self & 0x0F00) >> 8)
    }

    @inlinable var highNibbleOfLeastSigByte: Byte {
        return Byte((self & 0x00F0) >> 4)
    }
}
