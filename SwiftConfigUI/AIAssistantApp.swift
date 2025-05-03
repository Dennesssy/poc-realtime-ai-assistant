import SwiftUI

@main
struct AIAssistantApp: App {
    @StateObject private var configStore = ConfigurationStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(configStore)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About AI Assistant Config") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.applicationName: "AI Assistant Config",
                            NSApplication.AboutPanelOptionKey.applicationVersion: "1.0.0",
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: "A SwiftUI configuration tool for the real-time AI assistant."
                            )
                        ]
                    )
                }
            }
            
            CommandGroup(after: .appSettings) {
                Button("Reset to Defaults") {
                    configStore.resetToDefaults()
                }
            }
        }
    }
}
