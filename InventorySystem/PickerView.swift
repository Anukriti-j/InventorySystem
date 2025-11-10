import SwiftUI

struct PickerExampleView: View {
    @State private var selectedRows = 1
    @State private var selectedColumns = 1
    @State private var selectedSlots = 1
    @State private var selectedBuckets = 1
    
    let range = 1...10
    
    var body: some View {
        Form {
            Section(header: Text("Configuration").font(.headline)) {
                HStack {
                    Text("Rows")
                    Spacer()
                    Picker("Rows", selection: $selectedRows) {
                        ForEach(range, id: \.self) { number in
                            Text("\(number)").tag(number)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 100)
                }
                
                HStack {
                    Text("Columns")
                    Spacer()
                    Picker("Columns", selection: $selectedColumns) {
                        ForEach(range, id: \.self) { number in
                            Text("\(number)").tag(number)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 100)
                }
                
                HStack {
                    Text("Slots")
                    Spacer()
                    Picker("Slots", selection: $selectedSlots) {
                        ForEach(range, id: \.self) { number in
                            Text("\(number)").tag(number)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 100)
                }
                
                HStack {
                    Text("Buckets")
                    Spacer()
                    Picker("Buckets", selection: $selectedBuckets) {
                        ForEach(range, id: \.self) { number in
                            Text("\(number)").tag(number)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 100)
                }
            }
            
            Section(header: Text("Selected Values")) {
                Text("Rows: \(selectedRows)")
                Text("Columns: \(selectedColumns)")
                Text("Slots: \(selectedSlots)")
                Text("Buckets: \(selectedBuckets)")
            }
        }
        .navigationTitle("Picker Example")
    }
}

#Preview {
    PickerExampleView()
}
