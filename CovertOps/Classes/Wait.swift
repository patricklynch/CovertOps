import Foundation

/// An operation that pauses execution of the thread on which it is
/// executing until the `interval` elapses.  After that, the operation is
/// finishd and its completion block is called.
public final class Wait: QueueableOperation<Void> {
    
    public let interval: TimeInterval
    
    public init(interval: TimeInterval) {
        self.interval = interval
    }
    
    override public func main() {
        assert(!Thread.isMainThread)
        Thread.sleep(forTimeInterval: interval)
        super.main()
    }
}
