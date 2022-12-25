//
//  Pixel.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/26/22.
//

import Foundation

public struct Pixel {
    let red: Byte
    let green: Byte
    let blue: Byte
    let alpha: Byte

    public init(red: Byte, green: Byte, blue: Byte, alpha: Byte = 0xFF) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

extension Pixel {
    static let black = Pixel(red: 0, green: 0, blue: 0)
    static let white = Pixel(red: 0xFF, green: 0xFF, blue: 0xFF)
}

extension Pixel {
    static func pixelBuffer(from buffer: UnsafeMutableBufferPointer<DWord>, width: Byte, height: Byte) -> [Pixel] {
        var pixelBuffer: [Pixel] = Array(repeating: Pixel.black, count: Int(width) * Int(height))
        for row in 0 ..< height {
            for col in 0 ..< width {
                let index: DWord = (DWord(row) * DWord(width)) + DWord(col)
                pixelBuffer[Int(index)] = (buffer[index] > 0) ? Pixel.white : Pixel.black
            }
        }

        return pixelBuffer
    }
}
