import SwiftUI
import CoreLocation

// MARK: - Design System
extension Color {
    static let adanNavy      = Color(red: 0.06, green: 0.13, blue: 0.27)
    static let adanBlue      = Color(red: 0.16, green: 0.32, blue: 0.60)
    static let adanGold      = Color(red: 0.79, green: 0.66, blue: 0.30)
    static let adanCream     = Color(red: 0.94, green: 0.90, blue: 0.78)
    static let adanCardLight = Color(red: 0.97, green: 0.95, blue: 0.90)
    static let adanCardDark  = Color(red: 0.10, green: 0.18, blue: 0.32)
}

// MARK: - Prayer Row
struct PrayerRow: View {
    let prayer: PrayerTime
    let isNext: Bool

    @Environment(\.colorScheme) var colorScheme

    var cardBackground: Color {
        isNext
            ? .adanGold.opacity(colorScheme == .dark ? 0.18 : 0.22)
            : (colorScheme == .dark ? .adanCardDark : .adanCardLight)
    }

    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: 8) {
                if isNext {
                    Circle()
                        .fill(Color.adanGold)
                        .frame(width: 7, height: 7)
                }
                Text(prayer.name)
                    .font(isNext ? .body.weight(.bold) : .body.weight(.regular))
                    .foregroundStyle(isNext ? Color.adanGold : .primary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(prayer.time.formatted(date: .omitted, time: .shortened))
                    .font(.body.monospacedDigit())
                    .fontWeight(isNext ? .semibold : .regular)
                    .foregroundStyle(isNext ? Color.adanGold : .secondary)

                if isNext {
                    Text(timeUntil(prayer.time))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(Color.adanGold.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, isNext ? 16 : 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(cardBackground)
                .shadow(
                    color: isNext
                        ? Color.adanGold.opacity(0.15)
                        : Color.black.opacity(colorScheme == .dark ? 0.3 : 0.06),
                    radius: isNext ? 12 : 4,
                    x: 0,
                    y: isNext ? 4 : 2
                )
        )
    }
}

// MARK: - Content View
struct ContentView: View {

    @State private var prayers: [PrayerTime] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var locationManager = LocationManager()

    @Environment(\.colorScheme) var colorScheme

    var nextPrayer: PrayerTime? {
        prayers.first { $0.time > Date() }
    }

    var background: some View {
        Group {
            if colorScheme == .dark {
                Color.adanNavy.ignoresSafeArea()
            } else {
                Color.adanCream.opacity(0.4).ignoresSafeArea()
            }
        }
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {

                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Adan")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(colorScheme == .dark ? Color.adanCream : Color.adanNavy)
                        Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide)))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "moon.stars.fill")
                        .font(.title2)
                        .foregroundStyle(Color.adanGold)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 28)

                // Body
                if isLoading {
                    Spacer()
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(Color.adanGold)
                        Text("Finding your location...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()

                } else if let error = errorMessage {
                    Spacer()
                    Text(error)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()

                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(prayers, id: \.name) { prayer in
                                PrayerRow(
                                    prayer: prayer,
                                    isNext: prayer.name == nextPrayer?.name
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.location) { _, newLocation in
            guard let coord = newLocation else { return }
            Task {
                do {
                    prayers = try await fetchPrayerTimes(
                        latitude: coord.latitude,
                        longitude: coord.longitude
                    )
                    isLoading = false
                } catch {
                    let fallback = samplePrayers()
                    savePrayersToSharedStorage(fallback)
                    prayers = fallback
                    isLoading = false
                }
            }
        }
        .onChange(of: locationManager.status) { _, status in
            if status == .denied || status == .restricted {
                errorMessage = "Location access denied.\nPlease enable it in Settings."
                isLoading = false
            }
        }
    }
}

#Preview {
    ContentView()
}
