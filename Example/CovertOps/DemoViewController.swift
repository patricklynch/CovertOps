import UIKit
import CovertOps

class DemoViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var dataSource: DemoDataSource!
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let demo = dataSource.demos[indexPath.row]
        switch demo {
        case .showDetail:
            ShowDetail(demo: demo, from: self).queue()
            
        case .showMultipleAlerts:
            let operations = [
                ShowAlert(from: self),
                ShowAlert(from: self),
                ShowAlert(from: self)
            ]
            operations.chained().queue() { operations in
                print("Finished showing \(operations.count) alerts.")
            }
            
        case .downloadConcurrentData:
            let showLoading = ShowActivityIndicator(in: view).queue()
            let operations = (1...10).map() { integer in
                return DownloadData(id: integer)
            }
            operations.chained().queue() { operations in
                let todos: [Todo] = operations
                    .compactMap { $0 as? DownloadData }
                    .compactMap {
                        if let result = $0.output,
                            case let .success(data) = result {
                            return data
                        } else {
                            return nil
                        }
                    }
                print("Downloaded \(todos.count) todos.")
                showLoading.cancel()
            }
        case .observation:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let viewController = storyboard.instantiateViewController(withIdentifier: "ObservationViewController") as? ObservationViewController else {
                return
            }
            navigationController?.pushViewController(viewController, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class DemoDataSource: NSObject, UITableViewDataSource {
    
    let demos = Demo.allCases
    
    // MARK: - UITableViewDatasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell", for: indexPath) as! DemoCell
        let demo = demos[indexPath.row]
        cell.viewData = demo.demoDescription
        return cell
    }
}
