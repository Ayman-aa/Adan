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
        let prayers = loadPrayersFromSharedStorage() ?? samplePrayers()
        completion(PrayerEntry(date: Date(), prayers: prayers))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let prayers = loadPrayersFromSharedStorage() ?? samplePrayers()
        let entry = PrayerEntry(date: Date(), prayers: prayers)
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }
}

struct AdanWidgetEntryView: View {
    var entry: PrayerEntry
    @Environment(\.colorScheme) var colorScheme

    var nextPrayer: PrayerTime? {
        entry.prayers.first { $0.time > Date() }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Adan")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.adanGold.opacity(0.7))

            Spacer()

            if let next = nextPrayer {
                Text(next.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.adanGold)

                Text(next.time.formatted(date: .omitted, time: .shortened))
                    .font(.body.monospacedDigit())
                    .foregroundStyle(colorScheme == .dark ? Color.adanCream : Color.adanNavy)

                Text(next.time, style: .timer)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(colorScheme == .dark ? Color.adanCream.opacity(0.6) : Color.adanNavy.opacity(0.6))
            } else {
                Text("No more\nprayers today")
                    .font(.caption)
                    .foregroundStyle(colorScheme == .dark ? Color.adanCream.opacity(0.6) : Color.adanNavy.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
    }
}

struct AdanWidgetBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        colorScheme == .dark ? Color.adanNavy : Color.adanCardLight
    }
}

struct AdanWidget: Widget {
    let kind: String = "AdanWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AdanWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    AdanWidgetBackground()
                }
        }
        .configurationDisplayName("Adan")
        .description("Next prayer time at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    AdanWidget()
} timeline: {
    PrayerEntry(date: Date(), prayers: samplePrayers())
}
