import SwiftUI


struct ContentView: View {

    @State private var prayers: [PrayerTime] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
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
                ProgressView()
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
        .task {
            // try network first, fall back to hardcoded
            do {
                prayers = try await fetchPrayerTimes(latitude: 33.5731, longitude: -7.5898)
                isLoading = false
            } catch {
                // network failed — use hardcoded and save to shared storage
                let fallback = samplePrayers()
                savePrayersToSharedStorage(fallback)
                prayers = fallback
                isLoading = false
            }
        }
    }
}

#Preview {
    ContentView()
}
