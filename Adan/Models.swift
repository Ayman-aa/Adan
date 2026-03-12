import Foundation
import SwiftUI

// MARK: - Design System
extension Color {
    static let adanNavy      = Color(red: 0.06, green: 0.13, blue: 0.27)
    static let adanBlue      = Color(red: 0.16, green: 0.32, blue: 0.60)
    static let adanGold      = Color(red: 0.79, green: 0.66, blue: 0.30)
    static let adanCream     = Color(red: 0.94, green: 0.90, blue: 0.78)
    static let adanCardLight = Color(red: 0.97, green: 0.95, blue: 0.90)
    static let adanCardDark  = Color(red: 0.10, green: 0.18, blue: 0.32)
}

// MARK: - Model
struct PrayerTime {
    let name: String
    let time: Date
}
