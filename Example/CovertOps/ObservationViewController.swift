import UIKit
import CovertOps

class ImportantTodoService {
    
    private(set) var nextTodo: Todo?
    
    func reload() {
        let randomId: Int = Array(1..<100).randomElement() ?? 1
        DownloadData(id: randomId).queue() { result in
            guard let result = result,
                case .success(let data) = result else {
                    return
            }
            self.nextTodo = data
        }
    }
}

class ObservationViewController: UIViewController {
    
    let importantTodoService = ImportantTodoService()
    
    private weak var observer: Operation?
    private weak var activtyIndicatorOperation: Operation?
    
    @IBOutlet private weak var label: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        observer = Observe(self.importantTodoService.nextTodo).start() { observer, value in
            if let value = value {
                let status = value.completed ? "Completed" : "Not Completed"
                self.label.text = "\(value.title.localizedCapitalized)\n\n(\(status))"
            } else {
                self.label.text = "Tap \"Reload\" to see next todo."
            }
            self.activtyIndicatorOperation?.cancel()
        }.trigger()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        observer?.cancel()
    }
    
    @IBAction func reloadTodo() {
        activtyIndicatorOperation = ShowActivityIndicator(in: view).queue()
        importantTodoService.reload()
    }
}
