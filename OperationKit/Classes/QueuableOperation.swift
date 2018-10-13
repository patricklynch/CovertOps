import UIKit

private var _retainedOperations = Set<Operation>()

open class QueueableOperation<OutputType>: Operation {
    
    final public internal(set) var output: OutputType?
    
    /// Create an array of `Operation` instances to be be queued as dependants of (after) the receiver.
    /// Intended only for use by ovrriding in subclasses.  Default value is empty array and has no effect.
    func createDependants() -> [Operation] {
        return []
    }
    
    /// Create an array of `Operation` instances to be be queued as dependants of (after) the receiver.
    /// Intended only for use by ovrriding in subclasses.  Default value is empty array and has no effect.
    func createDependencies() -> [Operation] {
        return []
    }
    
    override public init() {
        super.init()
        
        for operation in createDependencies() {
            self.after(operation)
            OperationQueue.default.addOperation(operation)
        }
        
        for operation in createDependants() {
            self.before(operation)
            OperationQueue.default.addOperation(operation)
        }
    }
    
    private var dependenciesHashMap = NSHashTable<Operation>(options: [.weakMemory])
    private var dependentsHashMap = NSHashTable<Operation>(options: [.weakMemory])
    
    final var dependents: [Operation] {
        return dependentsHashMap.allObjects
    }
    
    func valueFromDependency<T>() -> T? {
        let typedDependencies = dependencies.compactMap { $0 as? QueueableOperation<T> }
        guard !typedDependencies.isEmpty else { return nil }
        return typedDependencies.compactMap { $0.output }.first
    }
    
    func typedDependency<DependencyType>() -> DependencyType? {
        return dependencies.compactMap { $0 as? DependencyType }.first
    }
    
    @discardableResult
    func then<T>(_ nextOperation: QueueableOperation<T>, mainQueueCompletionBlock: ((T?)->())? = nil) -> QueueableOperation<OutputType> {
        nextOperation.addDependency(self)
        nextOperation.queue(mainQueueCompletionBlock: mainQueueCompletionBlock)
        return self
    }
    
    @discardableResult
    func then(_ mainQueueCompletionBlock: @escaping (QueueableOperation<OutputType>, OutputType?)->()) -> QueueableOperation<OutputType> {
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
    func before(_ dependant: Operation) -> QueueableOperation<OutputType> {
        dependant.addDependency(self)
        return self
    }
    
    @discardableResult
    func after(_ dependency: Operation) -> QueueableOperation<OutputType> {
        addDependency(dependency)
        return self
    }
    
    /// Subclasses may override to specify a queue that they would like to use.
    /// The default return value is `OperationQueue.default`
    var preferredQueue: OperationQueue {
        return OperationQueue.default
    }
    
    @discardableResult
    open func queue(
        on queue: OperationQueue? = nil,
        before dependant: Operation? = nil,
        after dependency: Operation? = nil,
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
        if let dependency = dependency {
            self.after(dependency)
        }
        if let dependant = dependant {
            self.before(dependant)
        }
        
        let finalQueue = queue ?? preferredQueue
        finalQueue.addOperation(self)
        return self
    }
    
    override open func addDependency(_ op: Operation) {
        super.addDependency(op)
        
        if let queueableOperation = op as? QueueableOperation {
            queueableOperation.dependentsHashMap.add(self)
        }
        dependenciesHashMap.add(op)
    }
}

