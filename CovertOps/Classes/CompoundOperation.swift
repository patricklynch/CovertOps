import Foundation

/// An operation that executes an array of child operations.  This is useful
/// for giving single operation semantics to a group of operations.
open class CompoundOperation: AsyncOperation<Void> {
    
    public let operations: [Operation]
    
    public init(from operations: [Operation]) {
        self.operations = operations
    }
    
    override open var dependencies: [Operation] {
        return super.dependencies + operations
    }
    
    override open func execute() {
        operations.queue() { _ in
            self.finish(output: nil)
        }
    }
    
    override open func cancel() {
        super.cancel()
        
        for suboperation in operations {
            suboperation.cancel()
        }
    }
}

