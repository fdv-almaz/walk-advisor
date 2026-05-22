import SwiftUI
import CoreLocation

@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 380, minHeight: 600, maxHeight: .infinity)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                    if let window = NSApplication.shared.windows.first {
                        window.setFrame(NSRect(x: 100, y: 100, width: 400, height: 700), display: true)
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
    }
}
