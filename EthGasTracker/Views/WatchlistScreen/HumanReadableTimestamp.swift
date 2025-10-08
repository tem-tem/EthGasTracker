import SwiftUI

/// A view that displays a timestamp in a human-readable format
/// For time ranges > 1 hour, shows the relative time in brackets
struct HumanReadableTimestamp: View {
    let date: Date
    
    init(date: Date) {
        self.date = date
    }
    
    init?(iso8601String: String) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let parsedDate = formatter.date(from: iso8601String) else {
            print("iso8601String could not be parsed \(iso8601String)")
            return nil
        }
        
        self.date = parsedDate
    }
    
    var body: some View {
        Text(formattedText)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    private var formattedText: String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        let seconds = Int(timeInterval)
        
        // < 60 seconds
        if seconds < 60 {
            return "Just now"
        }
        
        let minutes = seconds / 60
        
        // < 2 minutes
        if minutes < 2 {
            return "1 min ago"
        }
        
        // < 60 minutes
        if minutes < 60 {
            return "\(minutes) min ago"
        }
        
        let hours = minutes / 60
        
        // < 2 hours
        if hours < 2 {
            return "1 h ago"
        }
        
        let calendar = Calendar.current
        
        // < 24 hours - show actual time with relative in brackets
        if hours < 24 {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            let timeString = timeFormatter.string(from: date)
            return "\(timeString) (\(hours) hours ago)"
        }
        
        let days = hours / 24
        
        // < 48 hours
        if days < 2 {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            let timeString = timeFormatter.string(from: date)
            return "Yesterday \(timeString) (\(hours) hours ago)"
        }
        
        // < 7 days - show day of week with time
        if days < 7 {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE h:mm a"
            let formatted = dayFormatter.string(from: date)
            return "\(formatted) (\(days) days ago)"
        }
        
        // < 30 days - show abbreviated month and day
        if days < 30 {
            let monthDayFormatter = DateFormatter()
            monthDayFormatter.dateFormat = "MMM d"
            let formatted = monthDayFormatter.string(from: date)
            return "\(formatted) (\(days) days ago)"
        }
        
        // Check if same year
        let dateYear = calendar.component(.year, from: date)
        let currentYear = calendar.component(.year, from: now)
        
        if dateYear == currentYear {
            // Same year - show month and day
            let monthDayFormatter = DateFormatter()
            monthDayFormatter.dateFormat = "MMM d"
            let formatted = monthDayFormatter.string(from: date)
            
            // Calculate relative time for bracket
            let months = calendar.dateComponents([.month], from: date, to: now).month ?? 0
            if months > 0 {
                return "\(formatted) (\(months) \(months == 1 ? "month" : "months") ago)"
            } else {
                return "\(formatted) (\(days) days ago)"
            }
        } else {
            // Different year - include year
            let fullFormatter = DateFormatter()
            fullFormatter.dateFormat = "MMM d yyyy"
            let formatted = fullFormatter.string(from: date)
            
            // Calculate years for bracket
            let years = calendar.dateComponents([.year], from: date, to: now).year ?? 0
            if years > 0 {
                return "\(formatted) (\(years) \(years == 1 ? "year" : "years") ago)"
            } else {
                let months = calendar.dateComponents([.month], from: date, to: now).month ?? 0
                return "\(formatted) (\(months) \(months == 1 ? "month" : "months") ago)"
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(alignment: .leading, spacing: 12) {
        Group {
            HumanReadableTimestamp(date: Date().addingTimeInterval(-30))
            HumanReadableTimestamp(date: Date().addingTimeInterval(-90))
            HumanReadableTimestamp(date: Date().addingTimeInterval(-600))
            HumanReadableTimestamp(date: Date().addingTimeInterval(-1800))
            HumanReadableTimestamp(date: Date().addingTimeInterval(-3600))
            HumanReadableTimestamp(date: Date().addingTimeInterval(-7200))
            HumanReadableTimestamp(date: Date().addingTimeInterval(-18000))
            HumanReadableTimestamp(date: Date().addingTimeInterval(-86400))
            HumanReadableTimestamp(date: Date().addingTimeInterval(-86400 * 1.5))
            HumanReadableTimestamp(date: Date().addingTimeInterval(-86400 * 3))
        }
        
        Group {
            HumanReadableTimestamp(date: Date().addingTimeInterval(-86400 * 7))
            HumanReadableTimestamp(date: Date().addingTimeInterval(-86400 * 15))
            HumanReadableTimestamp(date: Date().addingTimeInterval(-86400 * 45))
            HumanReadableTimestamp(date: Date().addingTimeInterval(-86400 * 180))
            HumanReadableTimestamp(date: Date().addingTimeInterval(-86400 * 400))
        }
    }
    .padding()
}

