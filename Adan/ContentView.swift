import SwiftUI

struct PrayerTime {
    let name: String
    let time: String
}

struct ContentView: View {

    let prayers: [PrayerTime] = [
        PrayerTime(name: "Fajr",    time: "05:12"),
        PrayerTime(name: "Dhuhr",   time: "12:45"),
        PrayerTime(name: "Asr",     time: "15:58"),
        PrayerTime(name: "Maghrib", time: "18:32"),
        PrayerTime(name: "Isha",    time: "20:04")
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Prayer Times")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top)

            ForEach(prayers, id: \.name) { prayer in
                HStack {
                    Text(prayer.name)
                    Spacer()
                    Text(prayer.time)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }

            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
