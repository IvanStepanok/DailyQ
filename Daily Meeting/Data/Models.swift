//
//  Models.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import UIKit

enum UserRole: String, CaseIterable {
    case teamLead = "Team Leader"
    case designer = "Designer"
    case mobile = "Mobile Developer"
    case qa = "Quality Assurance"
    case frontend = "Frontend Developer"
    case backend = "Backend Developer"
}

enum EnglishLevel: String, CaseIterable {
    case beginner = "Beginner"
    case elementary = "Elementary"
    case preIntermediate = "Pre-Intermediate"
    case intermediate = "Intermediate"
    case upperIntermediate = "Upper Intermediate"
    case advanced = "Advanced"
    case proficient = "Proficient"
}

enum UserGender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
}

struct UserSettings: Equatable {
    var id: Int
    var isBot: Bool
    var userName: String
    var avatarName: String?
    var gender: UserGender
    var userRole: UserRole
    var englishLevel: EnglishLevel
    var color: UIColor {
        var hash = 0
           let colorConstant = 131
           let maxSafeValue = Int.max / colorConstant
           for char in userName.unicodeScalars{
               if hash > maxSafeValue {
                   hash = hash / colorConstant
               }
               hash = Int(char.value) + ((hash << 5) - hash)
           }
           let finalHash = abs(hash) % (256*256*256);
           let color = UIColor(hue:CGFloat(finalHash)/255.0 , saturation: 0.40, brightness: 0.75, alpha: 1.0)
           return color
    }
}

struct ChatSettings {
    var agenda: String?
    var voiceOver: Bool
    var isPurchaced: Bool
}

struct Random {
    static let events: [String] = [
    "Сломался сервер",
    "Был день рождения у ",
    "Заказчику одобрил дизайн",
    "Вчера был новый год",
    "",
    ]
}
