import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var currentQuestIndex = 0
    let questionsAmount = 10
    var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewController?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    var correctAnswer: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
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
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswer, total: questionsAmount)
            let quizResult = QuizResultViewModel(title: "Этот раунд окончен!",
                                                 text: "Ваш результат: \(correctAnswer)/\(questionsAmount)\nКоличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%",
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
