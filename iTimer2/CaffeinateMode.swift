import SwiftUI
import IOKit.pwr_mgt

struct CaffeinateModeView: View {
    @AppStorage("isCaffeinated") private var isCaffeinated = false
    @State private var assertionID: IOPMAssertionID = 0 // Use @State for mutability

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
