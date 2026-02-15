//
//  CreateEventTool.swift
//  OnDeviceLLMExp
//
//  Created by Nikita Nikitin on 2026-02-14.
//

import Foundation
import FoundationModels

// Looks like LLM doesn't now what the day is today

struct CreateEventTool: Tool {
    let name = "createEvent"
    
    var description: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        return "Creates a calendar event using EventKit. Today's date is \(today). When creating events, use dates relative to today or in the future unless the user specifically requests a past date."
    }

    @Generable
    struct Arguments {
        @Guide(description: "The title of the event")
        var title: String

        @Guide(description: "The start date and time of the event in yyyy-MM-ddTHH:mm:ss format. Use dates relative to today's date.")
        var startDate: String

        @Guide(description: "The end date and time of the event in yyyy-MM-ddTHH:mm:ss format")
        var endDate: String
    }

    let eventsUtils: EventsUtils

    func call(arguments: Arguments) async throws -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone.current
        
        guard let start = formatter.date(from: arguments.startDate),
              let end = formatter.date(from: arguments.endDate) else {
            return "Failed to parse the event start or end time. Expected format: yyyy-MM-ddTHH:mm:ss"
        }
        
        guard end > start else {
            return "End date must be after start date."
        }
        
        let success = try await eventsUtils.createEvent(
            title: arguments.title,
            startDate: start,
            endDate: end
        )
        
        if success {
            return "Successfully created the event '\(arguments.title)' from \(arguments.startDate) to \(arguments.endDate)."
        } else {
            return "Failed to create the event '\(arguments.title)'."
        }
    }
}
