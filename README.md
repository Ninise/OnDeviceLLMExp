# 🤖 OnDeviceLLM Chat

A privacy-first iOS chat application powered by Apple's **FoundationModels** framework, bringing AI assistance directly to your device—no internet required, no data leaves your phone.

## ✨ Features

### 🧠 100% On-Device AI
- Powered by iOS 18's native FoundationModels framework
- All processing happens locally on your iPhone
- Zero cloud dependencies, complete privacy
- Works offline

### 🛠️ Smart Tool Integration
Your AI assistant can actually *do* things:

- **📅 Calendar Events** - "Schedule a dentist appointment for next Tuesday at 2pm"
- **✅ Reminders** - "Remind me to buy milk tomorrow morning"
- **📝 Notes** - "Summarize our conversation and save it as a note"

The LLM understands context, parses dates naturally, and creates real entries in your native iOS apps.

## 🎯 Why This Project?

Most AI chat apps send your data to the cloud. This one doesn't. Ever.

- **Private**: Your conversations never leave your device
- **Fast**: No network latency, instant responses
- **Reliable**: Works on airplane mode
- **Native**: Deep iOS integration with Calendar, Reminders, and Notes

## 🏗️ Architecture
```
┌─────────────────────────────────────────┐
│          Chat Interface (SwiftUI)        │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      FoundationModels Framework          │
│      (Local LLM - iOS 18+)               │
└──────────────┬──────────────────────────┘
               │
       ┌───────┴───────┐
       │               │
┌──────▼─────┐  ┌─────▼──────┐
│   Tools     │  │  EventKit  │
│  System     │  │  Framework │
└─────────────┘  └────────────┘
       │               │
┌──────▼───────────────▼──────┐
│  Calendar  Reminders  Notes  │
└──────────────────────────────┘
```

## 🚀 Getting Started

### Requirements
- iOS 18.0+ (FoundationModels availability)
- Xcode 16+
- iPhone (FoundationModels not available on simulator in early betas)

### Setup

1. **Clone the repository**
```bash
   git clone https://github.com/yourusername/OnDeviceLLMExp.git
   cd OnDeviceLLMExp
```

2. **Open in Xcode**
```bash
   open OnDeviceLLMExp.xcodeproj
```

3. **Configure permissions**
   
   Already configured in `Info.plist`:
   - `NSCalendarsUsageDescription` - For creating calendar events
   - `NSRemindersUsageDescription` - For creating reminders

4. **Build and Run**
   - Select your device (FoundationModels requires physical device)
   - Cmd+R to build and run
   - Grant permissions when prompted

## 🎮 Usage Examples

### Natural Language → Real Actions

**Creating Events:**
```
You: "Schedule a team meeting next Friday at 3pm for 2 hours"
AI: ✅ Created event "Team Meeting" on March 21, 2026, 3:00 PM - 5:00 PM
```

**Setting Reminders:**
```
You: "Remind me to call the dentist tomorrow morning"
AI: ✅ Created high-priority reminder "Call the dentist" due tomorrow at 9:00 AM
```

**Saving Conversations:**
```
You: "Summarize what we discussed and save it"
AI: ✅ Created note "Meeting Action Items" with key points and decisions
```

## 🔧 Tools System

Each tool follows a clean protocol-based architecture:
```swift
struct CreateEventTool: Tool {
    let name = "createEvent"
    var description: String { /* Dynamic with current date */ }
    
    @Generable
    struct Arguments {
        @Guide(description: "The title of the event")
        var title: String
        
        @Guide(description: "Start date in yyyy-MM-ddTHH:mm:ss format")
        var startDate: String
        
        @Guide(description: "End date in yyyy-MM-ddTHH:mm:ss format")
        var endDate: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        // Implementation
    }
}
```

### Available Tools

| Tool | Purpose | iOS Framework |
|------|---------|---------------|
| `createEvent` | Add calendar events | EventKit |
| `createReminder` | Create reminders with due dates | EventKit |
| `createNote` | Save conversation summaries | Files/Share |

### Adding Custom Tools

1. Create a new struct conforming to `Tool` protocol
2. Define `@Generable` arguments with `@Guide` descriptions
3. Implement `call(arguments:)` async function
4. Add to tools array in your chat controller

## 🏛️ Core Components

### EventsUtils
Manages calendar event creation with robust error handling:
- Permission management (iOS 17+ full access support)
- Custom calendar creation
- Event validation and persistence
- Comprehensive logging

### RemindersUtils  
Handles reminder creation:
- Separate permission flow
- Custom reminder lists
- Priority levels (high, medium, low)
- Due date parsing

### Tool Protocol
Generic tool system allowing LLM to interact with iOS:
- Type-safe argument parsing
- Async/await native support
- Clear error propagation
- LLM-friendly descriptions

## 🔐 Privacy & Security

- ✅ All AI inference happens on-device
- ✅ No network calls for LLM processing
- ✅ User controls all permission grants
- ✅ Data stored only in native iOS apps (Calendar, Reminders)
- ✅ No telemetry or analytics
- ✅ Open source - audit the code yourself

## 🐛 Troubleshooting

**"Permissions stuck/not requesting"**
- Ensure `Info.plist` contains required usage descriptions
- Delete app and reinstall after adding new permissions
- Check Settings → Privacy → Calendars/Reminders

**"Events created but with wrong dates"**
- LLM needs context about current date
- Tool descriptions include dynamic timestamps
- Check date format: `yyyy-MM-ddTHH:mm:ss`

**"FoundationModels not available"**
- Requires iOS 18.0+
- Must run on physical device (not simulator in early betas)
- Check device compatibility

## 🛣️ Roadmap

- [ ] Location-based reminders
- [ ] Multi-turn conversation memory
- [ ] Voice input/output

## 🤝 Contributing

Contributions welcome! Areas of interest:
- New tool implementations
- UI/UX improvements
- Performance optimizations
- Documentation

## 📄 License

MIT License - see [LICENSE](LICENSE) file

## 🙏 Acknowledgments

- Apple's FoundationModels team for bringing on-device LLMs to iOS
- EventKit framework for calendar/reminder integration
- The iOS developer community

## 📬 Contact

- GitHub: [@yourusername](https://github.com/yourusername)
- Twitter: [@yourhandle](https://twitter.com/yourhandle)

---

**Built with ❤️ and SwiftUI. Privacy matters.**