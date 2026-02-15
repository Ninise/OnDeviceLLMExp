//
//  CreateNoteTool.swift
//  OnDeviceLLMExp
//
//  Created by Nikita Nikitin on 2026-02-15.
//

import Foundation
import FoundationModels

struct CreateNoteTool: Tool {
    let name = "createNote"
    
    var description: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let now = formatter.string(from: Date())
        return "Creates a note with the provided title and content. Current date/time is \(now). Use this to save conversation summaries, action items, or important information discussed."
    }
    
    @Generable
    struct Arguments {
        @Guide(description: "The title of the note")
        var title: String
        
        @Guide(description: "The detailed content of the note. Include all relevant information, summaries, or action items.")
        var content: String
        
        @Guide(description: "Optional folder name in Notes app. If not specified, saves to default folder.")
        var folder: String?
    }
    
    func call(arguments: Arguments) async throws -> String {
        // Create the note content with title and timestamp
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        let timestamp = formatter.string(from: Date())
        
        let noteContent = """
        \(arguments.title)
        
        Created: \(timestamp)
        
        \(arguments.content)
        """
        
        // Save to a file that can be shared/exported
        let fileName = "\(arguments.title.replacingOccurrences(of: " ", with: "_")).txt"
        let fileManager = FileManager.default
        
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return "Failed to access documents directory."
        }
        
        let filePath = documentsPath.appendingPathComponent(fileName)
        
        do {
            try noteContent.write(to: filePath, atomically: true, encoding: .utf8)
            
            // Return success with file location
            return """
            ✅ Successfully created note '\(arguments.title)'
            
            The note has been saved and can be:
            - Shared via the Files app
            - Opened in Notes or any text editor
            - Found at: Documents/\(fileName)
            
            Would you like me to help you with anything else?
            """
        } catch {
            return "❌ Failed to create note: \(error.localizedDescription)"
        }
    }
}
