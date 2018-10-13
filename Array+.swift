import Foundation

extension Array where Element : Operation {
    
    public func batched(size batchSize: Int = 10) -> [Operation] {
        var batched: [Operation] = []
        var dependencies: [Operation] = []
        for op in self {
            if batched.count >= batchSize {
                dependencies += batched
                batched = []
            }
            
            if batched.count < batchSize {
                batched.append(op)
            }
            for dependency in dependencies {
                op.addDependency(dependency)
            }
        }
        return self
    }
    
    public func chained() -> [Operation] {
        var last: Operation?
        for op in self {
            if let dependency = last {
                op.addDependency(dependency)
            }
            last = op
        }
        return self
    }
    
    @discardableResult
    public func queue(on providedQueue: OperationQueue? = nil, batchSize: Int? = 10, completion: (([Operation])->())? = nil) -> [Operation] {
        let queue: OperationQueue = providedQueue ?? .default
        return queue.addOperations(self, batchSize: batchSize, completion: completion)
    }
}
