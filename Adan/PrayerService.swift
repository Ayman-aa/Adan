import Foundation

let appGroupID = "group.com.aymanaa.adan"

struct PrayerResponse: Codable {
    let data: PrayerData
}

struct PrayerData: Codable {
    let timings: PrayerTimings
}

struct PrayerTimings: Codable {
    let Fajr: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}

func fetchPrayerTimes(latitude: Double, longitude: Double) async throws -> [PrayerTime] {
    let url = URL(string: "https://api.aladhan.com/v1/timings?latitude=\(latitude)&longitude=\(longitude)&method=2")!

    let (data, _) = try await URLSession.shared.data(from: url)
    let response = try JSONDecoder().decode(PrayerResponse.self, from: data)

    let timings = response.data.timings
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    formatter.timeZone = .current

    func parse(_ string: String) -> Date {
        let cleaned = String(string.prefix(5)) // strip any extra chars like "(+01)"
        guard let parsed = formatter.date(from: cleaned) else { return Date() }
        
        // apply today's date to the parsed time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: parsed)
        return calendar.date(bySettingHour: components.hour ?? 0,
                            minute: components.minute ?? 0,
                            second: 0,
                            of: Date()) ?? Date()
    }

    let prayers = [
        PrayerTime(name: "Fajr",    time: parse(timings.Fajr)),
        PrayerTime(name: "Dhuhr",   time: parse(timings.Dhuhr)),
        PrayerTime(name: "Asr",     time: parse(timings.Asr)),
        PrayerTime(name: "Maghrib", time: parse(timings.Maghrib)),
        PrayerTime(name: "Isha",    time: parse(timings.Isha))
    ]

    savePrayersToSharedStorage(prayers)
    return prayers
}

func savePrayersToSharedStorage(_ prayers: [PrayerTime]) {
    let defaults = UserDefaults(suiteName: appGroupID)
    let data = prayers.map { ["name": $0.name, "time": $0.time.timeIntervalSince1970] }
    defaults?.set(data, forKey: "prayers")
    print("💾 Saved to app group: \(appGroupID)")
    print("💾 Data: \(data)")
}

func loadPrayersFromSharedStorage() -> [PrayerTime]? {
    let defaults = UserDefaults(suiteName: appGroupID)
    guard let data = defaults?.array(forKey: "prayers") as? [[String: Any]] else { return nil }
    return data.compactMap { dict in
        guard let name = dict["name"] as? String,
              let timestamp = dict["time"] as? Double else { return nil }
        print("📖 Loading from app group: \(appGroupID)")
        print("📖 Raw data: \(String(describing: defaults?.array(forKey: "prayers")))")
        return PrayerTime(name: name, time: Date(timeIntervalSince1970: timestamp))
    }
}
func samplePrayers() -> [PrayerTime] {
    func t(_ h: Int, _ m: Int) -> Date {
        Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: Date()) ?? Date()
    }
    return [
        PrayerTime(name: "Fajr",    time: t(5,  12)),
        PrayerTime(name: "Dhuhr",   time: t(12, 45)),
        PrayerTime(name: "Asr",     time: t(15, 58)),
        PrayerTime(name: "Maghrib", time: t(18, 32)),
        PrayerTime(name: "Isha",    time: t(20, 1))
    ]
}
