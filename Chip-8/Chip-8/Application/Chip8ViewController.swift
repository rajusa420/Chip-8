//
//  GameViewController.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/24/22.
//

import UIKit
import MetalKit
import SwiftUI

class Chip8ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var keyboardContainerView: UIView!
    @IBOutlet weak var mtkView: MTKView!

    lazy var defaultDevice: MTLDevice = {
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported!")
        }

        return defaultDevice
    }()

    lazy var renderer: Renderer = {
        guard let renderer = Renderer(metalKitView: mtkView) else {
            fatalError("Renderer cannot be initialized!")
        }

        return renderer
    }()

    lazy var keyboardViewModel: KeyboardViewModel = {
        let keyboardViewModel = KeyboardViewModel(
            keyDownCallback: { [weak self] buttonId in
                self?.chip8Emulator.keyPressed(keyCode: buttonId.buttonCode)
            },
            keyUpCallback: { [weak self] buttonId in
                self?.chip8Emulator.keyRelease(keyCode: buttonId.buttonCode)
            }
        )

        return keyboardViewModel
    }()

    lazy var keyboardView: UIView = {
        guard let keyboardView = keyboardViewController.view else {
            fatalError("Unable to create keyboard view")
        }

        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        return keyboardView
    }()

    lazy var keyboardViewController: UIViewController = {
        return UIHostingController(
            rootView: KeyboardView()
                .environmentObject(keyboardViewModel)
        )
    }()

    lazy var chip8Emulator: Chip8Emulator = Chip8Emulator()

    var displayLoop: DisplayLoop?
    var runLoopTimer: Timer?
    var delayLoopTimer: Timer?

    deinit {
        removeChildViewController(viewController: keyboardViewController)
    }

    override func loadView() {
        super.loadView()

        keyboardView.backgroundColor = .clear
        addChildViewController(viewController: keyboardViewController, intoViewContainer: keyboardContainerView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mtkView.device = defaultDevice
        mtkView.backgroundColor = UIColor.black

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        mtkView.delegate = renderer
        imageView.isHidden = true
        
        chip8Emulator.loadROM()
        setupDisplayLoop()
        setupRunLoop()
    }

    private func setupRunLoop() {
        runLoopTimer = Timer.scheduledTimer(timeInterval: 1 / Chip8Emulator.Constants.cycleFrequencyHz, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)

        delayLoopTimer = Timer.scheduledTimer(timeInterval: 1 / Chip8Emulator.Constants.delayFrequencyHz, target: self, selector: #selector(delayTimerFired), userInfo: nil, repeats: true)
    }

    @objc func timerFired() {
        self.chip8Emulator.cycle()
    }

    @objc func delayTimerFired() {
        self.chip8Emulator.delayCycle()
    }

    private func setupDisplayLoop() {
        guard displayLoop == nil else {
            return
        }

        displayLoop = DisplayLoop() {
//            if let videoImage = self.chip8Emulator.getUIImageOfVideoMemoryIfDirty() {
//                self.imageView.image = videoImage
//            }

            if let videoImage = self.chip8Emulator.getCGImageOfVideoMemoryIfDirty() {
                self.renderer.updateTexture(
                    from: videoImage,
                    width: CGFloat(Chip8Emulator.Constants.videoWidth),
                    height: CGFloat(Chip8Emulator.Constants.videoHeight))
            }
        }
    }
}
