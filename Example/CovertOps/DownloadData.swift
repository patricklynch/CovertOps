import Foundation
import CovertOps

class Todo: Codable, Hashable, Comparable {
    static func < (lhs: Todo, rhs: Todo) -> Bool {
        return lhs.dateUpdated > rhs.dateUpdated
    }
    
    static func == (lhs: Todo, rhs: Todo) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: Int
    let title: String
    var completed: Bool {
        didSet {
            dateUpdated = Date()
        }
    }
    private(set) var dateUpdated = Date()
    let userId: Int?
    
    init(title: String) {
        self.title = title
        id = (100..<100000).randomElement() ?? 0
        completed = false
        userId = nil
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, title, completed, userId
    }
    
    var hashValue: Int {
        return id.hashValue
    }
}

class ShowActivityIndicator: AsyncMainOperation<Void> {
    
    private weak var parentView: UIView?
    private var activityIndcatorView: UIView?
    private let animationDuration: TimeInterval
    
    init(in parentView: UIView, animationDuration: TimeInterval = 0.25) {
        self.parentView = parentView
        self.animationDuration = animationDuration
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
        UIView.animate(withDuration: animationDuration) {
            activityIndcatorView.alpha = 1.0
        }
        
        self.activityIndcatorView = activityIndcatorView
    }
    
    override func cancel() {
        UIView.animate(
            withDuration: animationDuration,
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

enum Result<T> {
    case success(data: T)
    case error(Error)
}

class DownloadData: AsyncOperation<Result<Todo>> {
    
    let id: Int
    
    init(id: Int) {
        self.id = id
    }
    
    override func execute() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/\(id)")!
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            let decoder = JSONDecoder()
            if let error = error {
                self.finish(output: .error(error))
                
            } else if let data = data,
                let todo = try? decoder.decode(Todo.self, from: data) {
                self.finish(output: .success(data: todo))
            }
        }
        task.resume()
    }
}
