//
//  Array+Subscript.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/24/22.
//

import Foundation

extension Array {
    @inlinable public subscript(index: UInt16) -> Element {
        get {
            return self[Int(index)]
        }

        set(newValue) {
            self[Int(index)] = newValue
        }
    }

    @inlinable public subscript(index: UInt8) -> Element {
        get {
            return self[Int(index)]
        }

        set(newValue) {
            self[Int(index)] = newValue
        }
    }
}
