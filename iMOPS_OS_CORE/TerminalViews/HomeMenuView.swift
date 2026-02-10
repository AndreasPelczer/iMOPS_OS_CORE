import SwiftUI

struct HomeMenuView: View {
    // Wir beobachten den Kernel direkt
    @State private var brain = TheBrain.shared

    // Animation-State für den Stress-Modus
    @State private var pulseOpacity: Double = 1.0

    // Guard-Report (Gen 3 Schutz-Stack)
    @State private var guardReport: GuardReport?

    var body: some View {
        VStack(spacing: 50) {
            
            // --- DER BRANDING-KNOTEN ---
            VStack(spacing: 10) {
                Text("iMOPS OS")
                    .font(.system(size: 40, weight: .black, design: .monospaced))
                    .tracking(8)
                    // Farbe schlägt bei Stress auf Rot um
                    .foregroundColor(brain.meierScore > 60 ? .red : .white)
                    // Pulsieren nur bei kritischem Score
                    .opacity(brain.meierScore > 60 ? pulseOpacity : 1.0)
                
                Text(brain.meierScore > 60 ? "!! CRITICAL LOAD !!" : "KERNEL_26 // OMNI_GRID")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .tracking(2)
                    .foregroundColor(brain.meierScore > 60 ? .red : .orange)
            }
            .padding(.top, 60)
            .onAppear {
                // Dauer-Animation im Hintergrund, wirkt sich nur bei Stress aus
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    pulseOpacity = 0.3
                }
            }
            
            // --- DAS REBELLEN-COCKPIT ---
            VStack(spacing: 25) {
                
                // BRIGADE-ZUGANG
                Button(action: {
                    iMOPS.GOTO("BRIGADE_SELECT")
                }) {
                    RebelButton(title: "BRIGADE", icon: "person.2.fill", color: .orange)
                }
                
                // COMMANDER-ZENTRALE
                Button(action: {
                    iMOPS.GOTO("COMMANDER")
                }) {
                    RebelButton(title: "COMMANDER", icon: "terminal.fill", color: .blue)
                }

                // STAFF-GRID (Zero-Waste-Masterstroke)
                Button(action: {
                    iMOPS.GOTO("STAFF_GRID")
                }) {
                    RebelButton(title: "STAFF-GRID", icon: "leaf.fill", color: .green)
                }
                
                // STRESS-SIMULATOR (Versteckter Knopf für den Commander)
                Button(action: {
                    brain.simulateRushHour()
                }) {
                    HStack {
                        Image(systemName: "flame.fill")
                        Text("SIMULATE RUSH HOUR")
                    }
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray.opacity(0.5))
                }
                .padding(.top, 5)

                // OMNI-GRID STATUS
                HStack(spacing: 12) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .symbolEffect(.variableColor.iterative, isActive: true)
                    
                    // Live-Anzeige der Matrix
                    Text("MATRIX-SCORE: \(brain.meierScore)")
                        .fontWeight(.bold)
                    
                    Text("//")
                    
                    Text("GRID: \(iMOPS.GET(.sys("STATUS")) as String? ?? "OFFLINE")")
                }
                .font(.system(size: 12, design: .monospaced))
                // Ampel-Logik für den Footer-Status
                .foregroundColor(brain.meierScore > 60 ? .red : (brain.meierScore > 30 ? .orange : .green))
                .padding(.top, 10)
            }
            .padding(.horizontal, 30)
            
            Spacer()

            // --- GUARD STATUS (Gen 3 Schutz-Stack) ---
            if let report = guardReport {
                VStack(spacing: 4) {
                    // Zeile 1: Security + Fatigue + Shield
                    HStack(spacing: 8) {
                        // SecurityLevel
                        Image(systemName: report.securityLevel.sfSymbol)
                            .foregroundColor(report.securityLevel.isShieldActive ? .yellow : .green)
                        Text(report.securityLevel.displayName.uppercased())
                            .foregroundColor(report.securityLevel.isShieldActive ? .yellow : .green)

                        Text("//")
                            .foregroundColor(.white.opacity(0.3))

                        // FatigueLevel
                        Image(systemName: report.fatigueLevel.sfSymbol)
                            .foregroundColor(report.fatigueLevel == .fresh ? .green
                                : report.fatigueLevel == .warning ? .orange : .red)
                        Text(report.fatigueLevel.rawValue.uppercased())
                            .foregroundColor(report.fatigueLevel == .fresh ? .green
                                : report.fatigueLevel == .warning ? .orange : .red)

                        // Privacy Shield Indikator
                        if report.privacyShieldActive {
                            Text("//")
                                .foregroundColor(.white.opacity(0.3))
                            Image(systemName: "shield.lefthalf.filled")
                                .foregroundColor(.yellow)
                            Text("SHIELD")
                                .foregroundColor(.yellow)
                        }
                    }
                    .font(.system(size: 9, weight: .bold, design: .monospaced))

                    // Training Mode Warnung
                    if report.forceTrainingMode {
                        HStack(spacing: 4) {
                            Image(systemName: "graduationcap.fill")
                            Text("PRAEZISIONSMODUS ERZWUNGEN")
                        }
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.red)
                    }

                    // Whisper Message (dezent, kein Alert)
                    if let whisper = report.whisperMessage {
                        Text(whisper)
                            .font(.system(size: 9, design: .serif))
                            .italic()
                            .foregroundColor(.orange.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.top, 2)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color.white.opacity(0.03))
            }

            // --- FUSSZEILE ---
            Text("NO SQL // NO LATENCY // NO POWER FOR NOBODY")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { evaluateGuards() }
        // Hintergrund färbt sich bei extremem Stress leicht rötlich ein
        .background(
            ZStack {
                Color.black
                if brain.meierScore > 60 {
                    Color.red.opacity(0.1).ignoresSafeArea()
                }
            }
        )
    }

    // MARK: - Guard Evaluation

    private func evaluateGuards() {
        let shiftStart: Date = brain.get("^SYS.SHIFT_START") ?? Date()
        let report = KernelGuards.evaluate(
            schritte: brain.getArbeitsschritte(),
            securityLevel: .standard,
            sessionStart: shiftStart,
            adminRequestCount: brain.adminRequestCount
        )
        guardReport = report
    }
}

// RebelButton bleibt im Stil erhalten
struct RebelButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
            Spacer()
            Image(systemName: "chevron.right.square")
        }
        .padding(25)
        .foregroundColor(.white)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.5), lineWidth: 2)
                .background(color.opacity(0.1))
        )
    }
}
