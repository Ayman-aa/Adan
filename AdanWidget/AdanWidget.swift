import WidgetKit
import SwiftUI

struct PrayerEntry: TimelineEntry {
    let date: Date
    let prayers: [PrayerTime]
}

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(date: Date(), prayers: samplePrayers())
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        completion(PrayerEntry(date: Date(), prayers: samplePrayers()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        Task {
            let prayers = (try? await fetchPrayerTimes(latitude: 33.5731, longitude: -7.5898)) ?? samplePrayers()
            let entry = PrayerEntry(date: Date(), prayers: prayers)

            // refresh once a day at midnight
            let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
            let timeline = Timeline(entries: [entry], policy: .after(midnight))
            completion(timeline)
        }
    }
}

func samplePrayers() -> [PrayerTime] {
    func t(_ h: Int, _ m: Int) -> Date {
        Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: Date()) ?? Date()
    }
    return [
        PrayerTime(name: "Fajr",    time: t(23, 0)),
        PrayerTime(name: "Dhuhr",   time: t(23, 15)),
        PrayerTime(name: "Asr",     time: t(23, 30)),
        PrayerTime(name: "Maghrib", time: t(23, 45)),
        PrayerTime(name: "Isha",    time: t(23, 59))
    ]
}

struct AdanWidgetEntryView: View {
    var entry: PrayerEntry

    var nextPrayer: PrayerTime? {
        entry.prayers.first { $0.time > Date() }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Adan")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let next = nextPrayer {
                Text(next.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(next.time.formatted(date: .omitted, time: .shortened))
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("next prayer")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            } else {
                Text("No more prayers today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
    }
}

struct AdanWidget: Widget {
    let kind: String = "AdanWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AdanWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Adan")
        .description("Next prayer time at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    AdanWidget()
} timeline: {
    PrayerEntry(date: Date(), prayers: samplePrayers())
}
