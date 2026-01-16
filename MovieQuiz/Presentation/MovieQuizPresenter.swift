import UIKit

final class MovieQuizPresenter {
    
    private var currentQuestIndex = 0
    let questionsAmount = 10
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
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
    func resetQuestionIndex() {
        currentQuestIndex = 0
    }
    func switchToNextQuestion() {
        currentQuestIndex += 1
    }
    
    func yesButton() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    func noButton() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        viewController?.showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
}
