import UIKit
import CovertOps

/// This navigation logic is encapsulated in this operation.  The "origin" view controller
/// provided in the initializer and the "destination" view controller created are
/// completely decoupled from one another.
class ShowDetail: AsyncMainOperation<Void>, DetailViewDelegate {
    private let demo: Demo
    private weak var originViewController: UIViewController?
    
    init(demo: Demo, from originViewController: UIViewController) {
        self.demo = demo
        self.originViewController = originViewController
    }
    
    override func execute() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let originViewController = originViewController,
            let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            cancel()
            return
        }

        detailViewController.delegate = self
        detailViewController.demo = demo
        let navigationController = UINavigationController(rootViewController: detailViewController)
        originViewController.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - DetailViewDelegate
    
    func onDone() {
        guard let originViewController = originViewController else {
            cancel()
            return
        }
        originViewController.dismiss(animated: true) {
            self.finish()
        }
    }
}
