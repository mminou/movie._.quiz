import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter?
    private var movieQuizPresenter = MovieQuizPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupQuestionFactory()
        setupAlertPresenter()
        
        showLoadingIndicator()
        questionFactory?.loadData()
        
        movieQuizPresenter.viewController = self
        
    }
    
    // MARK: - Setup
    
    private func setupQuestionFactory() {
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader())
        questionFactory.delegate = self
        self.questionFactory = questionFactory
    }
    
    private func setupAlertPresenter() {
        let alertPresenter = AlertPresenter()
        alertPresenter.controller = self
        self.alertPresenter = alertPresenter
    }

    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        movieQuizPresenter.didReceiveNextQuestion(question: question)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        
        movieQuizPresenter.didAnswer(isCorrect: isCorrect)
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.movieQuizPresenter.questionFactory = self.questionFactory
            
            self.movieQuizPresenter.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    func show(quiz result: QuizResultViewModel) {
        let alert = AlertModel(title: result.title,
                               message: result.text,
                               buttonText: result.buttonText, completion: { [weak self] in
                               guard let self = self else { return }
                               movieQuizPresenter.restartGame()
                               questionFactory?.loadData() } )
        
        alertPresenter?.show(result: alert)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(_ message: String) {
        hideLoadingIndicator()
        let networkError = QuizResultViewModel(title: "Ошибка", text: message, buttonText: "Попробовать ещё раз")
        show(quiz: networkError)
        showLoadingIndicator()
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(error.localizedDescription)
    }
    
    @IBAction private func yesButton(_ sender: UIButton) {
        movieQuizPresenter.yesButton()
    }
    
    @IBAction private func noButton(_ sender: UIButton) {
        sender.isEnabled = false
        movieQuizPresenter.noButton()
    }
}
