import Foundation

extension Date {
    func relative(to date: Date) -> String {
        let interval = timeIntervalSince(date) * -1
        if interval < 1 {
            return "now"
        } else if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let diff = Int(round(interval / 60))
            return "\(diff) minutes ago"
        } else if interval < 86400 {
            let diff = Int(round(interval / 3600))
            return "\(diff) hours ago"
        }
        let diff = Int(round(interval / 86400))
        return "\(diff) days ago"
    }
}
