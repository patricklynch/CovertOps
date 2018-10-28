import Foundation

open class SyncOperation<OutputType>: QueueableOperation<OutputType> {
    
    open func execute() -> OutputType? {
        assertionFailure("Please implement this method in a subclass.")
        return nil
    }
    
    override open func main() {
        output = execute()
    }
}

open class AsyncOperation<OutputType>: QueueableOperation<OutputType> {
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    open func createPrecompletionDependants() -> [Operation] {
        return []
    }
    
    open func execute() {
        assertionFailure("Please implement this method in a subclass.")
    }
    
    override open func main() {
        guard !isCancelled && !isFinished else {
            return
        }
        execute()
        wait()
    }
    
    final func wait() {
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    public final func finish(output: OutputType? = nil) {
        self.output = output
        
        let precompletionDependants = createPrecompletionDependants()
        precompletionDependants.queue() { _ in
            self.semaphore.signal()
        }
    }
    
    override open func cancel() {
        super.cancel()
        finish(output: nil)
    }
}

open class AsyncMainOperation<OutputType>: AsyncOperation<OutputType> {
    
    override open func main() {
        guard !isCancelled && !isFinished else {
            return
        }
        DispatchQueue.main.async() {
            self.execute()
        }
        wait()
    }
}
