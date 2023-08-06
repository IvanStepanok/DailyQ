//
//  ChatPersistence.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import CoreData
import Combine
import SwiftUI

protocol ChatPersistenceProtocol {
    func saveUserSettings(settings: UserSettings) async
    func loadAllUsersSettings() -> [UserSettings]
    func saveSettings(_ settings: ChatSettings) async
    func loadSettings() -> ChatSettings
}

class ChatPersistence: ChatPersistenceProtocol {
    
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
                chatSettings.agenda = settings.agenda
                chatSettings.isPurchaced = settings.isPurchaced
                chatSettings.voiceOver = settings.voiceOver
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
        
        return ChatSettings(agenda: chatSettings.agenda,
                            voiceOver: chatSettings.voiceOver,
                            isPurchaced: chatSettings.isPurchaced)        
    }
    
    private func createSettings() -> ChatSettings {
        let chatSettings = ChatSettings(voiceOver: true, isPurchaced: false)
        
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
