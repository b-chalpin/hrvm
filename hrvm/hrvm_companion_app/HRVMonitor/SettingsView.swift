import SwiftUI

struct SettingsView: View {
    @State var age: Int = 0
    @State var height: Int = 0
    @State var weight: Int = 0
    @State var sex: String = ""
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 30.0)
            
            VStack(alignment: .leading, spacing: 30.0) {
                VStack(alignment: .leading) {
                    Text("Age")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    TextField("Enter your age", value: $age, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .frame(height: 50.0)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10.0)
                }
                
                VStack(alignment: .leading) {
                    Text("Height (ft)")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    TextField("Enter your height", value: $height, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .frame(height: 50.0)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10.0)
                }
                
                VStack(alignment: .leading) {
                    Text("Weight (lbs)")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    TextField("Enter your weight", value: $weight, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .frame(height: 50.0)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10.0)
                }
                
                VStack(alignment: .leading) {
                    Text("Sex")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Picker(selection: $sex, label: Text("Sex")) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                }
            }
            .padding(.bottom, 30.0)
            
            HStack {
                Button(action: {
                    // Save settings action
                }) {
                    Text("Save Settings")
                        .fontWeight(.bold)
                        .padding(.vertical, 15.0)
                        .padding(.horizontal, 25.0)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10.0)
                }
                
                Spacer()
                
                Button(action: {
                    // Clear settings action
                }) {
                    Text("Clear Settings")
                        .fontWeight(.bold)
                        .padding(.vertical, 15.0)
                        .padding(.horizontal, 25.0)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10.0)
                }
            }
        }
        .padding(.horizontal, 30.0)
        .padding(.top, 50.0)
    }
}
