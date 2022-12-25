//
//  KeyboardView.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/27/22.
//

import SwiftUI

class KeyboardViewModel: ObservableObject {
    let keyDownCallback: (ButtonId) -> Void
    let keyUpCallback: (ButtonId) -> Void

    init(keyDownCallback: @escaping (ButtonId) -> Void, keyUpCallback: @escaping (ButtonId) -> Void) {
        self.keyDownCallback = keyDownCallback
        self.keyUpCallback = keyUpCallback
    }

    func onKeyDown(buttonId: ButtonId) {
        keyDownCallback(buttonId)
    }

    func onKeyUp(buttonId: ButtonId) {
        keyUpCallback(buttonId)
    }
}

struct KeyboardView: View {
    let buttonsPerRow = 4

    var body: some View {
        VStack(spacing: 2.0) {
            ForEach(0 ..< ButtonId.allCases.count / buttonsPerRow, id: \.self) { rowId in
                HStack(spacing: 2.0) {
                    ForEach(0 ..< buttonsPerRow, id: \.self) { colId in
                        if let buttonId = ButtonId(rawValue: (rowId * buttonsPerRow) + colId) {
                            KeyboardButton(buttonId: buttonId)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 5.0)
    }
}
