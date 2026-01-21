import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private var currentQuestion: QuizQuestion?
    private var currentQuestIndex = 0
    private let questionsAmount = 10
    private var correctAnswer: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didAnswer(isCorrect: Bool) {
        if isCorrect {
            self.correctAnswer += 1
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? UIImage()
        let text = model.text
        let number = "\(currentQuestIndex + 1)/\(questionsAmount)"
        let convertModel = QuizStepViewModel(image: image, question: text, questionNumber: number)
        return convertModel
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
    
    private func isLastQuestion() -> Bool {
        currentQuestIndex == questionsAmount - 1
    }

    private func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswer, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        let currentGameResultLine = "Ваш результат: \(correctAnswer)/\(questionsAmount)"
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGameInfoLine = "рекорд: \(bestGame.correct)/\(statisticService.bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let resultText = [currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        return resultText
    }
    
    private func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let quizResult = QuizResultViewModel(
                title: "Этот раунд окончен!",
                text: makeResultsMessage(),
                buttonText: "Сыграть еще раз"
            )
            viewController?.show(quiz: quizResult)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
        
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        didAnswer(isCorrect: isCorrect)
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            viewController?.setButtonsEnabled(true)
        }
    }
    
    private func didAnswer(_ isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == isYes)
    }
}
