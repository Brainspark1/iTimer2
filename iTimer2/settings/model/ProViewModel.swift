import Foundation
import SwiftUI

class ProViewModel: ObservableObject {
    
    @AppStorage("proTrue") var proTrue: Bool = false
//    @Published var upgradeButtonIsClosed: Bool = false
    
    @Published var userProPassword: String = ""
    @Published var actualProPassword: String = "LRx4-YG53-Ub73-723A"
    
    var passwordWindow: NSWindow?
}
