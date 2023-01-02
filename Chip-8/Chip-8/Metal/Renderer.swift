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
    let textureLoader: MTKTextureLoader

    lazy var vertexData: [AAPLVertex] = [
        AAPLVertex(position: vector_float2(x: -1.0, y:  1.0), textureCoordinate: vector_float2(x: -1.0, y:  1.0)),
        AAPLVertex(position: vector_float2(x: -1.0, y: -1.0), textureCoordinate: vector_float2(x: -1.0, y: -1.0)),
        AAPLVertex(position: vector_float2(x:  1.0, y: -1.0), textureCoordinate: vector_float2(x:  1.0, y: -1.0)),

        AAPLVertex(position: vector_float2(x: -1.0, y:  1.0), textureCoordinate: vector_float2(x: -1.0, y:  1.0)),
        AAPLVertex(position: vector_float2(x:  1.0, y:  1.0), textureCoordinate: vector_float2(x:  1.0, y:  1.0)),
        AAPLVertex(position: vector_float2(x:  1.0, y: -1.0), textureCoordinate: vector_float2(x:  1.0, y: -1.0))
    ]

    lazy var vertexBuffer: MTLBuffer = {
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        guard let vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: .storageModeShared) else {
            fatalError("Failed to create vertex buffer!")
        }

        return vertexBuffer
    }()

    var viewportSize: SIMD2<UInt32> = SIMD2(x: 0, y: 0)
    var texture: MTLTexture?
    var pipelineState: MTLRenderPipelineState

    init?(metalKitView: MTKView) {
        guard let device = metalKitView.device else {
            return nil
        }

        self.device = device

        guard let queue = self.device.makeCommandQueue() else {
            return nil
        }

        commandQueue = queue
        metalKitView.colorPixelFormat = .rgba8Unorm

        textureLoader = MTKTextureLoader(device: device)

        guard let renderPipeline = Renderer.buildRenderPipelineWithDevice(
            device: device,
            metalKitView: metalKitView
        ) else {
            return nil
        }

        pipelineState = renderPipeline

        super.init()
    }
    
    func updateTexture(from cgImage: CGImage, width: CGFloat, height: CGFloat) {
        let textureLoaderOptions = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
        ]

        guard let texture = try? textureLoader.newTexture(cgImage: cgImage, options: textureLoaderOptions) else {
            return
        }

        self.texture = texture
    }
    
    func draw(in view: MTKView) {
        guard let texture = texture,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else {
            return
        }

        commandEncoder.label = "Chip-8 Render Encoder"
        commandEncoder.setViewport(MTLViewport(originX: 0.0, originY: 0.0, width: Double(viewportSize.x), height: Double(viewportSize.y), znear: -1.0, zfar: 1.0))
        commandEncoder.setRenderPipelineState(pipelineState)

        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: Int(AAPLVertexInputIndexVertices.rawValue))

        commandEncoder.setFragmentTexture(texture, index: Int(AAPLTextureIndexBaseColor.rawValue))

        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count)

        commandEncoder.endEncoding()

        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }

        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize.x = UInt32(size.width)
        viewportSize.y = UInt32(size.height)
    }

    class func buildRenderPipelineWithDevice(
        device: MTLDevice,
        metalKitView: MTKView
    ) -> MTLRenderPipelineState? {
        let library = device.makeDefaultLibrary()

        let vertexFunction = library?.makeFunction(name: "vertexShader")
        let fragmentFunction = library?.makeFunction(name: "samplingShader")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "RenderPipeline"
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction

        pipelineDescriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float

        do {
            return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Error: \(error.localizedDescription)")
        }

        return nil
    }
}
