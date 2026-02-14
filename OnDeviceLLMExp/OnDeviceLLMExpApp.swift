//
//  OnDeviceLLMExpApp.swift
//  OnDeviceLLMExp
//
//  Created by Nikita Nikitin on 2026-02-14.
//

import SwiftUI

@main
struct OnDeviceLLMExpApp: App {
    private let llmManager: LLMMManager
    
    init() {
        let eventsUtils = EventsUtils()
        let llmManager = LLMMManager(eventsUtils: eventsUtils)
        self.llmManager = llmManager
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                repository: ChatRepository(llmManager: self.llmManager),
                llmManager: self.llmManager
            )
        }
    }
}
