import UIKit

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func comparison(_ result: GameResult) -> Bool {
        return correct > result.correct
    }
}
