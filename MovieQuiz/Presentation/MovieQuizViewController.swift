import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    @IBAction private func yesButton(_ sender: UIButton) {
        let answer = true
        guard let currentQuestion = currentQuestion else {
            return
        }
        let isCorrect = currentQuestion.correctAnswer == answer
        showAnswerResult(isCorrect: isCorrect)
    }
    
    @IBAction private func noButton(_ sender: UIButton) {
        sender.isEnabled = false
        let answer = false
        guard let currentQuestion = currentQuestion else {
            return
        }
        let isCorrect = currentQuestion.correctAnswer == answer
        showAnswerResult(isCorrect: isCorrect)
    }
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    private var currentQuestIndex: Int = 0
    private var correctAnswer: Int = 0
    
    private let questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService = StatisticService()
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(named: model.image) ?? UIImage()
        let text = model.text
        let number = "\(currentQuestIndex+1)/\(questionsAmount)"
        let convertModel = QuizStepViewModel(image: image, question: text, questionNumber: number)
        return convertModel
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        if isCorrect {
            self.correctAnswer+=1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    private func showNextQuestionOrResults() {
        
        
        
        if currentQuestIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswer, total: questionsAmount)
            let quizResult = QuizResultViewModel(title: "Этот раунд окончен!",
                                                 text: "Ваш результат: \(correctAnswer)/\(questionsAmount)\nКоличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%",
                                                 buttonText: "Сыграть еще раз")
            show(quiz: quizResult)
        } else {
            currentQuestIndex += 1
            
            questionFactory?.requestNextQuestion()
        }
        
    }
    
    private func show(quiz result: QuizResultViewModel) {
        let alert = AlertModel(title: result.title,
                               message: result.text,
                               buttonText: result.buttonText, completion: { [weak self] in
                               guard let self = self else { return }
                               self.currentQuestIndex = 0
                               self.correctAnswer = 0
                               questionFactory?.requestNextQuestion() } )
        
        alertPresenter?.show(result: alert)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        let alertPresenter = AlertPresenter()
        alertPresenter.controller = self
        self.alertPresenter = alertPresenter
        
        self.questionFactory?.requestNextQuestion()
        
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}
