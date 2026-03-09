import Foundation

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
        formatter.date(from: string) ?? Date()
    }

    return [
        PrayerTime(name: "Fajr",    time: parse(timings.Fajr)),
        PrayerTime(name: "Dhuhr",   time: parse(timings.Dhuhr)),
        PrayerTime(name: "Asr",     time: parse(timings.Asr)),
        PrayerTime(name: "Maghrib", time: parse(timings.Maghrib)),
        PrayerTime(name: "Isha",    time: parse(timings.Isha))
    ]
}
