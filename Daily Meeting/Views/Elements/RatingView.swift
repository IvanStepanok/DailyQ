//
//  RatingView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 07.08.2023.
//

import SwiftUI

struct RatingView: View {
    
    private let rating: Double
    
    private func scale(_ index: Int) -> Double {
        switch index {
        case 1:
            return 1
        case 2:
            return 1.5
        case 3:
            return 1
        default:
            return 1
        }
    }
    
    private func padding(_ index: Int) -> CGFloat {
        switch index {
        case 1:
            return 1
        case 2:
            return 4
        case 3:
            return 1
        default:
            return 1
        }
    }
    
    init(rating: Double) {
        self.rating = rating
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            ForEach(1...3, id: \.self) { index in
                if index <= Int(self.rating) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaleEffect(scale(index))
                        .padding(.horizontal, padding(index))
                        .offset(y: -padding(index))
                } else if index == Int(self.rating) + 1 && self.rating.truncatingRemainder(dividingBy: 1) != 0 {
                    Image(systemName: "star.leadinghalf.fill")
                        .resizable()
                        .scaleEffect(scale(index))
                        .padding(.horizontal, padding(index))
                        .offset(y: -padding(index))
                } else {
                    Image(systemName: "star")
                        .resizable()
                        .scaleEffect(scale(index))
                        .padding(.horizontal, padding(index))
                        .offset(y: -padding(index))
                }
            }
        }.foregroundColor(Color(.yellow))
            .fixedSize(horizontal: true, vertical: true)
            .scaleEffect(0.9)
    }
}

struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        RatingView(rating: 4.5)
    }
}
