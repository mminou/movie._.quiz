import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenter?
    private var movieQuizPresenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAlertPresenter()
        
        showLoadingIndicator()
        movieQuizPresenter = MovieQuizPresenter(viewController: self)
        
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButton(_ sender: UIButton) {
        movieQuizPresenter.yesButton()
    }
    
    @IBAction private func noButton(_ sender: UIButton) {
        sender.isEnabled = false
        movieQuizPresenter.noButton()
    }
    
    // MARK: - Setup
    
    private func setupAlertPresenter() {
        let alertPresenter = AlertPresenter()
        alertPresenter.controller = self
        self.alertPresenter = alertPresenter
    }
    
    // MARK: - Private functions
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        setButtonsEnabled(false)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
    }
    
    func setButtonsEnabled(_ enabled: Bool) {
        yesButton.isEnabled = enabled
        noButton.isEnabled = enabled
    }
    
    func show(quiz result: QuizResultViewModel) {
        let alert = AlertModel(title: result.title,
                               message: result.text,
                               buttonText: result.buttonText, completion: { [weak self] in
                               guard let self = self else { return }
                               movieQuizPresenter.restartGame()
                                } )
        
        alertPresenter?.show(result: alert)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(_ message: String) {
        hideLoadingIndicator()
        let networkError = QuizResultViewModel(title: "Ошибка", text: message, buttonText: "Попробовать ещё раз")
        show(quiz: networkError)
        showLoadingIndicator()
    }
}

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultViewModel)
    
    func highlightImageBorder(isCorrect: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(_ message: String)
    
    func setButtonsEnabled(_ enabled: Bool)
}
