import Foundation
import CovertOps

struct Todo {
    
}

class ShowActivityIndicator: AsyncMainOperation<Void> {
    
    private weak var parentView: UIView?
    private var activityIndcatorView: UIView?
    
    init(in parentView: UIView) {
        self.parentView = parentView
    }
    
    override func execute() {
        guard let parentView = parentView else {
            cancel()
            return
        }
        let activityIndcatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndcatorView.color = .black
        activityIndcatorView.frame = parentView.bounds
        activityIndcatorView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        activityIndcatorView.startAnimating()
        parentView.addSubview(activityIndcatorView)
        
        activityIndcatorView.alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            activityIndcatorView.alpha = 1.0
        }
        
        self.activityIndcatorView = activityIndcatorView
    }
    
    override func cancel() {
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.activityIndcatorView?.alpha = 0.0
            },
            completion: { _ in
                self.activityIndcatorView?.removeFromSuperview()
                self.finish()
            }
        )
    }
}

class DownloadData: AsyncOperation<Todo> {
    
    let id: Int
    
    init(id: Int) {
        self.id = id
    }
    
    override func execute() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/\(id)")!
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                self.cancel()
                return
            }
            
            print(data)
            self.finish()
        }
        task.resume()
    }
}
