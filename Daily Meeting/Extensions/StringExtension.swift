//
//  StringExtension.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import Foundation

extension String {
    func removingLastWord() -> String {

        let words = self.split(separator: " ")
        
        guard words.count > 1 else {
            return ""
        }
        
        let result = words.dropLast().joined(separator: " ")
        return String(result)
    }
}
