//
//  SoundModel.swift
//  iTimer2
//
//  Created by Nihaal Garud on 17/08/2024.
//

import Foundation
import SwiftUI

class SoundModel: ObservableObject {
    
    @AppStorage("selectedSound") var selectedSound: String = "alarm"
    
}
