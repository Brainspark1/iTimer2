//
//  LayoutViewModel.swift
//  iTimer2
//
//  Created by Nihaal Garud on 19/08/2024.
//

import Foundation
import SwiftUI

class LayoutViewModel: ObservableObject {
    
    @AppStorage("showPomButton") var showPomButton: Bool = true
    @AppStorage("showStopwatchButton") var showStopwatchButton: Bool = true
    @AppStorage("showHistoryButton") var showHistoryButton: Bool = true
    @AppStorage("onlyTimerModel") var onlyTimerMode: Bool = false
    
}
