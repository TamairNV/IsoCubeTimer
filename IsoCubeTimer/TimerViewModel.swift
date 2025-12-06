




import SwiftUI

class TimerViewModel: ObservableObject {
    // @Published means: "If this variable changes, update the UI automatically"
    @Published var scrambleDisplay: String = "Loading..."
    @Published var timeString: String = "0.00"
    @Published var isRunning: Bool = false
    
    // This holds the actual data object (optional, in case we need the ID later)
    private var currentScramble: Scramble?
    
    private var timer: Timer?
    private var startTime: Date?
        
    
    // This runs immediately when the app starts
    init() {
        generateNewScramble()
    }
    
    func toggleTimer() {
            if isRunning {
                stop()
            } else {
                start()
            }
        }
    private func start() {
            // 1. Mark the start time
            startTime = Date()
            isRunning = true
            
            // 2. Start the run loop (updates UI every 0.01s)
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                // Calculate exact difference between NOW and START
                let timeElapsed = Date().timeIntervalSince(self.startTime!)
                
                // Update the string (format to 2 decimal places)
                self.timeString = String(format: "%.2f", timeElapsed)
            }
        }
    
    private func stop() {
            // 1. Kill the timer process
            timer?.invalidate()
            timer = nil
            isRunning = false
            
            // 2. Logic to save the solve would go here (we'll do this later)
            print("Final Time: \(timeString)")
            
            // 3. Generate a new scramble for the next round
            generateNewScramble()
        }
    func generateNewScramble() {
        // 1. Create the Scramble Object
        let newScramble = Scramble()
        
        // 2. Save the object for logic (logging to database later)
        self.currentScramble = newScramble
        
        // 3. Take out the scramble string for the UI
        self.scrambleDisplay = newScramble.scramble
    }
}
