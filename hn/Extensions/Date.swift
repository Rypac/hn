import Foundation

extension Date {
    func relative(to date: Date) -> String {
        let interval = timeIntervalSince(date) * -1
        switch interval {
        case let x where x < 1:
            return "now"
        case 1..<60:
            return "just now"
        case 60..<3_600:
            return "\(Int(round(interval / 60))) minutes ago"
        case 3_600..<86_400:
            return "\(Int(round(interval / 3_600))) hours ago"
        default:
            return "\(Int(round(interval / 86_400))) days ago"
        }
    }
}
