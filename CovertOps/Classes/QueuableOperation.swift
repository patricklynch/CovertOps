import UIKit

private var _retainedOperations = Set<Operation>()

open class QueueableOperation<OutputType>: Operation {
    
    final public var output: OutputType?
    
    public final func outputFromDependency<T>() -> T? {
        let typedDependencies = dependencies.compactMap { $0 as? QueueableOperation<T> }
        guard !typedDependencies.isEmpty else { return nil }
        return typedDependencies.compactMap { $0.output }.first
    }
    
    public final func typedDependency<DependencyType>() -> DependencyType? {
        return dependencies.compactMap { $0 as? DependencyType }.first
    }
    
    @discardableResult
    public final func followed<T>(by nextOperation: QueueableOperation<T>, mainQueueCompletionBlock: ((T?)->())? = nil) -> QueueableOperation<OutputType> {
        nextOperation.addDependency(self)
        nextOperation.queue(mainQueueCompletionBlock: mainQueueCompletionBlock)
        return self
    }
    
    @discardableResult
    public final func then(_ mainQueueCompletionBlock: @escaping (QueueableOperation<OutputType>, OutputType?)->()) -> QueueableOperation<OutputType> {
        completionBlock = { [weak self] in
            guard let strelf = self else {
                return
            }
            DispatchQueue.main.async {
                mainQueueCompletionBlock(strelf, strelf.output)
                _retainedOperations.remove(strelf)
            }
        }
        return self
    }
    
    @discardableResult
    public final func before(_ dependant: Operation) -> QueueableOperation<OutputType> {
        dependant.addDependency(self)
        return self
    }
    
    @discardableResult
    public final func following(_ dependency: Operation) -> QueueableOperation<OutputType> {
        addDependency(dependency)
        return self
    }
    
    @discardableResult
    public final func following(_ operations: [Operation]) -> QueueableOperation<OutputType> {
        for op in operations {
            addDependency(op)
        }
        return self
    }
    
    /// Subclasses may override to specify a queue that they would like to use.
    /// The default return value is `OperationQueue.default`
    open var preferredQueue: OperationQueue {
        return OperationQueue.default
    }
    
    @discardableResult
    open func queue(
        on queue: OperationQueue? = nil,
        mainQueueCompletionBlock: ((OutputType?)->())? = nil) -> QueueableOperation<OutputType> {
        if let mainQueueCompletionBlock = mainQueueCompletionBlock {
            completionBlock = { [weak self] in
                guard let strelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    mainQueueCompletionBlock(strelf.output)
                    _retainedOperations.remove(strelf)
                }
            }
            _retainedOperations.insert(self)
        }
        
        let finalQueue = queue ?? preferredQueue
        finalQueue.addOperation(self)
        return self
    }
}

