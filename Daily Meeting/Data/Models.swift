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
    case humanResourse = "Human Resourse"
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

struct UserSettings: Equatable {
    var id: Int
    var isBot: Bool
    var userName: String
    var avatarName: String?
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
    var isMale: Bool {
        switch avatarName {
        case "avatar-1",
            "avatar-2",
            "avatar-3",
            "avatar-4",
            "avatar-5",
            "avatar-6",
            "avatar-7",
            "avatar-8",
            "avatar-9",
            "avatar-10",
            "avatar-11",
            "avatar-12":
            return true
        case .some, .none:
            return false
        }
    }
}

struct ChatSettings {
    var companyDetails: String?
    var userStackDescription: String?
    var voiceOver: Bool
    var isPremium: Bool
    var userOnboarded: Bool
    var dailyMeetingsCompleted: Int
    var salaryReviewsCompleted: Int
    var techInterviewsCompleted: Int
    var bgImageIndex: Int
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
