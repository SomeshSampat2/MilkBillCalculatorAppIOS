import SwiftUI

struct MilkEntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var milkStore: MilkStore
    @State private var date = Date()
    @State private var milkType = MilkType.cow
    @State private var liters = ""
    @State private var pricePerLiter = ""
    @State private var isDelivered = true
    @State private var showingDeleteAlert = false
    
    var isEditing: Bool = false
    var editEntry: MilkEntry?
    
    private var isFormValid: Bool {
        guard let litersDouble = Double(liters),
              let priceDouble = Double(pricePerLiter) else {
            return false
        }
        return litersDouble > 0 && priceDouble > 0
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "f0f2f5")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Date Picker Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Select Date")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // Milk Details Card
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Milk Details")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            // Milk Type Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Type")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                HStack(spacing: 15) {
                                    ForEach(MilkType.allCases, id: \.self) { type in
                                        Button {
                                            milkType = type
                                        } label: {
                                            VStack(spacing: 8) {
                                                ZStack {
                                                    Circle()
                                                        .fill(type == .cow ? Color.blue.gradient : Color.purple.gradient)
                                                        .frame(width: 50, height: 50)
                                                    Image(systemName: "drop.fill")
                                                        .font(.title3)
                                                        .foregroundColor(.white)
                                                }
                                                Text(type.rawValue)
                                                    .font(.subheadline)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        .opacity(milkType == type ? 1 : 0.5)
                                        .scaleEffect(milkType == type ? 1.1 : 1)
                                        .animation(.spring(response: 0.3), value: milkType)
                                    }
                                }
                            }
                            
                            // Quantity and Price
                            VStack(spacing: 15) {
                                CustomTextField(
                                    title: "Quantity (Liters)",
                                    text: $liters,
                                    icon: "drop.fill"
                                )
                                .keyboardType(.decimalPad)
                                
                                CustomTextField(
                                    title: "Price per Liter (₹)",
                                    text: $pricePerLiter,
                                    icon: "indianrupeesign"
                                )
                                .keyboardType(.decimalPad)
                            }
                            
                            // Delivery Status
                            Toggle(isOn: $isDelivered) {
                                HStack {
                                    Image(systemName: isDelivered ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(isDelivered ? .green : .red)
                                    Text("Milk Delivered")
                                        .font(.headline)
                                }
                            }
                            .tint(.green)
                            
                            if let litersDouble = Double(liters),
                               let priceDouble = Double(pricePerLiter) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Total Amount")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("₹\(litersDouble * priceDouble, specifier: "%.2f")")
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                }
                                .padding(.top)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // Delete Button (Only show in edit mode)
                        if isEditing {
                            Button(role: .destructive) {
                                showingDeleteAlert = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("Delete Entry")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .fill(Color.red.opacity(0.1))
                                }
                            }
                            .padding(.horizontal)
                            .alert("Delete Entry", isPresented: $showingDeleteAlert) {
                                Button("Cancel", role: .cancel) { }
                                Button("Delete", role: .destructive) {
                                    if let entry = editEntry {
                                        milkStore.deleteEntry(entry)
                                        dismiss()
                                    }
                                }
                            } message: {
                                Text("Are you sure you want to delete this entry? This action cannot be undone.")
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Add") {
                        saveEntry()
                        dismiss()
                    }
                    .font(.headline)
                    .disabled(!isFormValid)
                }
            }
            .onAppear {
                if let entry = editEntry {
                    date = entry.date
                    milkType = entry.type
                    liters = String(entry.liters)
                    pricePerLiter = String(entry.pricePerLiter)
                    isDelivered = entry.isDelivered
                }
            }
        }
    }
    
    private func saveEntry() {
        guard let litersDouble = Double(liters),
              let priceDouble = Double(pricePerLiter) else { return }
        
        let entry = MilkEntry(
            id: editEntry?.id ?? UUID(),
            date: date,
            type: milkType,
            liters: litersDouble,
            pricePerLiter: priceDouble,
            isDelivered: isDelivered
        )
        
        if isEditing {
            milkStore.updateEntry(entry)
        } else {
            milkStore.addEntry(entry)
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                TextField(title, text: $text)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}
