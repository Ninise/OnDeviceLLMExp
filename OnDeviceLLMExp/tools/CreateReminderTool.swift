//
//  CreateReminderTool.swift
//  OnDeviceLLMExp
//
//  Created by Nikita Nikitin on 2026-02-15.
//

import Foundation
import EventKit
import FoundationModels

struct CreateReminderTool: Tool {
    let name = "createReminder"
    
    var description: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        return "Creates a reminder in the Reminders app. Today's date is \(today). Use this for tasks, to-dos, and things the user needs to remember. Can set due dates and times."
    }
    
    @Generable
    struct Arguments {
        @Guide(description: "The title/task of the reminder")
        var title: String
        
        @Guide(description: "Optional: Due date and time in yyyy-MM-ddTHH:mm:ss format. Leave empty for no due date.")
        var dueDate: String?
        
        @Guide(description: "Optional: Priority level - 'high', 'medium', 'low', or 'none'. Default is 'none'.")
        var priority: String?
        
        @Guide(description: "Optional: Additional notes or details about the reminder")
        var notes: String?
        
        @Guide(description: "Optional: List name in Reminders app. If not specified, uses default list.")
        var listName: String?
    }
    
    let remindersUtils: RemindersUtils
    
    func call(arguments: Arguments) async throws -> String {
        // Parse optional due date
        var dueDate: Date? = nil
        if let dueDateString = arguments.dueDate, !dueDateString.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            formatter.timeZone = TimeZone.current
            
            guard let parsedDate = formatter.date(from: dueDateString) else {
                return "Failed to parse due date. Expected format: yyyy-MM-ddTHH:mm:ss"
            }
            dueDate = parsedDate
        }
        
        // Parse priority
        let priorityValue: Int
        switch arguments.priority?.lowercased() {
        case "high":
            priorityValue = 1
        case "medium":
            priorityValue = 5
        case "low":
            priorityValue = 9
        default:
            priorityValue = 0 // none
        }
        
        let success = try await remindersUtils.createReminder(
            title: arguments.title,
            dueDate: dueDate,
            priority: priorityValue,
            notes: arguments.notes,
            listName: arguments.listName ?? "LLM Reminders"
        )
        
        if success {
            var message = "✅ Successfully created reminder '\(arguments.title)'"
            if let dueDate = dueDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                message += " due \(formatter.string(from: dueDate))"
            }
            return message
        } else {
            return "Failed to create reminder '\(arguments.title)'."
        }
    }
}
