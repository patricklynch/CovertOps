import Foundation
import CovertOps

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
