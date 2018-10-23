import Foundation

public final class Async: AsyncOperation<Void> {
    
    let block: (Async) -> ()
    
    public init(block: @escaping (Async) -> ()) {
        self.block = block
    }
    
    override public func execute() {
        block(self)
    }
    
    func finish() {
        super.finish(output: nil)
    }
}

public final class AsyncMain: AsyncMainOperation<Void> {
    
    let block: (AsyncMain) -> ()
    
    public init(block: @escaping (AsyncMain) -> ()) {
        self.block = block
    }
    
    override public func execute() {
        block(self)
    }
    
    func finish() {
        super.finish(output: nil)
    }
}

public final class SyncMain: AsyncMainOperation<Void> {
    
    let block:(Operation)->()
    
    public init(block: @escaping (Operation)->()) {
        self.block = block
    }
    
    override public func execute() {
        finish(output: block(self))
    }
}

public final class Sync<OutputType>: QueueableOperation<OutputType> {
    
    let block: (Operation) -> (OutputType?)
    
    public init(block: @escaping (Operation) -> (OutputType?)) {
        self.block = block
    }
    
    override public func main() {
        self.output = block(self)
    }
}
