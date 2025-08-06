//
//  PopoutViews.swift
//  iTimer2
//
//  Created by Nihaal Garud on 17/08/2024.
//

import Foundation
import SwiftUI

struct PopoutView: View {
    
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var provm: ProViewModel
    
    var body: some View {
        VStack {
            Text("\(timeString(time: timerManager.remainingTime))")
                .font(.system(size: 50))
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if provm.proTrue {
                ProgressView(value: timerManager.progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
            }
            
            HStack {
                Button(action: {
                    timerManager.isRunning ? pauseTimer() : startTimer()
                }) {
                    Text(timerManager.isRunning ? "Pause" : "Start")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .keyboardShortcut(.return, modifiers: .command)
                .padding()
                .fixedSize()
                .buttonStyle(PlainButtonStyle())
                .frame(width: 112, height: 26)
                
                Button(action: stopTimer) {
                    Text("Stop")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .keyboardShortcut(.return, modifiers: [.command, .shift])
                .fixedSize()
                .buttonStyle(PlainButtonStyle())
                .frame(width: 112, height: 26)
            }
            .padding()
        }
        .padding()
    }
    
    func timeString(time: Int) -> String {
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func startTimer() {
        let hours = Int(timerManager.hoursInput) ?? 0
        let minutes = Int(timerManager.minutesInput) ?? 0
        let seconds = Int(timerManager.secondsInput) ?? 0
        timerManager.startNewTimer(hours: hours, minutes: minutes, seconds: seconds, name: "Timer")
    }
    
    func pauseTimer() {
            timerManager.timer?.cancel()
            timerManager.isRunning = false
        }
    
    func stopTimer() {
            timerManager.remainingTime = 0
            timerManager.timer?.cancel()
            timerManager.isRunning = false
        }
}

struct PomoPopoutView: View {
    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        VStack {
            Text(viewModel.isOnBreak ? "Break Time" : "Work Time")
                .font(.largeTitle)
                .padding()

            Text("\(timeString(time: viewModel.timeRemaining))")
                .font(.system(size: 50))
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack {
                Button(action: {
                    if viewModel.isTimerRunning {
                        viewModel.stopTimer()
                    } else {
                        viewModel.startTimer()
                    }
                }) {
                    Text(viewModel.isTimerRunning ? "Pause" : "Start")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                .fixedSize()
                .buttonStyle(PlainButtonStyle())
                .frame(width: 112, height: 26)
                
                Button(action: {
                    viewModel.stopTimer()
                    viewModel.resetTimer(workDuration: viewModel.getWorkDuration())
                }) {
                    Text("Reset")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                .fixedSize()
                .buttonStyle(PlainButtonStyle())
                .frame(width: 112, height: 26)
            }
            .padding()
        }
        .padding()
    }

    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
