import Foundation

private let _defaultQueue = OperationQueue()

extension OperationQueue {
    
    public static func serialQueue() -> OperationQueue {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }
    
    static internal var `default`: OperationQueue {
        return _defaultQueue
    }
    
    @discardableResult
    func addOperations(_ ops: [Operation], batchSize: Int? = 10, completion: (([Operation])->())? = nil) -> [Operation] {
        let final = BlockOperation() {
            DispatchQueue.main.async {
                completion?(ops)
            }
        }
        
        var batched: [Operation] = []
        var dependencies: [Operation] = []
        for op in ops {
            if let batchSize = batchSize {
                if batched.count >= batchSize {
                    dependencies += batched
                    batched = []
                }
                
                if batched.count < batchSize {
                    batched.append(op)
                }
            }
            for dependency in dependencies {
                op.addDependency(dependency)
            }
            final.addDependency(op)
        }
        let allOperations = ops + [final]
        addOperations(allOperations, waitUntilFinished: false)
        return allOperations
    }
}

