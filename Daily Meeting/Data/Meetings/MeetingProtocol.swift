//
//  MeetingProtocol.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 10.08.2023.
//

import Foundation

protocol MeetingProtocol {
    var members: [UserSettings] { get }
    var tasks: String? { get set }
    var meetingName: String { get set }
    func promt() async -> String
}
