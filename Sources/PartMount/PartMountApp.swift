import SwiftUI

@main
struct PartMountApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
                .onOpenURL { url in
                    appState.imageURL = url
                }
                .onAppear {
                    handleCommandLineArgs()
                }
        }
        .defaultSize(width: 420, height: 440)
        .windowResizability(.contentSize)
    }

    private func handleCommandLineArgs() {
        let args = CommandLine.arguments.dropFirst()
        guard let path = args.first else { return }
        let url = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        appState.imageURL = url
    }
}

class AppState: ObservableObject {
    @Published var imageURL: URL?
    @Published var status: String = "Ready"
    @Published var busy = false
}
