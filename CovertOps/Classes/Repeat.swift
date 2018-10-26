import Foundation

/// An operation the repeatedly calls the provided `block` at the provided
/// `interval` until it is stopped.  This can be don directly by calling `stop()`
/// or `cancel()`, or providing a condition using `until(_:)`.
public class Repeat: QueueableOperation<Void> {
    private var timer: Timer?
    private let block: ()->()
    private var shouldStop: (()->Bool)?
    
    private var startDate = Date()
    private var duration: TimeInterval?
    private let interval: TimeInterval?
    let minInterval: TimeInterval = 0.1
    
    public init(interval: TimeInterval? = nil, duration: TimeInterval? = nil, block: @escaping ()->()) {
        self.block = block
        self.duration = duration
        self.interval = interval
    }
    
    /// Provides the execution operation with a way of checking on each interval
    /// whether or not it should stop executing.
    ///
    /// - Parameter shouldStop: An autoclosure that returns a boolean incidicating
    ///   whether the operation should stop executing.
    /// - Returns: itself for functional-style chaining
    @discardableResult
    public  func until(_ shouldStop: @autoclosure @escaping ()->Bool) -> Operation {
        self.shouldStop = shouldStop
        return self
    }
    
    override public func main() {
        assert(!Thread.isMainThread)
        startDate = Date()
        while !isExpired && !isCancelled && !isFinished {
            let interval = max(self.interval ?? minInterval, minInterval)
            Thread.sleep(forTimeInterval: interval)
            DispatchQueue.main.async {
                self.block()
            }
        }
    }
    
    private var isExpired: Bool {
        if let duration = self.duration {
            let currentDuration = abs(startDate.timeIntervalSinceNow)
            if currentDuration >= duration {
                return true
            }
        }
        if let shouldStop = shouldStop {
            return shouldStop()
        } else {
            return false
        }
    }
}
