import SwiftUI

struct AboutView: View {
    @Binding var isPresented: Bool
    let appVersion: String
    let appBuild: String

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("About Walk Advisor")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.135, green: 0.506, blue: 0.969),
                        Color(red: 0.198, green: 0.631, blue: 0.973)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // App Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Application")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)

                        InfoRow(label: "Name", value: "Walk Advisor")
                        InfoRow(label: "Version", value: "v\(appVersion)")
                        InfoRow(label: "Build", value: appBuild)
                        InfoRow(label: "Platform", value: "macOS 12.0+")
                    }

                    Divider()

                    // Developer Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Developer")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Dmitry Frantsevich")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)

                            Link("dzmitry.frantskevich@gmail.com",
                                 destination: URL(string: "mailto:dzmitry.frantskevich@gmail.com")!)
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                    }

                    Divider()

                    // API Servers
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Data Sources")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Weather Data")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.primary)
                                Link("api.open-meteo.com",
                                     destination: URL(string: "https://api.open-meteo.com")!)
                                    .font(.system(size: 11))
                                    .foregroundColor(.blue)
                                Text("Free weather API with no authentication required")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }

                            Divider()
                                .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("IP Geolocation")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.primary)
                                Link("ipapi.co",
                                     destination: URL(string: "https://ipapi.co")!)
                                    .font(.system(size: 11))
                                    .foregroundColor(.blue)
                                Text("Determines your location based on IP address")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                    }

                    Divider()

                    // Features
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Features")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 6) {
                            FeatureRow(icon: "location.fill", text: "GPS and IP Geolocation")
                            FeatureRow(icon: "cloud.sun.fill", text: "5-Day Weather Forecast")
                            FeatureRow(icon: "percent", text: "Activity Score (0-100%)")
                            FeatureRow(icon: "globe", text: "4 Language Support")
                            FeatureRow(icon: "lock.fill", text: "Privacy-First Design")
                        }
                    }

                    Divider()

                    // License
                    VStack(alignment: .leading, spacing: 12) {
                        Text("License")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("MIT License")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary)
                            Text("Open source and free to use, modify, and distribute")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }

                    // Footer
                    VStack(alignment: .center, spacing: 8) {
                        Text("Thank you for using Walk Advisor! 🙏")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Text("Made with ❤️ for macOS")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                }
                .padding(16)
            }
        }
        .frame(width: 380, height: 600)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)

            Spacer()

            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(4)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.blue)
                .frame(width: 20)

            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.primary)

            Spacer()
        }
    }
}
