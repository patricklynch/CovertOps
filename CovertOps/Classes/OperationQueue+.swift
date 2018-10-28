import Foundation

private let _defaultQueue = OperationQueue()

protocol StartableOperation {
    func operationWillStart()
}

extension QueueableOperation: StartableOperation {}

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
        for op in ops as? [StartableOperation] ?? [] {
            op.operationWillStart()
        }
        addOperations(ops, waitUntilFinished: false)
        addOperation(final)
        return ops
    }
}

