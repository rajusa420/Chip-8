//
//  UIImage+VideoMemory.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/26/22.
//

import UIKit



extension UIImage {

    static func fromPixelBuffer(buffer: [Pixel], width: Int, height: Int) -> UIImage? {
        guard let imageRef = CGImage.fromPixelBuffer(buffer: buffer, width: width, height: height) else {
            return nil
        }
        
        return UIImage(cgImage: imageRef)
    }
}
