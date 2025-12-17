import UIKit

class AlertPresenter {
    weak var controller: UIViewController?
    
    init(controller: UIViewController? = nil) {
        self.controller = controller
    }
    
    func show(result: AlertModel) {
        let alert = UIAlertController(title: result.title, message: result.message, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in result.completion() }
        alert.addAction(action)
        controller?.present(alert, animated: true, completion: nil)
    }
}
