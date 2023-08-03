//
//  CustomButton.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import SwiftUI

struct CustomButton: View {
    
    private let text: String
    private let bgColor: Color
    private let action: () -> Void
    
    init(text: String, bgColor: Color = Color("secondaryColor"), action: @escaping () -> Void) {
        self.text = text
        self.action = action
        self.bgColor = bgColor
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                action()
            }, label: {
                Text(text)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fixedSize(horizontal: false, vertical: false)
                            .foregroundColor(bgColor)
                    )
            })
        }
    }
}

struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("bgColor")
            CustomButton(text: "Test button", action: {})
        }
    }
}
