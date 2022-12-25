//
//  UIImage+VideoMemory.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/26/22.
//

import UIKit



extension UIImage {

    static func fromPixelBuffer(buffer: [Pixel], width: Int, height: Int) -> UIImage? {
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

        return UIImage(cgImage: imageRef)
    }
}
