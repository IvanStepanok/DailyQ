//
//  ChatPersistence.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import CoreData
import Combine
import SwiftUI
import KeychainSwift

protocol ChatPersistenceProtocol {
    func saveUserSettings(settings: UserSettings) async
    func loadAllUsersSettings() -> [UserSettings]
    func saveSettings(_ settings: ChatSettings) async
    func loadSettings() -> ChatSettings
    func challengePassed() async
    func challengeDates() -> [Date]
    
    // KeyChain
    func saveNewMeetingVisiting()
    func getTodayMeetingVisited() -> Int
}

class ChatPersistence: ChatPersistenceProtocol {
    
    private let keychain = KeychainSwift()
    
    init() {

    }
    
    func getTodayMeetingVisited() -> Int {
        if let visited = keychain.get("visitedMeetings"),
           let lastDateString = keychain.get("lastMeetingVisitedDate"),
           let lastDate = Date.fromString(lastDateString) {
            let lastDateReset = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: lastDate)!
            let currentDateRest = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
            if lastDateReset == currentDateRest {
                return Int(visited) ?? 99
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func saveNewMeetingVisiting() {
        if let visited = keychain.get("visitedMeetings"),
           var lastVisitedInt = Int(visited) {
            lastVisitedInt += 1
            keychain.set("\(lastVisitedInt)", forKey: "visitedMeetings")
            keychain.set("\(Date().toString())", forKey: "lastMeetingVisitedDate")
            
        } else {
            keychain.set("1", forKey: "visitedMeetings")
        }
    }
    
    func saveUserSettings(settings: UserSettings) async {
        await withCheckedContinuation { continuation in
            context.perform {
                self.context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                let userSettings = CDUserSettings(context: self.context)
                userSettings.id = Int64(settings.id)
                userSettings.isBot = settings.isBot
                userSettings.userName = settings.userName
                userSettings.avatarName = settings.avatarName
                userSettings.gender = settings.gender.rawValue
                userSettings.userRole = settings.userRole.rawValue
                userSettings.englishLevel = settings.englishLevel.rawValue
                
                do {
                    try self.context.save()
                    continuation.resume()
                } catch {
                    print("⛔️⛔️⛔️⛔️⛔️", error)
                    continuation.resume()
                }
            }
        }
    }
    
    func loadAllUsersSettings() -> [UserSettings] {
        let request = CDUserSettings.fetchRequest()
        guard let userSettings = try? context.fetch(request) else { return createMembers() }
        if !userSettings.contains(where: {$0.isBot == true}) {
            return createMembers()
        } else {
            return userSettings.map {
                UserSettings(id: Int($0.id),
                             isBot: $0.isBot,
                             userName: $0.userName ?? "",
                             avatarName: $0.avatarName,
                             gender: UserGender.init(rawValue: $0.gender ?? "") ?? .male,
                             userRole: UserRole.init(rawValue: $0.userRole ?? "") ?? .frontend,
                             englishLevel: EnglishLevel.init(rawValue: $0.englishLevel ?? "") ?? .elementary)
            }
        }
    }
    
    func saveSettings(_ settings: ChatSettings) async {
        await withCheckedContinuation { continuation in
            context.perform {
                self.context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                let chatSettings = CDChatSettings(context: self.context)
                chatSettings.companyDetails = settings.companyDetails
                chatSettings.isPremium = settings.isPremium
                chatSettings.voiceOver = settings.voiceOver
                chatSettings.userOnboarded = settings.userOnboarded
                chatSettings.id = "123"
                do {
                    try self.context.save()
                    continuation.resume()
                } catch {
                    print("⛔️⛔️⛔️⛔️⛔️", error)
                    continuation.resume()
                }
            }
        }
    }
    
    func loadSettings() -> ChatSettings {
        let request = CDChatSettings.fetchRequest()
        guard let chatSettings = try? context.fetch(request).first else { return createSettings() }
        
        return ChatSettings(companyDetails: chatSettings.companyDetails,
                            voiceOver: chatSettings.voiceOver,
                            isPremium: chatSettings.isPremium,
                            userOnboarded: chatSettings.userOnboarded)
    }
    
    func challengePassed() async {
        await withCheckedContinuation { continuation in
            context.perform {
                self.context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                let date = CDChallengeDate(context: self.context)
                date.date = Date()
                do {
                    try self.context.save()
                    continuation.resume()
                } catch {
                    print("⛔️⛔️⛔️⛔️⛔️", error)
                    continuation.resume()
                }
            }
        }
    }
    
    func challengeDates() -> [Date] {
        let request = CDChallengeDate.fetchRequest()
        var dates: [Date] = []
        guard let response = try? context.fetch(request) else { return [] }
        
        for date in response {
            if let date = date.date {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    
    
    private func createSettings() -> ChatSettings {
        let chatSettings = ChatSettings(voiceOver: true,
                                        isPremium: false,
                                        userOnboarded: false)
        
        Task {
            await saveSettings(chatSettings)
        }
        
        return chatSettings
    }
    
    private func createMembers() -> [UserSettings] {
        let defaultMembers = [
        UserSettings(id: 1,
                     isBot: true,
                     userName: "Ethan Thompson",
                     avatarName: "avatar_5",
                     gender: .male,
                     userRole: .teamLead,
                     englishLevel: .preIntermediate),
        UserSettings(id: 2,
                     isBot: true,
                     userName: "Daniel Williams",
                     avatarName: "avatar_13",
                     gender: .male,
                     userRole: .backend,
                     englishLevel: .preIntermediate),
        UserSettings(id: 3,
                     isBot: true,
                     userName: "Sophia Martinez",
                     avatarName: "avatar_12",
                     gender: .female,
                     userRole: .designer,
                     englishLevel: .preIntermediate)
        ]
        
        for member in defaultMembers {
            Task {
                await saveUserSettings(settings: member)
            }
        }
        return defaultMembers
    }
    
    private let model = "ChatDataModel"
    
    private lazy var persistentContainer: NSPersistentContainer = {
      return createContainer()
    }()
    
    private lazy var context: NSManagedObjectContext = {
        return createContext()
    }()
    
    private func createContainer() -> NSPersistentContainer {
        let bundle = Bundle(for: Self.self)
        let url = bundle.url(forResource: model, withExtension: "momd")
        let managedObjectModel = NSManagedObjectModel(contentsOf: url!)
        let container = NSPersistentContainer(name: model, managedObjectModel: managedObjectModel!)
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        container.persistentStoreDescriptions = [description]
        
        return container
    }
    
    private func createContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        return context
    }
}

class ChatPersistenceMock: ChatPersistenceProtocol {
    func saveUserSettings(settings: UserSettings) async {}
    func loadAllUsersSettings() -> [UserSettings] {
        let users: [UserSettings] = [
            UserSettings(id: 0,
                         isBot: false,
                         userName: "Ivan Stepanok",
                         avatarName: "avatar_0",
                         gender: .male,
                         userRole: .teamLead,
                         englishLevel: .preIntermediate),
            UserSettings(id: 1,
                         isBot: true,
                         userName: "Igor Kondratuk",
                         avatarName: "avatar_5",
                         gender: .male,
                         userRole: .teamLead,
                         englishLevel: .preIntermediate),
            UserSettings(id: 2,
                         isBot: true,
                         userName: "Natalie Kovalengo",
                         avatarName: "avatar_4",
                         gender: .female,
                         userRole: .backend,
                         englishLevel: .preIntermediate),
            UserSettings(id: 3,
                         isBot: true,
                         userName: "Serhii Dorozhny",
                         avatarName: "avatar_11",
                         gender: .male,
                         userRole: .designer,
                         englishLevel: .preIntermediate)
        ]
        
        return users
    }
    func saveSettings(_ settings: ChatSettings) async {}
    func loadSettings() -> ChatSettings {
        ChatSettings(voiceOver: true,
                     isPremium: false,
                     userOnboarded: false)
    }
    
    func challengePassed() async {
        
    }
    
    func challengeDates() -> [Date] {
        return []
    }
    
    func saveNewMeetingVisiting() {}
    func getTodayMeetingVisited() -> Int {0}
}
