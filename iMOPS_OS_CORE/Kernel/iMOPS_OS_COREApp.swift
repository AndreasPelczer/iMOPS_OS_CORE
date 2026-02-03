import SwiftUI

@main
struct iMOPS_OS_COREApp: App {
    // Kernel Bootloader
    let brain = TheBrain.shared

    init() {
        // Kernel-Zündung: Seed (Demo-Daten)
        brain.seed()
    }

    var body: some Scene {
        WindowGroup {
            RootTerminalView()
        }
    }
}

