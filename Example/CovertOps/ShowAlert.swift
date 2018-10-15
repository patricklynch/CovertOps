import UIKit
import CovertOps

class ShowAlert: AsyncMainOperation<Void> {
    private weak var originViewController: UIViewController?
    
    init(from originViewController: UIViewController) {
        self.originViewController = originViewController
    }
    
    override func execute() {
        guard let originViewController = self.originViewController else {
            cancel()
            return
        }
        
        let alert = UIAlertController(
            title: "Hello World!",
            message: "Just a plain and simple alert.",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: { action in
                self.finish()
            })
        )
        originViewController.present(alert, animated: true, completion: nil)
    }
}
