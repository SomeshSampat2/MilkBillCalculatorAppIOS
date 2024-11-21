//
//  ContentView.swift
//  MilkBillCalculator
//
//  Created by Somesh Sampat on 21/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var milkStore = MilkStore()
    @State private var showingAddEntry = false
    @State private var selectedEntry: MilkEntry?
    @State private var entryToDelete: MilkEntry?
    @State private var showingDeleteAlert = false
    @Environment(\.colorScheme) var colorScheme
    
    private var totalSpentThisMonth: Double {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        return milkStore.entries
            .filter { entry in
                let entryMonth = calendar.component(.month, from: entry.date)
                let entryYear = calendar.component(.year, from: entry.date)
                return entryMonth == currentMonth && entryYear == currentYear
            }
            .reduce(0) { $0 + $1.totalPrice }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: colorScheme == .dark ?
                        [Color(hex: "1a1a1a"), Color(hex: "2d2d2d")] :
                        [Color(hex: "f0f2f5"), Color(hex: "ffffff")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Monthly Summary Card
                        VStack(spacing: 15) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("This Month's Expenses")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Text("₹\(totalSpentThisMonth, specifier: "%.2f")")
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                }
                                Spacer()
                                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.blue.gradient)
                            }
                            
                            Divider()
                            
                            HStack {
                                Button {
                                    showingAddEntry = true
                                } label: {
                                    Label("Add Entry", systemImage: "plus.circle.fill")
                                        .font(.headline)
                                }
                                .buttonStyle(.borderedProminent)
                                .buttonBorderShape(.capsule)
                                .tint(.blue)
                                
                                Spacer()
                                
                                Text(Date().formatted(.dateTime.month(.wide)))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .glassCard()
                        
                        // Recent Entries
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Recent Entries")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
                            LazyVStack(spacing: 15) {
                                ForEach(milkStore.entries.sorted(by: { $0.date > $1.date })) { entry in
                                    EntryCard(entry: entry) {
                                        selectedEntry = entry
                                    } onDelete: {
                                        entryToDelete = entry
                                        showingDeleteAlert = true
                                    }
                                }
                            }
                            
                            if milkStore.entries.isEmpty {
                                VStack(spacing: 15) {
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 50))
                                        .foregroundStyle(.blue.gradient)
                                    Text("No Entries Yet")
                                        .font(.title3)
                                        .bold()
                                    Text("Tap the Add Entry button to get started")
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, minHeight: 200)
                                .modernCard()
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Milk Bill Calculator")
            .sheet(isPresented: $showingAddEntry) {
                MilkEntryFormView(milkStore: milkStore)
            }
            .sheet(item: $selectedEntry) { entry in
                MilkEntryFormView(milkStore: milkStore, isEditing: true, editEntry: entry)
            }
            .alert("Delete Entry", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let entry = entryToDelete {
                        withAnimation {
                            milkStore.deleteEntry(entry)
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete this entry? This action cannot be undone.")
            }
        }
        .onAppear {
            NotificationManager.shared.requestAuthorization()
        }
    }
}

struct EntryCard: View {
    let entry: MilkEntry
    let onTap: () -> Void
    let onDelete: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 15) {
            // Milk Type Icon
            ZStack {
                Circle()
                    .fill(entry.type == .cow ? Color.blue.gradient : Color.purple.gradient)
                    .frame(width: 50, height: 50)
                Image(systemName: "drop.fill")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            // Entry Details
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(entry.type.rawValue)
                        .font(.headline)
                    Spacer()
                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("\(entry.liters, specifier: "%.1f") L")
                        .foregroundColor(.secondary)
                    Text("×")
                        .foregroundColor(.secondary)
                    Text("₹\(entry.pricePerLiter, specifier: "%.2f")")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("₹\(entry.totalPrice, specifier: "%.2f")")
                        .font(.headline)
                }
                
                HStack {
                    Image(systemName: entry.isDelivered ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(entry.isDelivered ? .green : .red)
                    Text(entry.isDelivered ? "Delivered" : "Not Delivered")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Delete Button
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.red.opacity(0.8))
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
        .onTapGesture {
            onTap()
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
