//
//  ContentView.swift
//  OnDeviceLLMExp
//
//  Created by Nikita Nikitin on 2026-02-14.
//

import SwiftUI

struct ContentView: View {
    let repository: ChatRepository
    let llmManager: LLMMManager
    
    var body: some View {
        ChatView(repository: repository, llmManager: llmManager)
    }
}
