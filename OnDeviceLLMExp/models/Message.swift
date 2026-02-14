//
//  Message.swift
//  OnDeviceLLMExp
//
//  Created by Nikita Nikitin on 2026-02-14.
//

import Foundation

struct Message: Equatable, Identifiable {
    let id: UUID = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
}
