//
//  StaffGridView.swift
//  iMOPS_OS_CORE
//
//  Created by Andreas Pelczer on 29.01.26.
//


//
//  StaffGridView.swift
//  iMOPS_OS_CORE
//
//  FEATURE 5: STAFF-GRID (Zero-Waste-Masterstroke)
//  - Kreislauf-System für Überproduktion
//  - Verwandelt Abfall in Wertschätzung für die Brigade
//  - Roman-Anker: "Respekt vor dem Tier, Respekt vor der Arbeit"
//

import SwiftUI

struct StaffGridView: View {
    @State private var brain = TheBrain.shared
    @State private var showingMasterstrokeAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            // --- HEADER ---
            HStack {
                VStack(alignment: .leading) {
                    Text("STAFF-GRID: BRIGADE-EHRE")
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                    Text("ZERO-WASTE-MASTERSTROKE ACTIVE")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.orange)
                }
                Spacer()
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color.white.opacity(0.05))

            // --- OPERATIVE ZONE ---
            ScrollView {
                VStack(spacing: 25) {
                    
                    // 1. ÜBERPRODUKTION-ERFASSUNG
                    VStack(alignment: .leading, spacing: 15) {
                        Text("AKTUELLE ÜBERPRODUKTION")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        // Demo-Item: Das Boeuf Bourguignon aus dem Buch
                        MasterstrokeCard(
                            title: "Boeuf Bourguignon",
                            portions: 200,
                            origin: "VIP-BUFFET",
                            onAction: { activateMasterstroke() }
                        )
                    }
                    .padding()
                    
                    // 2. KANTINE-STATUS
                    VStack(alignment: .leading, spacing: 15) {
                        Text("STATUS: KOLLEGEN-KANTINE")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        if let kantineSpecial: String = iMOPS.GET(.sys("KANTINE_SPECIAL")) {
                            HStack {
                                Image(systemName: "fork.knife")
                                Text("HEUTE: \(kantineSpecial)")
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                Spacer()
                                Text("FREIGESCHALTET")
                                    .font(.system(size: 10))
                                    .padding(4)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        } else {
                            Text("KEIN SPECIAL AKTIV")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.gray.opacity(0.5))
                        }
                    }
                    .padding()
                }
            }

            Spacer()
            
            // --- FOOTER-LEITSATZ ---
            Text("„Wertschätzung gilt auch dem Produkt.“")
                .font(.system(size: 12, design: .serif)).italic()
                .foregroundColor(.gray)
                .padding(.bottom, 10)

            Button("ZURÜCK") { iMOPS.GOTO("HOME") }
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.red)
                .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .alert("MASTERSTROKE GEZÜNDET", isPresented: $showingMasterstrokeAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("200 Portionen wurden HACCP-geprüft und für die Kantine freigeschaltet. Die Brigade dankt.")
        }
    }
    
    // MARK: - LOGIK: DIE VERWANDLUNG
    private func activateMasterstroke() {
        // Technischer Ablauf aus Kapitel 'Das System erklärt'
        iMOPS.SET(.sys("KANTINE_SPECIAL"), "Boeuf Bourguignon (VIP-Qualität)")
        
        // Archivierung des Masterstrokes (HACCP & Moral-Check)
        // DSGVO: Rolle statt Name, Stundenfenster statt Millisekunden
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        let hour = formatter.string(from: Date())
        let archiveID = "MS_\(hour)\(Int(Date().timeIntervalSince1970) % 10000)"
        iMOPS.SET(.archive(archiveID, "TITLE"), "ZERO-WASTE: Boeuf Bourguignon")
        iMOPS.SET(.archive(archiveID, "TIME"), "\(hour):00-\(hour):59")
        let userKey: String = iMOPS.GET(.nav("ACTIVE_USER")) ?? "SYSTEM"
        let role: String = TheBrain.shared.get("^BRIGADE.\(userKey).ROLE") ?? "Brigade"
        iMOPS.SET(.archive(archiveID, "ROLE"), role)
        
        showingMasterstrokeAlert = true
        
        // Moral-Boost im Kernel (Simuliert durch Reduktion des Jitters)
        print("iMOPS-KERNEL: Masterstroke registriert. Entropie erfolgreich umgewandelt.")
    }
}

// MARK: - SUBVIEW: DIE MASTERSTROKE-KARTE
struct MasterstrokeCard: View {
    let title: String
    let portions: Int
    let origin: String
    var onAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 20, weight: .black, design: .monospaced))
                Spacer()
                Text("\(portions) Port.")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
            }
            
            Text("HERKUNFT: \(origin)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.gray)
            
            Button(action: onAction) {
                Text("FÜR BRIGADE FREIGEBEN")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.black)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(8)
    }
}