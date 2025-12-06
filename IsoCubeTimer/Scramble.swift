


import SwiftUI
import Foundation
import GameplayKit


struct Solve{
    let ID : String
    let scramble : String
    let time : Double
    init(scramble: String, time: Double) {
        self.ID = UUID().uuidString
        self.scramble = scramble
        self.time = time
    }
    
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

