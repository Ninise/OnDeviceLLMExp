//
//  RemindersUtils.swift
//  OnDeviceLLMExp
//
//  Created by Nikita Nikitin on 2026-02-15.
//

import Foundation
import EventKit
import UIKit

enum ReminderError: Error {
    case unauthorized
    case noWritableSource
    case listSaveFailed(Error)
    case reminderSaveFailed(Error)
}

@MainActor
class RemindersUtils {
    private let eventStore = EKEventStore()
    
    init() {}
    
    /// Request access to reminders
    func ensureAccess() async throws -> Bool {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        
        switch status {
        case .fullAccess, .authorized:
            return true
        case .writeOnly:
            return true
        case .notDetermined:
            if #available(iOS 17.0, *) {
                return try await eventStore.requestFullAccessToReminders()
            } else {
                return try await eventStore.requestAccess(to: .reminder)
            }
        case .denied, .restricted:
            throw ReminderError.unauthorized
        @unknown default:
            throw ReminderError.unauthorized
        }
    }
    
    /// Creates a reminder in a specific list
    func createReminder(
        title: String,
        dueDate: Date? = nil,
        priority: Int = 0,
        notes: String? = nil,
        listName: String = "LLM Reminders"
    ) async throws -> Bool {
        print("🔵 Starting createReminder for: \(title)")
        
        // 1. Ensure Permissions
        print("🔵 Checking permissions...")
        let granted = try await ensureAccess()
        guard granted else { throw ReminderError.unauthorized }
        print("✅ Permissions granted")
        
        // 2. Get or Create the List
        print("🔵 Getting/creating list: \(listName)")
        let targetList = try createListIfNeeded(named: listName)
        print("✅ Using list: \(targetList.title), ID: \(targetList.calendarIdentifier)")
        
        // 3. Build and Save Reminder
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.calendar = targetList
        
        if let dueDate = dueDate {
            reminder.dueDateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: dueDate
            )
        }
        
        reminder.priority = priority
        
        if let notes = notes {
            reminder.notes = notes
        }
        
        print("🔵 Saving reminder: \(title)")
        if let dueDate = dueDate {
            print("   Due: \(dueDate)")
        }
        print("   Priority: \(priority)")
        print("   List: \(targetList.title)")
        
        do {
            try eventStore.save(reminder, commit: true)
            print("✅ Reminder saved successfully! ID: \(reminder.calendarItemIdentifier)")
            
            // Verify the reminder was saved
            if let savedReminder = eventStore.calendarItem(withIdentifier: reminder.calendarItemIdentifier) as? EKReminder {
                print("✅ Verified: Reminder exists with title: \(savedReminder.title ?? "no title")")
            } else {
                print("⚠️ Warning: Could not verify reminder was saved")
            }
            
            return true
        } catch {
            print("❌ Failed to save reminder: \(error.localizedDescription)")
            throw ReminderError.reminderSaveFailed(error)
        }
    }
    
    private func createListIfNeeded(named name: String) throws -> EKCalendar {
        // Check if list exists
        let lists = eventStore.calendars(for: .reminder)
        print("🔵 Available reminder lists: \(lists.map { "\($0.title) (\($0.source.title))" })")
        
        if let existing = lists.first(where: { $0.title == name && $0.allowsContentModifications }) {
            print("✅ Found existing list: \(existing.title)")
            print("   Source: \(existing.source.title)")
            print("   Allows modifications: \(existing.allowsContentModifications)")
            return existing
        }
        
        print("🔵 List '\(name)' not found, creating new one...")
        guard let source = resolveWritableSource() else {
            print("❌ No writable source found!")
            throw ReminderError.noWritableSource
        }
        
        print("✅ Using source: \(source.title) (type: \(source.sourceType.rawValue))")
        
        let newList = EKCalendar(for: .reminder, eventStore: eventStore)
        newList.title = name
        newList.source = source
        newList.cgColor = UIColor.systemOrange.cgColor
        
        do {
            try eventStore.saveCalendar(newList, commit: true)
            print("✅ List created successfully: \(newList.calendarIdentifier)")
            return newList
        } catch {
            print("❌ Failed to create list: \(error.localizedDescription)")
            throw ReminderError.listSaveFailed(error)
        }
    }
    
    private func resolveWritableSource() -> EKSource? {
        let sources = eventStore.sources
        
        // Priority 1: iCloud
        if let iCloud = sources.first(where: { $0.sourceType == .calDAV && $0.title.contains("iCloud") }) {
            return iCloud
        }
        // Priority 2: Local
        if let local = sources.first(where: { $0.sourceType == .local }) {
            return local
        }
        // Priority 3: Any writable source
        return sources.first { $0.sourceType != .birthdays && $0.sourceType != .subscribed }
    }
}
