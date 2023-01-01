//
//  CGImage+VideoMemory.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/30/22.
//

import Foundation
import CoreGraphics

extension CGImage {
    static func fromPixelBuffer(buffer: [Pixel], width: Int, height: Int) -> CGImage? {
        let alphaInfo = CGImageAlphaInfo.premultipliedLast
        let bytesPerPixel = MemoryLayout<Pixel>.size
        let bytesPerRow = width * bytesPerPixel

        let bitsPerComponent = 8
        let bitsPerPixel = bytesPerPixel * bitsPerComponent

        guard let providerRef = CGDataProvider(data: Data(
            bytes: buffer, count: height * bytesPerRow
        ) as CFData) else {
            return nil
        }

        guard let imageRef = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: alphaInfo.rawValue),
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else {
            return nil
        }

        return imageRef
    }
}
