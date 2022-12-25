//
//  ButtonId.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/27/22.
//

import Foundation

enum ButtonId: Int, CaseIterable {
    case one = 0
    case two
    case three
    case c
    case four
    case five
    case six
    case d
    case seven
    case eight
    case nine
    case e
    case a
    case zero
    case b
    case f

    var displayText: String {
        switch self {
        case .one:
            return "1"
        case .two:
            return "2"
        case .three:
            return "3"
        case .c:
            return "C"
        case .four:
            return "4"
        case .five:
            return "5"
        case .six:
            return "6"
        case .d:
            return "D"
        case .seven:
            return "7"
        case .eight:
            return "8"
        case .nine:
            return "9"
        case .e:
            return "E"
        case .a:
            return "A"
        case .zero:
            return "0"
        case .b:
            return "B"
        case .f:
            return "F"
        }
    }

    var buttonCode: Byte {
        switch self {
        case .one:
            return Byte(0x1)
        case .two:
            return Byte(0x2)
        case .three:
            return Byte(0x3)
        case .c:
            return Byte(0xC)
        case .four:
            return Byte(0x4)
        case .five:
            return Byte(0x5)
        case .six:
            return Byte(0x6)
        case .d:
            return Byte(0xD)
        case .seven:
            return Byte(0x7)
        case .eight:
            return Byte(0x8)
        case .nine:
            return Byte(0x9)
        case .e:
            return Byte(0xE)
        case .a:
            return Byte(0xA)
        case .zero:
            return Byte(0x0)
        case .b:
            return Byte(0xB)
        case .f:
            return Byte(0xF)
        }
    }
}
