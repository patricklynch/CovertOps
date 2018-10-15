import UIKit

protocol DetailViewDelegate: class {
    func onDone()
}

class DetailViewController: UIViewController {
    
    @IBOutlet private weak var label: UILabel!
    
    var demo: Demo?
    var delegate: DetailViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = demo?.title
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(onDone)
        )
    }
    
    @objc private func onDone() {
        delegate?.onDone()
    }
}
