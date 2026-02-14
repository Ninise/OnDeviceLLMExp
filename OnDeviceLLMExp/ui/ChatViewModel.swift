//
//  ChatViewModel.swift
//  OnDeviceLLMExp
//
//  Created by Nikita Nikitin on 2026-02-14.
//

import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message]
    @Published var input = ""
    @Published var isResponding = false
    
    private let repository: ChatRepository
    private let llmManager: LLMMManager
    
    init(repository: ChatRepository, llmManager: LLMMManager) {
        self.repository = repository
        self.llmManager = llmManager
        self.messages = repository.messages
        
        self.subscribeToMessages()
        self.subscribeToResponding()
        
        Task { @MainActor in
            let eventsUtils = EventsUtils()
            do {
                try await eventsUtils.ensureAccess()
                print("Events access ensured successfully")
            } catch {
                print("Failed to ensure events access: \(error)")
            }
        }
    }
    
    func onSendTap() {
        let content = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard content.isEmpty == false else { return }
        Task {
            repository.sendMessage(content)
            input.removeAll()
        }
    }
}

// MARK: Subscriptions
extension ChatViewModel {
    private func subscribeToMessages() {
        repository.$messages
            .receive(on: DispatchQueue.main)
            .assign(to: &$messages)
    }
    
    private func subscribeToResponding() {
        llmManager.$isResponding
            .receive(on: DispatchQueue.main)
            .assign(to: &$isResponding)
    }
}

