import Foundation

class AsyncMain: AsyncMainOperation<Void> {
    
    let block: (AsyncMain) -> ()
    
    init(block: @escaping (AsyncMain) -> ()) {
        self.block = block
    }
    
    override func execute() {
        block(self)
    }
    
    func finish() {
        super.finish(output: nil)
    }
}

class SyncMain: AsyncMainOperation<Void> {
    
    let block:(Operation)->()
    
    init(block: @escaping (Operation)->()) {
        self.block = block
    }
    
    override func execute() {
        finish(output: block(self))
    }
}

class Sync<OutputType>: QueueableOperation<OutputType> {
    
    let block: (Operation) -> (OutputType?)
    
    init(block: @escaping (Operation) -> (OutputType?)) {
        self.block = block
    }
    
    override func main() {
        self.output = block(self)
    }
}
