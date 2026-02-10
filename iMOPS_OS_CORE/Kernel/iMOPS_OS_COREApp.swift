import SwiftUI

@main
struct iMOPS_OS_COREApp: App {
    // Kernel Bootloader
    let brain = TheBrain.shared

    init() {
        // Kernel wartet auf Branchen-Auswahl — seed() wird von BranchSelectView aufgerufen
        iMOPS.GOTO("BRANCH_SELECT")
    }

    var body: some Scene {
        WindowGroup {
            RootTerminalView()
        }
    }
}

