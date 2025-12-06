//
//  ContentView.swift
//  IsoCubeTimer
//
//  Created by Tamer Vassib on 06/12/2025.
//

import SwiftUI

struct ContentView: View {
    
    // Connect to your Logic
    @StateObject private var vm = TimerViewModel()
    
    // Track if finger is holding down
    @State private var isUserTouching = false
    // Track if the current touch was used to stop the timer
    @State private var gestureJustStoppedTimer = false
    
    // Dummy Data for history
    let lastSolves = [
        (time: "12.45", diff: "+0.12", color: Color.red),
        (time: "11.20", diff: "-1.23", color: Color.green),
        (time: "13.01", diff: "+0.50", color: Color.orange),
        (time: "10.99", diff: "-0.40", color: Color.green),
        (time: "14.50", diff: "+2.05", color: Color.red)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. DYNAMIC BACKGROUND
                // Uses function to switch between Indigo, Red, and Black
                LinearGradient(
                    colors: getBackgroundColors(),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                // Smoothly animate the color change
                .animation(.easeInOut(duration: 0.2), value: isUserTouching)
                .animation(.easeInOut(duration: 0.2), value: vm.isRunning)
                
                VStack(spacing: 0) {
                    
                    // --- TOP HEADER ---
                    // Hide header when timer is running to reduce distractions
                    if !vm.isRunning {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("IsoTimer")
                                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                Text("Ready to solve?")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            NavigationLink(destination: Text("Settings")) {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(12)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Spacer()
                        
                        // --- SCRAMBLE DISPLAY ---
                        Text(vm.scrambleDisplay)
                            .font(.title2)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.9))
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                            .padding(.horizontal, 40)
                            // Allow tapping scramble to generate a new one
                            .onTapGesture {
                                withAnimation {
                                    vm.generateNewScramble()
                                }
                            }
                    }
                    
                    Spacer()
                    
                    // --- MAIN TIMER ---
                    Text(vm.timeString)
                        .font(.system(size: 90, weight: .bold, design: .monospaced))
                        // Green if holding down, Yellow if running, White if idle
                        .foregroundColor(isUserTouching ? .green : (vm.isRunning ? .yellow : .white))
                        .shadow(color: isUserTouching ? .green : .indigo, radius: 20, x: 0, y: 0)
                        .padding(.vertical, 20)
                    
                    Spacer()
                    
                    // --- BOTTOM CARD ---
                    // Hide stats when timer is running
                    if !vm.isRunning {
                        VStack(spacing: 25) {
                            
                            // 1. Colorful Stats Pills
                            HStack(spacing: 15) {
                                StatPill(label: "Ao5", value: "12.30", color: .cyan)
                                StatPill(label: "Ao12", value: "12.55", color: .purple)
                                StatPill(label: "Best", value: "9.80", color: .yellow)
                            }
                            
                            Divider().overlay(.white.opacity(0.2))
                            
                            // 2. History List
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text("Recent History")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.8))
                                    Spacer()
                                    Image(systemName: "clock.arrow.circlepath")
                                        .foregroundColor(.gray)
                                }
                                
                                ForEach(lastSolves.indices, id: \.self) { index in
                                    let solve = lastSolves[index]
                                    HStack {
                                        Text("#\(index + 1)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .frame(width: 30)
                                        
                                        Text(solve.time)
                                            .font(.system(.body, design: .monospaced))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Text(solve.diff)
                                            .font(.caption)
                                            .padding(4)
                                            .background(solve.color.opacity(0.2))
                                            .foregroundColor(solve.color)
                                            .cornerRadius(4)
                                    }
                                }
                            }
                        }
                        .padding(30)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(35, corners: [.topLeft, .topRight])
                        .overlay(
                            RoundedCorner(radius: 35, corners: [.topLeft, .topRight])
                                .stroke(LinearGradient(colors: [.white.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                        )
                    }
                }
            }
            .preferredColorScheme(.dark)
            // Critical: Make the whole background tappable
            .contentShape(Rectangle())
            // FIXED GESTURE LOGIC:
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        // FINGER DOWN (Happens continuously)
                        
                        if vm.isRunning {
                            // If running, this touch is meant to STOP.
                            vm.toggleTimer()
                            // Set a flag so we don't accidentally restart immediately in the next frame
                            gestureJustStoppedTimer = true
                        } else if !gestureJustStoppedTimer {
                            // Only enter "Ready" (Red) state if we didn't JUST stop the timer
                            isUserTouching = true
                        }
                    }
                    .onEnded { _ in
                        // FINGER UP
                        
                        // Only start if we were actually holding down (Ready)
                        // AND this wasn't the same gesture that stopped the timer
                        if isUserTouching && !gestureJustStoppedTimer {
                            vm.toggleTimer()
                            isUserTouching = false
                        }
                        
                        // Reset the flag for the next completely new touch
                        gestureJustStoppedTimer = false
                    }
            )
        }
    }
    
    // Logic to pick the background color
    func getBackgroundColors() -> [Color] {
        if vm.isRunning {
            return [.black, .black] // Focus Mode
        } else if isUserTouching {
            return [.red.opacity(0.8), .black] // Ready State (Red)
        } else {
            return [.indigo.opacity(0.6), .black] // Idle State (Purple)
        }
    }
}

#Preview {
    ContentView()
}
