


import SwiftUI
import Foundation
import GameplayKit
import Foundation

struct Solve : Codable{
    let ID : String
    let scrambleID : String
    let time : Double
    let dateSolved : Date
    init(scramble: String, time: Double,dateSolved : Date) {
        self.ID = UUID().uuidString
        self.scrambleID = scramble
        self.time = time
        self.dateSolved = dateSolved
    }
    
}


import Foundation

struct SolveDataSheet {
    let AO5: Double
    let AO12: Double

    
    let Best: Double
    

    
    init(AO5: Double, AO12: Double, Best: Double){
        self.AO12 = AO12
        self.Best = Best
        self.AO5 = AO5
    }
}


func createDataSheet(solves : [Solve]) -> SolveDataSheet{
    var avOf5 = 0.0
    var avOf12 = 0.0
    var best = 999999.0
    let newestFirst = solves.sorted { $0.dateSolved > $1.dateSolved }

    for (i, solve) in newestFirst.enumerated() {
        
        
        if i < 5 {
            avOf5 += solve.time
            print(solve.time)
        }
        

        if i < 12 {
            avOf12 += solve.time
        }
        

        if solve.time < best {
            best = solve.time
        }
    }
    avOf5 /= 5.0
    avOf12 /= 12.0
    
    if solves.count < 12{
        avOf12 = 0.0
    }
    if solves.count < 5{
        avOf5 = 0.0
    }
    if solves.count <= 0{
        best = 0.0
    }
    return SolveDataSheet(AO5: avOf5, AO12: avOf12, Best: best)
    
}

struct Scramble{
    static var scrambleLetters = ["R","L","D","M","B","U","F"]
    var scramble : String = ""
    let ID : String
    
    init() {
    
        self.ID = UUID().uuidString
        self.scramble = Scramble.getScramble(id: self.ID)
  
    }
    static func getScramble(id : String) -> String {
    
        let seedData = id.data(using: .utf8)!
        let seededGenerator = GKMersenneTwisterRandomSource(seed: UInt64(seedData[0]))
        var scramble : String = ""
        for _ in 1...12{
            var newLetter : String = Scramble.scrambleLetters[seededGenerator.nextInt(upperBound: Scramble.scrambleLetters.count-1)]
            if Int.random(in: 0...3) == 1 {
                newLetter += "'"
            }
            scramble+=newLetter + " "
        }
        return scramble
    }
        
}

