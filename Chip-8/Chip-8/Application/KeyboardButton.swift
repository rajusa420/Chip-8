//
//  KeyboardButton.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/27/22.
//

import SwiftUI

struct KeyboardButton: View {
    @EnvironmentObject var viewModel: KeyboardViewModel

    let buttonId: ButtonId
    @State var isPressed: Bool = false

    var body: some View {
        VStack {
            Spacer()

            HStack {
                Spacer()

                Text(buttonId.displayText)
                    .minimumScaleFactor(0.5)
                    .font(.largeTitle)
                    .foregroundColor(.black)

                Spacer()
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .background(isPressed ? Color.gray : Color.white)
        .cornerRadius(15.0)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    guard !isPressed else {
                        return
                    }

                    isPressed = true
                    viewModel.onKeyDown(buttonId: buttonId)
                }
                .onEnded { value in
                    guard isPressed else {
                        return
                    }

                    viewModel.onKeyUp(buttonId: buttonId)
                    isPressed = false
                }
        )
    }
}
