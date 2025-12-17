import UIKit

final class StatisticService {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case gamesCount = "gamesCount"
        case bestGameCorrect = "bestGameCorrect"
        case bestGameTotal = "bestGameTotal"
        case bestGameData = "bestGameData"
        case totalQuestionsAsked = "totalQuestionsAsked"
        case totalCorrectAnswer = "totalCorrectAnswer"
    }
}

extension StatisticService: StatisticServiceProtocol {
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = UserDefaults.standard.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = UserDefaults.standard.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = UserDefaults.standard.object(forKey: Keys.bestGameData.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameData.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        if totalQuestionsAsked != 0 {
            return (Double(totalCorrectAnswer)/Double(totalQuestionsAsked) * 100)
        } else {
            return 0.0
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount+=1
        totalQuestionsAsked = gamesCount*10
        totalCorrectAnswer+=count
        if count > bestGame.correct {
            bestGame = GameResult(correct: count, total: amount, date: Date())
        }
    }
    
    private var totalQuestionsAsked: Int {
        get {
            storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
        }
    }
    private var totalCorrectAnswer: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswer.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswer.rawValue)
        }
    }
}
