//
//  RootTerminalView.swift
//  iMOPS_OS_CORE
//
//  Router / Terminal:
//  - liest ^NAV.LOCATION
//  - rendert passende "Station"
//
//  Safety-Update:
//  - Typed Paths via iMOPS.GET(.nav("LOCATION"))
//

import SwiftUI
import UIKit

// CommanderView nutzt UIActivityViewController

struct RootTerminalView: View {
    @State private var brain = TheBrain.shared
    @State private var guardReport: GuardReport?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Standort aus dem Kernel
            let location: String = iMOPS.GET(.nav("LOCATION")) ?? "HOME"

            switch location {
            case "HOME":
                HomeMenuView(guardReport: guardReport)

            case "BRIGADE_SELECT":
                EmployeeTerminalView()

            case "PRODUCTION":
                let userID: String = iMOPS.GET(.nav("ACTIVE_USER")) ?? ""
                ProductionTaskView(userID: userID)

            case "COMMANDER":
                CommanderView()

            case "STAFF_GRID":
                StaffGridView()

            default:
                VStack(spacing: 12) {
                    Text("KERNEL ERROR")
                        .foregroundColor(.red)
                        .font(.system(.headline, design: .monospaced))

                    Text("Standort: \(location)")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Button("RESET") { iMOPS.GOTO("HOME") }
                        .padding()
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        // Animation bewusst aus (Terminal-Style: hartes Umschalten)
        .animation(.none, value: iMOPS.GET(.nav("LOCATION")) as String? ?? "HOME")
        .onAppear {
            refreshGuardReport()
        }
        .onChange(of: brain.meierScore) { _, _ in
            refreshGuardReport()
        }
    }
    
    // MARK: - Guard Report Refresh
    
    private func refreshGuardReport() {
        // Schicht-Start aus Kernel lesen
        let shiftStart: Date = iMOPS.GET(.sys("SHIFT_START")) ?? Date()
        
        // Alle Tasks aus dem Kernel holen
        let allTasks = brain.getArbeitsschritte()
        
        // SecurityLevel aus Kernel lesen (Default: .standard)
        let securityLevelRaw: String = iMOPS.GET(.sys("SECURITY_LEVEL")) ?? "standard"
        let securityLevel = SecurityLevel(rawValue: securityLevelRaw) ?? .standard
        
        // Admin Request Count aus Kernel lesen (Default: 0)
        let adminRequestCount: Int = iMOPS.GET(.sys("ADMIN_REQUEST_COUNT")) ?? 0
        
        // Guards auswerten
        guardReport = KernelGuards.evaluate(
            schritte: allTasks,
            securityLevel: securityLevel,
            sessionStart: shiftStart,
            adminRequestCount: adminRequestCount
        )
    }
}

// MARK: - HILFS-VIEWS

struct EmployeeRow: View {
    let id: String

    var body: some View {
        Button(action: {
            iMOPS.SET(.nav("ACTIVE_USER"), id)
            iMOPS.GOTO("PRODUCTION")
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(iMOPS.GET(.brigade(id, "NAME")) ?? id)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))

                    Text(iMOPS.GET(.brigade(id, "ROLE")) ?? "STAFF")
                        .font(.caption)
                        .foregroundColor(.orange)
                }

                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(.white)
        }
    }
}

struct EmployeeTerminalView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("BRIGADE LOG-IN")
                .font(.headline)
                .foregroundColor(.orange)

            EmployeeRow(id: "HARRY")
            EmployeeRow(id: "LUKAS")

            Button("ZURÜCK") { iMOPS.GOTO("HOME") }
                .padding()
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}



