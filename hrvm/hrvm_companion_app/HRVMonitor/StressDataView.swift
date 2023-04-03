import SwiftUI

struct StressDataView: View {
    @EnvironmentObject var session: PhoneExportSession
    
    @State private var isReachable = "YES"
    @State private var hrvData: [Double] = []
    
    var body: some View {
        NavigationView {
            VStack {
                Text("HRV Companion")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("Stress View")
                    .font(.title)
                    .padding(.top, 16.0)
                    .padding(.bottom, 8.0)
                    .foregroundColor(.gray)
                
                if hrvData.isEmpty {
                    ProgressView("Loading HRV data...")
                } else {
                    LineChartView(data: hrvData)
                        .padding(.top, 16.0)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                // Load HRV data when the view appears
                hrvData = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0]
            }
        }
    }
}

// Line chart view
struct LineChartView: View {
    var data: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let xInterval = geometry.size.width / CGFloat(data.count - 1)
                let yInterval = geometry.size.height / CGFloat(data.max()! - data.min()!)
                for i in 0..<data.count {
                    let x = xInterval * CGFloat(i)
                    let y = yInterval * CGFloat(data[i] - data.min()!)
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: geometry.size.height - y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height - y))
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 1)
        }
        .aspectRatio(16/9, contentMode: .fit)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

