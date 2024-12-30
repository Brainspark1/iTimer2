import SwiftUI
import IOKit.pwr_mgt

struct CaffeinateModeView: View {
    @AppStorage("isCaffeinated") private var isCaffeinated = false
    @State private var assertionID: IOPMAssertionID = 0 // Use @State for mutability
    @State private var showPopover = false

    var body: some View {
        VStack {
            
            HStack {
                
                Toggle(isOn: $isCaffeinated) {
                  Image(systemName: "cup.and.saucer.fill")
                }
                .onChange(of: isCaffeinated) { value in
                    toggleCaffeinate(value: value)
                }
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                
                Button(action: {
                    showPopover.toggle()
                }) {
                    Image(systemName: "questionmark.circle")
                        .font(.headline)
                }
                .popover(isPresented: $showPopover, attachmentAnchor: .point(.trailing), arrowEdge: .trailing) {
                    Text("Toggle on Caffeinate Mode to keep your Mac awake")
                        .padding()
                }
                .buttonStyle(BorderlessButtonStyle())
            }
           
        }
    }

    private func toggleCaffeinate(value: Bool) {
        if value {
            startCaffeinate()
        } else {
            stopCaffeinate()
        }
    }

    private func startCaffeinate() {
        let success = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Caffeinate Mode" as CFString,
            &assertionID
        )

        if success == kIOReturnSuccess {
            print("Caffeinate mode started.")
        } else {
            print("Failed to start caffeinate mode.")
        }
    }

    private func stopCaffeinate() {
        let success = IOPMAssertionRelease(assertionID)

        if success == kIOReturnSuccess {
            print("Caffeinate mode stopped.")
        } else {
            print("Failed to stop caffeinate mode.")
        }
    }
}
