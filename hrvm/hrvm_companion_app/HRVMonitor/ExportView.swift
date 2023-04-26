import SwiftUI

struct ExportView: View {
    @EnvironmentObject var session: PhoneExportSession
    @State private var isReachable = "YES"

    var body: some View {
        VStack {
            Spacer()

            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 72))
                .padding()

            Text("Export HRV Data")
                .font(.title)

            Spacer()

            HStack {
                Button(action: {
                    let updateIsReachable: String
                    if self.session.session == nil {
                        updateIsReachable = "YES"
                    } else {
                        updateIsReachable = self.session.session!.isReachable ? "YES": "NO"
                    }
                    self.isReachable = updateIsReachable
                }) {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .padding(.horizontal)
            }

            Spacer()

            HStack {
                Text("Export Session Active:")
                    .font(.headline)

                Text(self.isReachable)
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            .padding()

            Text("In order for your iPhone to receive export from the Watch, this app must be open.")
                .multilineTextAlignment(.center)
                .padding()

            Spacer()
        }
        .background(Color(.systemGray6))
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}
