//
//  Chip8Emulator.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/24/22.
//

import Foundation
import UIKit

public typealias Byte = UInt8
public typealias Word = UInt16
public typealias DWord = UInt32

class Chip8Emulator {
    enum Constants {
        static let memoryInBytes = 4096
        static let registerCount = 16
        static let stackDepth = 16
        static let keypadKeyCount = 16

        static let programStartMemoryLocation: Word = 0x200
        static let fontSetMemoryLocation: Word = 0x50
        static let sizeOfEachFontCharacter: Byte = 5

        // The max memory address. The 2 byte opcodes can be & with this to separate
        // the memory address from the instruction
        static let maxMemoryAddress: Word = 0x0FFF

        static let videoWidth: Byte = 64
        static let videoHeight: Byte = 32
        static let videoMemorySize: Int = Int(videoWidth) * Int(videoHeight)
        static let videoPixelOn: DWord = 0xFFFFFFFF

        static let cycleFrequencyHz: TimeInterval = 500.0
        static let delayFrequencyHz: TimeInterval = 60.0
    }

    var memory = UnsafeMutableBufferPointer<Byte>.allocate(capacity: Constants.memoryInBytes)
    var videoMemory = UnsafeMutableBufferPointer<DWord>.allocate(capacity: Constants.videoMemorySize)

    var registers = UnsafeMutableBufferPointer<Byte>.allocate(capacity: Constants.registerCount)
    var indexRegister: Word = 0
    var programCounter: Word = Constants.programStartMemoryLocation

    var stack: [Word] = [Word](repeating: 0, count: Constants.stackDepth)
    var stackPointer: Word = 0

    var delayTimer: Byte = 0
    var soundTimer: Byte = 0
    var keypad: [Byte] = [Byte](repeating: 0, count: Constants.keypadKeyCount)

    var cycleCount: Int = 0
    
    init() {
        memory.initialize(repeating: 0)
        videoMemory.initialize(repeating: 0)
        registers.initialize(repeating: 0)
        loadFontSet()
    }

    deinit {
        memory.deallocate()
        videoMemory.deallocate()
        registers.deallocate()
    }

    func printMemoryContents() {
        for (index, element) in memory.enumerated() {
            print("\(index): \(element)")
        }
    }

    func loadROM() {
        guard let romURL = Bundle.main.url(forResource: "TestOpcode", withExtension: "ch8"),
              let romData = try? Data(contentsOf: romURL) else {
            fatalError("Failed to find and load ROM file")
        }

        // Convert into a typed array and copy the entire buffer into the program start location
        var romDataArray: [Byte] = Array(romData)
        copyIntoMemory(buffer: &romDataArray, startLocation: Constants.programStartMemoryLocation)
    }

    func getUIImageOfVideoMemory() -> UIImage? {
        let pixelBuffer = Pixel.pixelBuffer(from: videoMemory, width: Constants.videoWidth, height: Constants.videoHeight)
        return UIImage.fromPixelBuffer(buffer: pixelBuffer, width: Int(Constants.videoWidth), height: Int(Constants.videoHeight))
    }

    func loadFontSet() {
        var fontData = FontSet().data
        copyIntoMemory(buffer: &fontData, startLocation: Constants.fontSetMemoryLocation)
    }

    func keyPressed(keyCode: Byte) {
        keypad[keyCode] = 0xFF
    }

    func keyRelease(keyCode: Byte) {
        keypad[keyCode] = 0x0
    }

    private func copyIntoMemory(buffer: inout [Byte], startLocation: Word) {
        buffer.withUnsafeMutableBufferPointer { bufferPointer in
            let copyStartLocation = Int(startLocation)
            let copyEndLocation = copyStartLocation + bufferPointer.count
            memory[copyStartLocation..<copyEndLocation] = bufferPointer[0..<bufferPointer.count]
        }
    }

    private func copyIntoViewMemory(buffer: inout [DWord], startLocation: DWord) {
        buffer.withUnsafeMutableBufferPointer { bufferPointer in
            let copyStartLocation = Int(startLocation)
            let copyEndLocation = copyStartLocation + bufferPointer.count
            videoMemory[copyStartLocation..<copyEndLocation] = bufferPointer[0..<bufferPointer.count]
        }
    }

    private func clearVideoMemory() {
        videoMemory.assign(repeating: 0)
    }
}

extension Chip8Emulator {

    // Clear the Display
    func clearScreen() {
        clearVideoMemory()
    }

    // Return from a subroutine
    func ret() {
        guard stackPointer != 0 else {
            // TODO: Remove check for non-debug?
            fatalError("No function to return from!")
        }

        stackPointer -= 1
        programCounter = stack[stackPointer]
    }

    // Jump to location
    func jump(opcode: Word) {
        let address: Word = opcode & Constants.maxMemoryAddress
        programCounter = address
    }

    // Call Address - The difference from Jump is that the return address is saved on the stack
    func call(opcode: Word) {
        let address: Word = opcode & Constants.maxMemoryAddress

        stack[stackPointer] = programCounter
        stackPointer += 1
        programCounter = address
    }

    func skipNextIfRegEqualValue(opcode: Word) {
        let registerVx: Byte = opcode.lowNibbleOfMostSigByte
        let byteValue: Byte = Byte(opcode.leastSigByte)

        if registers[registerVx] == byteValue {
            programCounter += 2
        }
    }

    func skipNextIfRegNotEqualValue(opcode: Word) {
        let registerVx: Byte = opcode.lowNibbleOfMostSigByte
        let byteValue: Byte = Byte(opcode.leastSigByte)

        if registers[registerVx] != byteValue {
            programCounter += 2
        }
    }

    func skipNextIfRegsEqual(opcode: Word) {
        let registerVx: Byte = opcode.lowNibbleOfMostSigByte
        let registerVy: Byte = opcode.highNibbleOfLeastSigByte

        if registers[registerVx] == registers[registerVy] {
            programCounter += 2
        }
    }

    // Set register to value where registerVx = register index
    func loadValueIntoReg(opcode: Word) {
        let registerVx: Byte = opcode.lowNibbleOfMostSigByte
        let byteValue: Byte = Byte(opcode.leastSigByte)
        registers[registerVx] = byteValue
    }

    // Add value to register. registerVx = The register index
    func addValueToReg(opcode: Word) {
        let registerVx: Byte = opcode.lowNibbleOfMostSigByte
        let byteValue: Byte = Byte(opcode.leastSigByte)

        let sum: Word = Word(registers[registerVx]) + Word(byteValue)
        registers[registerVx] = Byte(sum & 0xFF)
    }

    func setRegToReg(opcode: Word) {
        let registerVx: Byte = opcode.lowNibbleOfMostSigByte
        let registerVy: Byte = opcode.highNibbleOfLeastSigByte
        registers[registerVx] = registers[registerVy]
    }

    func orRegs(opcode: Word) {
        let registerVx: Byte = opcode.lowNibbleOfMostSigByte
        let registerVy: Byte = opcode.highNibbleOfLeastSigByte
        registers[registerVx] = registers[registerVx] | registers[registerVy]
    }

    func andRegs(opcode: Word) {
        let registerVx: Byte = opcode.lowNibbleOfMostSigByte
        let registerVy: Byte = opcode.highNibbleOfLeastSigByte
        registers[registerVx] = registers[registerVx] & registers[registerVy]
    }

    func xorRegs(opcode: Word) {
        let registerVx: Byte = opcode.lowNibbleOfMostSigByte
        let registerVy: Byte = opcode.highNibbleOfLeastSigByte
        registers[registerVx] = registers[registerVx] ^ registers[registerVy]
    }

    func addRegs(opcode: Word) {
        let registerVx: Byte = opcode.lowNibbleOfMostSigByte
        let registerVy: Byte = opcode.highNibbleOfLeastSigByte

        let sum: Word = Word(registers[registerVx]) + Word(registers[registerVy])

        // set the overflow flag
        registers[0xF] = sum > 0xFF ? 1 : 0

        // Take the first byte of the sum i.e without the carry
        registers[registerVx] = Byte(sum & 0xFF)
    }

    func subRegs(opcode: Word) {
        let registerVx: Byte = opcode.lowNibbleOfMostSigByte
        let registerVy: Byte = opcode.highNibbleOfLeastSigByte

        // Strangely this is set to NOT borrow
        registers[0xF] = registers[registerVx] > registers[registerVy] ? 1 : 0

        registers[registerVx] = registers[registerVx].subtractingReportingOverflow(registers[registerVy]).partialValue
    }

    func rightShiftReg(opcode: Word) {
        let registerVx: Byte = opcode.lowNibbleOfMostSigByte

        registers[0xF] = registers[registerVx].leastSigBit
        registers[registerVx] = registers[registerVx] >> 1
    }

    func subNRegs(opcode: Word) {
        let registerVx: Byte = opcode.lowNibbleOfMostSigByte
        let registerVy: Byte = opcode.highNibbleOfLeastSigByte

        registers[0xF] = registers[registerVy] > registers[registerVx] ? 1 : 0
        registers[registerVx] = registers[registerVy].subtractingReportingOverflow(registers[registerVx]).partialValue
    }

    func leftShiftReg(opcode: Word) {
        let registerVx: Byte = opcode.lowNibbleOfMostSigByte

        registers[0xF] = registers[registerVx].mostSigBit
        registers[registerVx] = registers[registerVx] << 1
    }

    func skipNextIfRegsNotEqual(opcode: Word) {
        let registerVx: Byte = opcode.lowNibbleOfMostSigByte
        let registerVy: Byte = opcode.highNibbleOfLeastSigByte

        if registers[registerVx] != registers[registerVy] {
            programCounter += 2
        }
    }

    // Set index register
    func loadMemIntoIndexReg(opcode: Word) {
        let address: Word = opcode & Constants.maxMemoryAddress
        indexRegister = address
    }

    func jumpToAddressPlusRegister0(opcode: Word) {
        let address: Word = opcode & Constants.maxMemoryAddress
        programCounter = Word(registers[0]) + address
    }

    func loadRandomAndByValueToReg(opcode: Word) {
        let registerVx: Byte = opcode.lowNibbleOfMostSigByte
        let byteValue: Byte = Byte(opcode.leastSigByte)

        registers[registerVx] = Byte(arc4random_uniform(DWord(Byte.max))) & byteValue
    }

    // Display n-byte sprite. The sprite is guaranteed to be 8 pixels wide
    // registerVx = register index that holds xPos
    // registerVy = register index that holds yPos
    func drawSprite(opcode: Word) {
        let registerVx = opcode.lowNibbleOfMostSigByte
        let registerVy = opcode.highNibbleOfLeastSigByte
        let height = Byte(opcode.leastSigNibble)
        let width: Byte = 8

        // Wrap if it would cross the screen boundary
        let xPos = registers[registerVx] % Constants.videoWidth
        let yPos = registers[registerVy] % Constants.videoHeight

        registers[0xF] = 0

        for row in 0 ..< height {
            let spriteByte: Byte = memory[indexRegister + Word(row)]

            for column in 0 ..< width {
                let spritePixel: Byte = spriteByte & (0x80 >> column)

                let videoMemoryOffset: DWord = ((DWord(yPos) + DWord(row)) * DWord(Constants.videoWidth)) + DWord(xPos) + DWord(column)

                if videoMemoryOffset >= (DWord(Constants.videoWidth) * DWord(Constants.videoHeight)) {
                    return
                }

                let videoPixel: DWord = videoMemory[videoMemoryOffset]

                if spritePixel != 0 {

                    if videoPixel == Constants.videoPixelOn {
                        registers[0xF] = 1
                    }

                    // Xor the current pixel in view memory with the sprite pixel
                    videoMemory[videoMemoryOffset] = videoPixel ^ Constants.videoPixelOn
                }
            }
        }
    }

    func skipIfKeyPressed(opcode: Word) {
        let registerVx = opcode.lowNibbleOfMostSigByte
        let key = registers[registerVx]

        if keypad[key] > 0 {
            programCounter += 2
        }
    }

    func skipIfNotKeyPressed(opcode: Word) {
        let registerVx = opcode.lowNibbleOfMostSigByte
        let key = registers[registerVx]

        if keypad[key] == 0 {
            programCounter += 2
        }
    }

    func setRegToDelayTimer(opcode: Word) {
        let registerVx = opcode.lowNibbleOfMostSigByte
        registers[registerVx] = delayTimer
    }

    func waitForKeyPress(opcode: Word) {
        let registerVx = opcode.lowNibbleOfMostSigByte

        // Find the first key down
        for index: Byte in 0x0 ..< 0xF {
            if keypad[index] > 0 {
                registers[registerVx] = index
                return
            }
        }

        // We didn't find a key pressed so decrement the program counter
        // so we execute this command again
        programCounter -= 2
    }

    func setDelayTimerToReg(opcode: Word) {
        let registerVx = opcode.lowNibbleOfMostSigByte
        delayTimer = registers[registerVx]
    }

    func setSoundTimerToReg(opcode: Word) {
        let registerVx = opcode.lowNibbleOfMostSigByte
        soundTimer = registers[registerVx]
    }

    func addRegToIndexReg(opcode: Word) {
        let registerVx = opcode.lowNibbleOfMostSigByte
        indexRegister = indexRegister + Word(registers[registerVx])
    }

    func loadFontSpriteLocationIntoIndexReg(opcode: Word) {
        let registerVx = opcode.lowNibbleOfMostSigByte
        let digit = registers[registerVx]
        indexRegister = Constants.fontSetMemoryLocation + (Word(digit) * Word(Constants.sizeOfEachFontCharacter))
    }

    func loadBCDToMem(opcode: Word) {
        let registerVx = opcode.lowNibbleOfMostSigByte
        var value = registers[registerVx]

        memory[indexRegister + 2] = value % 10
        value /= 10

        memory[indexRegister + 1] = value % 10
        value /= 10

        memory[indexRegister] = value % 10
    }

    func loadRegsIntoMem(opcode: Word) {
        let registerVx = opcode.lowNibbleOfMostSigByte
        for index: Byte in 0 ... registerVx {
            memory[indexRegister + Word(index)] = registers[index]
        }
    }

    func loadMemIntoRegs(opcode: Word) {
        let registerVx = opcode.lowNibbleOfMostSigByte
        for index: Byte in 0 ... registerVx {
            registers[index] = memory[indexRegister + Word(index)]
        }
    }

    func noOp(opcode: Word) {
        print("No Op: \(opcode)")
    }
}
