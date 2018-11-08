import UIKit

public protocol ExclusiveHashable {
    var exclusiveHashValue: Int { get }
}

var retainedOperations = Set<Operation>()
var exclusiveOperations = NSHashTable<Operation>(options: [.weakMemory])

open class QueueableOperation<OutputType>: Operation {
    
    private var didSetOutput = false
    final public var output: OutputType? {
        didSet {
            guard !didSetOutput else { return }
            didSetOutput = true
            
            operationDidFinish(output: output)
        }
    }
    
    private func existingExclusiveOperation() -> QueueableOperation<OutputType>? {
        guard let operation = exclusiveOperations.allObjects.first(where: { type(of: $0) == type(of: self) }) else {
            return nil
        }
        if let exclusiveOperation = operation as? ExclusiveHashable,
            let exclusiveSelf = self as? ExclusiveHashable {
            if exclusiveOperation.exclusiveHashValue == exclusiveSelf.exclusiveHashValue {
                return self
            } else {
                return nil
            }
        } else {
            return operation as? QueueableOperation<OutputType>
        }
    }
    
    public final func exclusive() -> QueueableOperation {
        if let existingOperation = existingExclusiveOperation(),
            !existingOperation.isCancelled,
            !existingOperation.isFinished {
            return existingOperation
        } else {
            exclusiveOperations.add(self)
            return self
        }
    }
    
    public final func outputFromDependency<T>() -> T? {
        let typedDependencies = dependencies.compactMap { $0 as? QueueableOperation<T> }
        guard !typedDependencies.isEmpty else { return nil }
        return typedDependencies.compactMap { $0.output }.first
    }
    
    public final func typedDependency<DependencyType>() -> DependencyType? {
        return dependencies.compactMap { $0 as? DependencyType }.first
    }
    
    @discardableResult
    public final func then(_ mainQueueCompletionBlock: ((QueueableOperation<OutputType>, OutputType?)->())?) -> QueueableOperation<OutputType> {
        retainedOperations.insert(self)
        let existingCompletionBlock = completionBlock
        completionBlock = { [weak self] in
            guard let self = self else { return }
            existingCompletionBlock?()
            DispatchQueue.main.async {
                mainQueueCompletionBlock?(self, self.output)
                retainedOperations.remove(self)
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
    public final func before(_ dependants: [Operation]) -> QueueableOperation<OutputType> {
        for dependant in dependants {
            dependant.addDependency(self)
        }
        return self
    }
    
    @discardableResult
    public final func after(_ dependency: Operation) -> QueueableOperation<OutputType> {
        addDependency(dependency)
        return self
    }
    
    @discardableResult
    public final func after(_ dependencies: [Operation]) -> QueueableOperation<OutputType> {
        for dependency in dependencies {
            addDependency(dependency)
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
        mainQueueCompletionBlock: ((QueueableOperation<OutputType>, OutputType?)->())? = nil) -> QueueableOperation<OutputType> {
        
        let finalQueue = queue ?? preferredQueue
        if let existingOperation = existingExclusiveOperation() {
            if !existingOperation.isExecuting && !existingOperation.isCancelled && !existingOperation.isFinished {
                finalQueue.addOperation(existingOperation)
            }
            existingOperation.then(mainQueueCompletionBlock)
        } else {
            then(mainQueueCompletionBlock)
            operationWillStart()
            finalQueue.addOperation(self)
        }
        return self
    }
    
    open func operationWillStart() { }
    
    open func operationDidFinish(output: OutputType?) { }
}

