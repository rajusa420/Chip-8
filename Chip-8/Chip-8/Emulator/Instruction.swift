//
//  Opcode.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/25/22.
//

import Foundation

// The Chip-8 processor has 34 instructions
enum Instruction: Int {
    // 00E0: CLS
    case cls = 0

    // 00EE: RET
    case returnFromSub = 1

    // 1nnn: JP addr
    case jump = 2

    // 2nnn - CALL addr
    case call = 3

    // 3xkk - SE Vx, byte
    case skipNextIfRegEqualValue = 4

    // 4xkk - SNE Vx, byte
    case skipNextIfRegNotEqualValue = 5

    // 5xy0 - SE Vx, Vy (Note the not equal version is 9xy0)
    case skipNextIfRegsEqual = 6

    // 6xkk - LD Vx, byte
    case loadValueIntoReg = 7

    // 7xkk - ADD Vx, byte
    case addValueToReg = 8

    // 8xy0 - LD Vx, Vy
    case setRegToReg = 9

    // 8xy1 - OR Vx, Vy
    case orRegs = 10

    // 8xy2 - AND Vx, Vy
    case andRegs = 11

    // 8xy3 - XOR Vx, Vy
    case xorRegs = 12

    // 8xy4 - ADD Vx, Vy
    case addRegs = 13

    // 8xy5 - SUB Vx, Vy (Vx = Vx - Vy)
    case subRegs = 14

    // 8xy6 - SHR Vx
    case rightShiftReg = 15

    // 8xy7 - SUBN Vx, Vy (Vx = Vy - Vx)
    case subNRegs = 16

    // 8xyE - SHL Vx
    case leftShiftReg = 17

    // 9xy0 - SNE Vx, Vy
    case skipNextIfRegsNotEqual = 18

    // Annn - LD I, addr
    case loadMemoryIntoIndexReg = 19

    // Bnnn - JP V0, addr
    case jumpToAddressPlusRegister0 = 20

    // Cxkk - RND Vx, byte
    case loadRandomAndByValueToReg = 21

    // Dxyn - DRW Vx, Vy, nibble
    case drawSprite = 22

    // Ex9E - SKP Vx
    case skipIfKeyPressed = 23

    // ExA1 - SKNP Vx
    case skipIfKeyNotPressed = 24

    // Fx07 - LD Vx, DT
    case setRegToDelayTimer = 25

    // Fx0A - LD Vx, K
    case waitForKeyPress = 26

    // Fx15 - LD DT, Vx
    case setDelayTimerToReg = 27

    // Fx18 - LD ST, Vx
    case setSoundTimerToReg = 28

    // Fx1E - ADD I, Vx
    case addRegToIndexReg = 29

    // Fx29 - LD F, Vx
    case loadFontSpriteLocationIntoIndexReg = 30

    // Fx33 - LD B, Vx
    case loadBCDToMem = 31

    // Fx55 - LD [I], Vx
    case loadRegsIntoMem = 32

    // Fx65 - LD Vx, [I]
    case loadMemIntoRegs = 33

    case noOp
}

// Instead of a VTable we are parsing the opcode to an instruction
// and then dispatching it using the execute method.
extension Instruction {
    static func parseOpcode(opcode: Word) -> Instruction {
        switch opcode.mostSigNibble {

        case 0x0:
            let leastSigFourBits = opcode.leastSigNibble
            switch leastSigFourBits {
            case 0x0:
                return .cls
            case 0xE:
                return .returnFromSub
            default:
                return .noOp
            }

        case 0x1:
            return .jump

        case 0x2:
            return .call

        case 0x3:
            return .skipNextIfRegEqualValue

        case 0x4:
            return .skipNextIfRegNotEqualValue

        case 0x5:
            return .skipNextIfRegsEqual

        case 0x6:
            return .loadValueIntoReg

        case 0x7:
            return .addValueToReg

        case 0x8:
            let leastSigFourBits = opcode.leastSigNibble
            switch leastSigFourBits {
            case 0x0:
                return .setRegToReg
            case 0x1:
                return .orRegs
            case 0x2:
                return .andRegs
            case 0x3:
                return .xorRegs
            case 0x4:
                return .addRegs
            case 0x5:
                return .subRegs
            case 0x6:
                return .rightShiftReg
            case 0x7:
                return .subNRegs
            case 0xE:
                return .leftShiftReg
            default:
                return .noOp
            }

        case 0x9:
            return .skipNextIfRegsNotEqual

        case 0xA:
            return .loadMemoryIntoIndexReg

        case 0xB:
            return .jumpToAddressPlusRegister0

        case 0xC:
            return .loadRandomAndByValueToReg

        case 0xD:
            return .drawSprite

        case 0xE:
            let leastSigFourBits = opcode.leastSigNibble
            switch leastSigFourBits {
            case 0x1:
                return .skipIfKeyNotPressed
            case 0xE:
                return .skipIfKeyPressed
            default:
                return .noOp
            }

        case 0xF:
            let leastSigByte = opcode.leastSigByte
            switch leastSigByte {
            case 0x7:
                return .setRegToDelayTimer
            case 0xA:
                return .waitForKeyPress
            case 0x15:
                return .setDelayTimerToReg
            case 0x18:
                return .setSoundTimerToReg
            case 0x1E:
                return .addRegToIndexReg
            case 0x29:
                return .loadFontSpriteLocationIntoIndexReg
            case 0x33:
                return .loadBCDToMem
            case 0x55:
                return .loadRegsIntoMem
            case 0x65:
                return .loadMemIntoRegs
            default:
                return .noOp
            }

        default:
            print("Unexpected Opcode!")
            return .noOp
        }
    }
}

extension Instruction {
    func execute(opcode: Word, emulator: Chip8Emulator) {
        print("\(String(describing: self)): \(String(format:"0x%04X", opcode))")

        switch self {
        case .cls:
            emulator.clearScreen()

        case .jump:
            emulator.jump(opcode: opcode)

        case .call:
            emulator.call(opcode: opcode)

        case .returnFromSub:
            emulator.ret()

        case .skipNextIfRegEqualValue:
            emulator.skipNextIfRegEqualValue(opcode: opcode)

        case .skipNextIfRegNotEqualValue:
            emulator.skipNextIfRegNotEqualValue(opcode: opcode)

        case .skipNextIfRegsEqual:
            emulator.skipNextIfRegsEqual(opcode: opcode)

        case .loadValueIntoReg:
            emulator.loadValueIntoReg(opcode: opcode)

        case .addValueToReg:
            emulator.addValueToReg(opcode: opcode)

        case .setRegToReg:
            emulator.setRegToReg(opcode: opcode)

        case .orRegs:
            emulator.orRegs(opcode: opcode)

        case .andRegs:
            emulator.andRegs(opcode: opcode)

        case .xorRegs:
            emulator.xorRegs(opcode: opcode)

        case .addRegs:
            emulator.addRegs(opcode: opcode)

        case .subRegs:
            emulator.subRegs(opcode: opcode)

        case .rightShiftReg:
            emulator.rightShiftReg(opcode: opcode)

        case .subNRegs:
            emulator.subNRegs(opcode: opcode)

        case .leftShiftReg:
            emulator.leftShiftReg(opcode: opcode)

        case .skipNextIfRegsNotEqual:
            emulator.skipNextIfRegsNotEqual(opcode: opcode)

        case .loadMemoryIntoIndexReg:
            emulator.loadMemIntoIndexReg(opcode: opcode)

        case .jumpToAddressPlusRegister0:
            emulator.jumpToAddressPlusRegister0(opcode: opcode)

        case .loadRandomAndByValueToReg:
            emulator.loadRandomAndByValueToReg(opcode: opcode)

        case .drawSprite:
            emulator.drawSprite(opcode: opcode)

        case .skipIfKeyPressed:
            emulator.skipIfKeyPressed(opcode: opcode)

        case .skipIfKeyNotPressed:
            emulator.skipIfNotKeyPressed(opcode: opcode)

        case .setRegToDelayTimer:
            emulator.setRegToDelayTimer(opcode: opcode)

        case .waitForKeyPress:
            emulator.waitForKeyPress(opcode: opcode)

        case .setDelayTimerToReg:
            emulator.setDelayTimerToReg(opcode: opcode)

        case .setSoundTimerToReg:
            emulator.setSoundTimerToReg(opcode: opcode)

        case .addRegToIndexReg:
            emulator.addRegToIndexReg(opcode: opcode)

        case .loadFontSpriteLocationIntoIndexReg:
            emulator.loadFontSpriteLocationIntoIndexReg(opcode: opcode)

        case .loadBCDToMem:
            emulator.loadBCDToMem(opcode: opcode)

        case .loadRegsIntoMem:
            emulator.loadRegsIntoMem(opcode: opcode)

        case .loadMemIntoRegs:
            emulator.loadMemIntoRegs(opcode: opcode)

        default:
            emulator.noOp(opcode: opcode)
        }
    }
}
