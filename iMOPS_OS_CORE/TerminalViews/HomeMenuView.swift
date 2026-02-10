import SwiftUI

struct HomeMenuView: View {
    // Wir beobachten den Kernel direkt
    @State private var brain = TheBrain.shared
    
    // Animation-State für den Stress-Modus
    @State private var pulseOpacity: Double = 1.0
    
    // Guard Report von RootTerminalView
    let guardReport: GuardReport?

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
            
            // --- GUARD STATUS ANZEIGE ---
            if let report = guardReport {
                GuardStatusView(report: report)
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
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
            
            // --- WHISPER MESSAGE (BourdainGuard) ---
            if let report = guardReport, let whisper = report.whisperMessage {
                WhisperMessageView(message: whisper)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
            }
            
            // --- FUSSZEILE ---
            Text("NO SQL // NO LATENCY // NO POWER FOR NOBODY")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
// MARK: - Guard Status View

struct GuardStatusView: View {
    let report: GuardReport
    
    var body: some View {
        VStack(spacing: 8) {
            // SecurityLevel Badge
            HStack(spacing: 12) {
                Image(systemName: report.securityLevel.sfSymbol)
                    .foregroundColor(report.securityLevel == .standard ? .green : .orange)
                
                Text(report.securityLevel.displayName.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(report.securityLevel == .standard ? .green : .orange)
                
                // Privacy Shield Indikator
                if report.privacyShieldActive {
                    Image(systemName: "eye.slash.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 10))
                }
                
                Spacer()
                
                // Fatigue Level
                Image(systemName: report.fatigueLevel.sfSymbol)
                    .foregroundColor(fatigueColor)
                
                // Training Mode Badge
                if report.forceTrainingMode {
                    Text("TRAINING")
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.purple)
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
        }
    }
    
    private var fatigueColor: Color {
        switch report.fatigueLevel {
        case .fresh:   return .green
        case .warning: return .orange
        case .reset:   return .red
        }
    }
}

// MARK: - Whisper Message View

struct WhisperMessageView: View {
    let message: String
    @State private var opacity: Double = 0.5
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "quote.bubble.fill")
                .font(.system(size: 12))
            
            Text(message)
                .font(.system(size: 11, design: .monospaced))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .foregroundColor(.orange.opacity(0.8))
        .padding(12)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }
        }
    }
}

