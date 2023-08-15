//
//  DateExtension.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 12.08.2023.
//

import Foundation

extension Date {
    func toString() -> String {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.string(from: self)
    }
    
    static func fromString(_ string: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: string)
    }
}
