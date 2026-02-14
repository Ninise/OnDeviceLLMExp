//
//  ChatRepository.swift
//  OnDeviceLLMExp
//
//  Created by Nikita Nikitin on 2026-02-14.
//

import Foundation
import Combine

final class ChatRepository {
    @Published private(set) var messages: [Message] = []
    
    private let llmManager: LLMMManager
    
    init(llmManager: LLMMManager) {
        self.llmManager = llmManager
        checkModelAvailabilityAndTellUser()
    }
    
    // MARK: - Public Methods
    
    /// Send a message to the chat
    func sendMessage(_ content: String, isFromUser: Bool = true) {
        let message = Message(content: content, isFromUser: isFromUser, timestamp: Date())
        messages.append(message)
        
        if isFromUser {
            Task {
                let llmReply = try await llmManager.generateResponse(for: content)
                sendMessage(llmReply, isFromUser: false)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Check if on device model is available and send a message about the availability
    private func checkModelAvailabilityAndTellUser() {
        let (_, content) = llmManager.checkModelAvailability()
        sendMessage(content, isFromUser: false)
    }
}
