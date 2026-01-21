@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
    // все ниже Mock заглушка
    
    func show(quiz step: QuizStepViewModel) {
    
    }
    
    func show(quiz result: QuizResultViewModel) {
    
    }
    
    func highlightImageBorder(isCorrect: Bool) {
    
    }
    
    func showLoadingIndicator() {
    
    }
    
    func hideLoadingIndicator() {
    
    }
    
    func showNetworkError(_ message: String) {
    
    }
    func setButtonsEnabled(_ enabled: Bool) {

    }
}
