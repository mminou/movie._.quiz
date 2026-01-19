import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var currentQuestIndex = 0
    let questionsAmount = 10
    var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewController?
    private var statisticService: StatisticServiceProtocol!
    var correctAnswer: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? UIImage()
        let text = model.text
        let number = "\(currentQuestIndex + 1)/\(questionsAmount)"
        let convertModel = QuizStepViewModel(image: image, question: text, questionNumber: number)
        return convertModel
    }
    
    func isLastQuestion() -> Bool {
        return currentQuestIndex == questionsAmount - 1
    }
    func restartGame() {
        currentQuestIndex = 0
        correctAnswer = 0
        questionFactory?.loadData()
    }
    func switchToNextQuestion() {
        currentQuestIndex += 1
    }
    
    func yesButton() {
        didAnswer(true)
    }
    
    func noButton() {
        didAnswer(false)
    }
    private func didAnswer(_ isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == isYes)
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswer, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        let currentGameResultLine = "Ваш результат: \(correctAnswer)/\(questionsAmount)"
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGameInfoLine = "рекорд: \(bestGame.correct)/\(statisticService.bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let resultText = [currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        return resultText
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            
            let quizResult = QuizResultViewModel(title: "Этот раунд окончен!",
                                                 text: makeResultsMessage(),
                                                 buttonText: "Сыграть еще раз")
            viewController?.show(quiz: quizResult)
        } else {
            self.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
        
    }
    
    func didAnswer(isCorrect: Bool) {
        if isCorrect {
            self.correctAnswer+=1
        }
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
}
