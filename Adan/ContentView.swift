import SwiftUI
import CoreLocation

struct ContentView: View {

    @State private var prayers: [PrayerTime] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var locationManager = LocationManager()

    var nextPrayer: PrayerTime? {
        prayers.first { $0.time > Date() }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Prayer Times")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top)

            if isLoading {
                Spacer()
                ProgressView("Getting your location...")
                Spacer()
            } else if let error = errorMessage {
                Spacer()
                Text(error)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                ForEach(prayers, id: \.name) { prayer in
                    HStack {
                        Text(prayer.name)
                            .fontWeight(prayer.name == nextPrayer?.name ? .bold : .regular)
                        Spacer()
                        Text(prayer.time.formatted(date: .omitted, time: .shortened))
                            .foregroundStyle(prayer.name == nextPrayer?.name ? .primary : .secondary)
                    }
                    .padding(.horizontal)
                }
                Spacer()
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
                errorMessage = "Location access denied. Please enable it in Settings."
                isLoading = false
            }
        }
    }
}

#Preview {
    ContentView()
}
