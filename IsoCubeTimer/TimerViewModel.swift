




import SwiftUI

class TimerViewModel: ObservableObject {
    // @Published means: "If this variable changes, update the UI automatically"
    @Published var scrambleDisplay: String = "Loading..."
    @Published var timeString: String = "0.00"
    @Published var isRunning: Bool = false
    @Published var dataSheet : SolveDataSheet?
    
    @Published var Solves : [Solve] = []
    
    // This holds the actual data object (optional, in case we need the ID later)
    private var currentScramble: Scramble?
    
    private var timer: Timer?
    private var startTime: Date?
    private var timeElapsed : Double?
    
    @Published var lastSolves : [(time: String, diff: String, color: Color)] = []
        
    
    // This runs immediately when the app starts
    init() {
        generateNewScramble()
        Solves = loadSolves()
        dataSheet = createDataSheet(solves: Solves)
        setLastSolves()
        saveAllSolves()
        
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
                self.timeElapsed = Date().timeIntervalSince(self.startTime!)
                
                // Update the string (format to 2 decimal places)
                self.timeString = String(format: "%.2f", self.timeElapsed ?? 0)
            }
        }
    
    public func deleteSolve(index : Int){
        Solves = Solves.sorted { $0.dateSolved > $1.dateSolved }
        Solves.remove(at: index)
        saveAllSolves()
        Solves = loadSolves()
        dataSheet = createDataSheet(solves: Solves)
        setLastSolves()
    
    }
    
    private func stop() {
        // 1. Kill the timer process0
        timer?.invalidate()
        timer = nil
        isRunning = false
        
        // 2. Logic to save the solve would go here (we'll do this later)
        print("Final Time: \(timeString)")
        
        saveNewSolve(time: self.timeElapsed ?? 0,scram : currentScramble?.ID ?? "NULL" )
        // 3. Generate a new scramble for the next round
        generateNewScramble()
        Solves = loadSolves()
        dataSheet = createDataSheet(solves: Solves)
        
        setLastSolves()
    }
    
    func setLastSolves(){
        lastSolves = []
        let newestFirst = Solves.sorted { $0.dateSolved > $1.dateSolved }
        for i in 0..<5 {
    
            if newestFirst.indices.contains(i) && newestFirst.indices.contains(i + 1) {
                
                let currentTime = newestFirst[i].time
                let prevTime = newestFirst[i+1].time
                let diff = currentTime - prevTime
                
          
                let statusColor: Color = diff <= 0 ? .green : .red
                
              
                lastSolves.append((
                    time: String(format: "%.2f", currentTime),
                    diff: String(format: "%+.2f", diff),
                    color: statusColor
                ))
            }
            else if newestFirst.indices.contains(i){
                lastSolves.append((
                    time: String(format: "%.2f", newestFirst[i].time),
                    diff: String(format: "%+.2f", 0.0),
                    color: Color.green
                ))
                
            }
        }
    }
        
            
        
    func generateNewScramble() {
        // 1. Create the Scramble Object
        let newScramble = Scramble()
        
        // 2. Save the object for logic (logging to database later)
        self.currentScramble = newScramble
        
        // 3. Take out the scramble string for the UI
        self.scrambleDisplay = newScramble.scramble
    }
    
    
    func saveNewSolve(time: Double, scram: String) {
 
        let newSolve = Solve(scramble: scram, time: time, dateSolved: Date.now)
        
        var currentSolves = loadSolves()
        

        currentSolves.append(newSolve)
        
        Solves = currentSolves
        
        saveAllSolves()
        
    }
    
    func saveAllSolves(){
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent("solves.json")
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let data = try encoder.encode(Solves)
            
            try data.write(to: fileURL)
            
            print("Saved! Total solves: \(Solves.count)")
            
        } catch {
            print("Error saving file: \(error)")
        }
    }
    
    func loadSolves() -> [Solve] {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
        let fileURL = documentsDirectory.appendingPathComponent("solves.json")
        
        // 1. Check if file exists BEFORE trying to read it
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            print("ℹ️ First run: No file exists yet. Starting with empty list.")
            return [] // Return empty list quietly
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let solves = try decoder.decode([Solve].self, from: data)
            return solves
        } catch {
            print("❌ Error corrupt data: \(error)")
            return []
        }
    }
}
