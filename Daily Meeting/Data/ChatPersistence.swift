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
    func saveUserSettings(settings: String) async
    
}
