//
//  Chip8Emulator+Cycle.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/25/22.
//

import Foundation

extension Chip8Emulator {
    func cycle() {
        // Read 2 bytes at the program counter
        let opCode: Word = (Word(memory[programCounter]) << 8) |
                             (Word(memory[programCounter + 1]))

        programCounter += 2

        // Decode the opcode into an instruction
        let instruction = Instruction.parseOpcode(opcode: opCode)
        instruction.execute(opcode: opCode, emulator: self)
    }

    func delayCycle() {
        if delayTimer > 0 {
            delayTimer -= 1
        }

        if soundTimer > 0 {
            soundTimer -= 1
        }
    }
}
