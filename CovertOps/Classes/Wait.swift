import Foundation

/// An operation that pauses execution of the thread on which it is
/// executing until the `interval` elapses.  After that, the operation is
/// finished and its completion block is called.
public final class Wait: QueueableOperation<Void> {
    
    private let shouldStop: (()->Bool)?
    
    private var startDate = Date()
    private let duration: TimeInterval
    
    public init(duration: TimeInterval) {
        self.duration = duration
        self.shouldStop = nil
    }
    
    public init(until shouldStop: @autoclosure @escaping ()->Bool, orDuration: TimeInterval? = nil) {
        self.duration = orDuration ?? TimeInterval.greatestFiniteMagnitude
        self.shouldStop = shouldStop
    }
    
    override public func main() {
        assert(!Thread.isMainThread)
        startDate = Date()
        while !isExpired && !isCancelled && !isFinished {
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
    
    private var isExpired: Bool {
        let currentDuration = abs(startDate.timeIntervalSinceNow)
        if currentDuration >= duration {
            return true
        } else if let shouldStop = shouldStop {
            return shouldStop()
        } else {
            return false
        }
    }
}
