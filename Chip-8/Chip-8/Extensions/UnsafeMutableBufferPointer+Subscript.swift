//
//  UnsafeMutableBufferPointer+Subscript.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/24/22.
//

import Foundation

extension UnsafeMutableBufferPointer {
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

    @inlinable public subscript(index: UInt32) -> Element {
        get {
            return self[Int(index)]
        }

        set(newValue) {
            self[Int(index)] = newValue
        }
    }
}
