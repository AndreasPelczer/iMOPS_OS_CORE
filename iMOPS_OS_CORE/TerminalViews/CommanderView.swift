//
//  CommanderView.swift
//  iMOPS_OS_CORE
//
//  HACCP-TRESOR (Dispatcher Edition)
//  - Liest versiegelte Daten aus dem ^ARCHIVE Namespace
//  - Bietet Export-Funktion für die Revisionssicherheit
//  - Export-Formate: Tagesbericht (Text), Audit CSV, Journal JSON
//  - SHA-256 Versiegelung fuer jeden Export
//  - DSGVO: Guards werden VOR Export angewendet
//

import SwiftUI
import CryptoKit

struct CommanderView: View {
    @State private var brain = TheBrain.shared
    @State private var showShareSheet = false
    @State private var exportText = ""
    @State private var showExportView = false
    @State private var showSelfCheck = false

    // Killswitch-Sicherung (Roman-Anker: Joshua)
    @State private var killswitchEngaged = false

    var body: some View {
        VStack(spacing: 0) {
            // --- HEADER: THERMODYNAMISCHES DASHBOARD ---
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("COMMANDER: HACCP-TRESOR")
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                    Text("IMMUTABLE RECORDS // KERNEL_26")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.blue)
                }
                Spacer()

                // Status-Indikator basierend auf der Pelczer-Matrix
                let isCritical = brain.meierScore > 80
                Circle()
                    .fill(isCritical ? Color.red : Color.green)
                    .frame(width: 8, height: 8)
                Text(isCritical ? "CRITICAL" : "SECURE")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(isCritical ? .red : .green)
            }
            .padding()
            .background(Color.blue.opacity(0.15))

            // --- TRESOR-LISTE: DIE UNBESTECHLICHE WAHRHEIT ---
            ScrollView {
                VStack(spacing: 2) {
                    let _ = brain.meierScore
                    let ids = brain.getArchiveIDs()

                    if ids.isEmpty {
                        VStack(spacing: 10) {
                            Text("TRESOR LEER")
                                .font(.system(size: 12, design: .monospaced))
                            Text("\u{201E}Noch l\u{00FC}gt die Suppe nicht.\u{201C}")
                                .font(.system(size: 10, design: .serif)).italic()
                        }
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                    }

                    ForEach(ids, id: \.self) { id in
                        ArchiveRow(id: id)
                    }
                }
            }

            // --- COMMANDS ---
            VStack(spacing: 0) {
                if !killswitchEngaged {
                    HStack(spacing: 0) {
                        Button(action: { showExportView = true }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("EXPORT")
                            }
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                        }

                        Button(action: { showSelfCheck = true }) {
                            HStack {
                                Image(systemName: "checkmark.shield")
                                Text("SELF-CHECK")
                            }
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.cyan.opacity(0.2))
                            .foregroundColor(.cyan)
                        }
                    }
                }

                HStack(spacing: 0) {
                    Button("ZUR\u{00DC}CK") { iMOPS.GOTO("HOME") }
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.05))

                    Button(killswitchEngaged ? "LOCKED" : "KILLSWITCH") {
                        withAnimation { killswitchEngaged.toggle() }
                    }
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(killswitchEngaged ? Color.red : Color.red.opacity(0.1))
                    .foregroundColor(.white)
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .sheet(isPresented: $showExportView) {
            ExportView()
        }
        .sheet(isPresented: $showSelfCheck) {
            SelfCheckView()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [exportText])
        }
    }
}

// MARK: - Export View (Tagesbericht, CSV, JSON)

struct ExportView: View {
    @State private var brain = TheBrain.shared
    @State private var showShareSheet = false
    @State private var exportContent = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // --- System ---
                Section("System") {
                    HStack {
                        Text("iMOPS Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                }

                // --- Exportzeitraum ---
                Section("Exportzeitraum") {
                    HStack {
                        Text("Datum")
                        Spacer()
                        Text(datumString)
                            .foregroundColor(.secondary)
                    }
                }

                // --- Export erstellen ---
                Section("Export erstellen") {
                    // Tagesbericht (Text)
                    Button(action: { exportAlsText() }) {
                        Label("Tagesbericht (Text)", systemImage: "doc.text")
                    }

                    // Audit CSV
                    Button(action: { exportAlsCSV() }) {
                        Label("Audit CSV", systemImage: "tablecells")
                    }

                    // Journal JSON
                    Button(action: { exportAlsJSON() }) {
                        Label("Journal JSON", systemImage: "curlybraces")
                    }
                }

                // --- SHA-256 Hinweis ---
                Section {
                    Text("Jeder Export wird mit SHA-256 versiegelt und im Audit-Log protokolliert.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // --- PDF Footer Vorschau ---
                Section("PDF Footer Vorschau") {
                    Text("Generated by iMOPS v1.0")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Export")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schliessen") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [exportContent])
        }
    }

    // MARK: - Export-Aktionen

    private func exportAlsText() {
        let text = brain.exportLog()
        let hash = sha256(text)
        exportContent = text + "\n\nSHA-256: \(hash)"
        print("iMOPS-EXPORT: Tagesbericht exportiert. SHA-256: \(hash)")
        showShareSheet = true
    }

    private func exportAlsCSV() {
        let csv = brain.exportCSV()
        let hash = sha256(csv)
        exportContent = csv + "\n# SHA-256: \(hash)"
        print("iMOPS-EXPORT: Audit CSV exportiert. SHA-256: \(hash)")
        showShareSheet = true
    }

    private func exportAlsJSON() {
        let json = brain.exportJSON()
        let hash = sha256(json)
        // SHA-256 als Kommentar am Ende (valides JSON bleibt oben)
        exportContent = json + "\n// SHA-256: \(hash)"
        print("iMOPS-EXPORT: Journal JSON exportiert. SHA-256: \(hash)")
        showShareSheet = true
    }

    // MARK: - SHA-256 Versiegelung

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Hilfs-Properties

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private var datumString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: Date())
    }
}

// MARK: - ArchiveRow

struct ArchiveRow: View {
    let id: String
    @State private var brain = TheBrain.shared

    var body: some View {
        let archiveTitle = iMOPS.GET(.archive(id, "TITLE")) as String? ?? "DATA_LOCK_ERROR"
        let archiveTime   = iMOPS.GET(.archive(id, "TIME")) as String? ?? "--:--"
        let medical       = iMOPS.GET(.archive(id, "MEDICAL_SNAPSHOT")) as String?
        let role          = iMOPS.GET(.archive(id, "ROLE")) as String? ?? "Brigade"

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("#\(id)")
                    .foregroundColor(.green)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))

                Text(archiveTitle)
                    .bold()
                    .foregroundColor(.white)

                Spacer()

                Text(archiveTime)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray)
            }

            HStack(spacing: 20) {
                Label(role, systemImage: "checkmark.seal.fill")

                if let medicalData = medical {
                    Label(medicalData, systemImage: "pills.fill")
                        .foregroundColor(.orange.opacity(0.7))
                }
            }
            .font(.system(size: 9, design: .monospaced))
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.04))
        .id("row-\(id)-\(brain.meierScore)")
    }
}

// MARK: - Self-Check View (Kernel-Integritaetspruefung)

struct SelfCheckView: View {
    @State private var results: [TheBrain.CheckResult] = []
    @State private var hasRun = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if !hasRun {
                    Section {
                        Button(action: { runCheck() }) {
                            Label("Kernel-Selbsttest starten", systemImage: "play.fill")
                                .font(.headline)
                        }
                    }
                } else {
                    // Zusammenfassung
                    let passed = results.filter { $0.passed }.count
                    let total = results.count
                    Section("Ergebnis") {
                        HStack {
                            Image(systemName: passed == total
                                  ? "checkmark.seal.fill" : "xmark.seal.fill")
                                .foregroundColor(passed == total ? .green : .red)
                                .font(.title)
                            VStack(alignment: .leading) {
                                Text("\(passed)/\(total) bestanden")
                                    .font(.headline)
                                Text(passed == total
                                     ? "Kernel-Integritaet verifiziert"
                                     : "WARNUNG: Integritaet kompromittiert")
                                    .font(.caption)
                                    .foregroundColor(passed == total ? .green : .red)
                            }
                        }
                    }

                    // Einzelergebnisse
                    Section("Pruefschritte") {
                        ForEach(results) { result in
                            HStack {
                                Image(systemName: result.passed
                                      ? "checkmark.circle.fill"
                                      : "xmark.circle.fill")
                                    .foregroundColor(result.passed ? .green : .red)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(result.name)
                                        .font(.system(.body, design: .monospaced))
                                    Text(result.detail)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }

                    // Nochmal starten
                    Section {
                        Button(action: { runCheck() }) {
                            Label("Erneut pruefen", systemImage: "arrow.clockwise")
                        }
                    }
                }
            }
            .navigationTitle("Kernel Self-Check")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schliessen") { dismiss() }
                }
            }
        }
    }

    private func runCheck() {
        results = TheBrain.shared.kernelSelfCheck()
        hasRun = true
    }
}

// MARK: - ShareSheet (UIKit-Bridge)

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
