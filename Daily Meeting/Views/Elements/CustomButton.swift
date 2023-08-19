//
//  CustomButton.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import SwiftUI
import UIKit

struct CustomButton: View {
    
    private let text: String
    private let bgColor: Color?
    private let action: () -> Void
    private let flexible: Bool
    
    init(text: String, flexible: Bool = false, bgColor: Color? = nil, action: @escaping () -> Void) {
        self.text = text
        self.flexible = flexible
        self.action = action
        self.bgColor = bgColor
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                impactFeedbackgenerator.prepare()
                impactFeedbackgenerator.impactOccurred()
                
                action()
            }, label: {
                ZStack {
                    ZStack {
                        if let bgColor = bgColor {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(bgColor)
                        } else {
                            VisualEffectView(effect: UIBlurEffect(style: .dark))
                                .cornerRadius(12)
                            
                        }
                    }
                    Text(text)
                        .foregroundColor(.white)
                        .padding(12)
                    
                }
            })
        }.fixedSize(horizontal: !flexible, vertical: true)
    }
}


struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("bgColor")
            CustomButton(text: "Test button", flexible: false, action: {})
        }
    }
}
