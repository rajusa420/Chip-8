//
//  RunLoop.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/24/22.
//

import Foundation
import UIKit

class DisplayLoop {
    var executionBlock: () -> ()
    var displayLink: CADisplayLink?

    private enum Constants {
        static let minPreferredFrameRate: Float = 60.0
        static let maxPreferredFrameRate: Float = 60.0
    }

    init(executionBlock: @escaping () -> ()) {
        self.executionBlock = executionBlock
        start()
    }

    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkCallback))
//        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: Constants.minPreferredFrameRate, maximum: Constants.maxPreferredFrameRate)
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc func displayLinkCallback() {
        executionBlock()
    }

    func stop() {
        displayLink?.invalidate()
        displayLink?.remove(from: .main, forMode: .common)
    }
}
