//
//  Renderer.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/24/22.
//

// Our platform independent renderer class

import Metal
import MetalKit
import simd

class Renderer: NSObject, MTKViewDelegate {
    public let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let context: CIContext
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    var image: CIImage?
    weak var mtkView: MTKView?

    init?(metalKitView: MTKView) {
        guard let device = metalKitView.device else {
            return nil
        }

        self.device = device
        self.context = CIContext(mtlDevice: device)

        guard let queue = self.device.makeCommandQueue() else {
            return nil
        }

        commandQueue = queue
        metalKitView.framebufferOnly = false
        mtkView = metalKitView
        super.init()
    }
    
    func updateTexture(from cgImage: CGImage, width: CGFloat, height: CGFloat) {
        guard case let image = CIImage(cgImage: cgImage),
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let view = mtkView,
              let drawable = view.currentDrawable
        else {
            return
        }

        drawable.layer.backgroundColor = UIColor.black.cgColor

        let dpi = UIScreen.main.nativeScale
        let width = view.bounds.width * dpi
        let height = view.bounds.height * dpi
        let rect = CGRect(x: 0, y: 0, width: width, height: height)

        let extent = image.extent
        let xScale = extent.width > 0 ? width  / extent.width  : 1
        let yScale = extent.height > 0 ? height / extent.height : 1
        let scale = min(xScale, yScale)
        let tx = (width - extent.width * scale) / 2
        let ty = (height - extent.height * scale) / 2
        let transform = CGAffineTransform(a: scale, b: 0, c: 0, d: scale, tx: tx, ty: ty)
        guard let filter = CIFilter(
            name: "CIAffineTransform",
            parameters: [
                "inputImage": image,
                "inputTransform": transform
                ]
            ),
              var scaledImage: CIImage = filter.outputImage else {
            return
        }

        #if targetEnvironment(simulator)
            scaledImage = scaledImage.transformed(by: CGAffineTransform(scaleX: 1, y: -1))
                .transformed(by: CGAffineTransform(translationX: 0, y: scaledImage.extent.height))
        #endif

        let scaledImageExtent = scaledImage.extent
        context.render(
            scaledImage,
            to: drawable.texture,
            commandBuffer: commandBuffer,
            bounds: rect,
            colorSpace: colorSpace
        )

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func draw(in view: MTKView) {}

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
