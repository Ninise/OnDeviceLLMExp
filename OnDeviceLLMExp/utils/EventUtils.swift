import Foundation
import EventKit
import UIKit

enum CalendarError: Error {
    case unauthorized
    case noWritableSource
    case calendarSaveFailed(Error)
    case eventSaveFailed(Error)
    case invalidDateRange
}

@MainActor
class EventsUtils {
    private let eventStore = EKEventStore()

    init() {}

    func ensureAccess() async throws -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .fullAccess, .authorized:
            return true
        case .writeOnly:
            return true
        case .notDetermined:
            if #available(iOS 17.0, *) {
                return try await eventStore.requestFullAccessToEvents()
            } else {
                return try await eventStore.requestAccess(to: .event)
            }
        case .denied, .restricted:
            throw CalendarError.unauthorized
        @unknown default:
            throw CalendarError.unauthorized
        }
    }

    /// Creates an event in a specific named calendar
    func createEvent(title: String, startDate: Date, endDate: Date, inCalendarNamed calendarName: String = "LLM_TEST_CALENDAR") async throws -> Bool {
        
        // 1. Validation
        guard endDate > startDate else { throw CalendarError.invalidDateRange }
        
        // 2. Ensure Permissions
        let granted = try await ensureAccess()
        guard granted else { throw CalendarError.unauthorized }
        
        // 3. Get or Create the Calendar
        let targetCalendar = try createCalendarIfNeeded(named: calendarName)

        // 4. Build and Save Event
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = targetCalendar
        
        do {
            try eventStore.save(event, span: .thisEvent, commit: true)
            return true
        } catch {
            throw CalendarError.eventSaveFailed(error)
        }
    }

    private func createCalendarIfNeeded(named name: String) throws -> EKCalendar {
        let calendars = eventStore.calendars(for: .event)
        
        if let existing = calendars.first(where: { $0.title == name && $0.allowsContentModifications }) {
            return existing
        }

        guard let source = resolveWritableSource() else {
            throw CalendarError.noWritableSource
        }
        
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = name
        newCalendar.source = source
        newCalendar.cgColor = UIColor.systemBlue.cgColor

        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            return newCalendar
        } catch {
            throw CalendarError.calendarSaveFailed(error)
        }
    }

    private func resolveWritableSource() -> EKSource? {
        let sources = eventStore.sources
        
        // Priority 1: iCloud
        if let iCloud = sources.first(where: { $0.sourceType == .calDAV && $0.title.contains("iCloud") }) {
            return iCloud
        }
        // Priority 2: Local (Common for users not signed into iCloud)
        if let local = sources.first(where: { $0.sourceType == .local }) {
            return local
        }
        // Priority 3: Any writable source
        return sources.first { $0.sourceType != .birthdays && $0.sourceType != .subscribed }
    }
}
