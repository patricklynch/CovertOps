import Foundation

private var _debugObserverCount = 0

/// An operation that uses a repeating interval so observe changes in a value,
/// thereby creating an active binding.
public final class Observe<T: Equatable>: QueueableOperation<Void> {
    
    private var update: ((T, T)->())!
    private let read: (()->T)
    private var shouldStop: (()->Bool)?
    
    private var currentValue: T
    private let interval: TimeInterval?
    let minInterval: TimeInterval = 0.1
    
    /// - Parameters:
    ///   - interval: rate at which to check for changes in output of `read`
    ///   - read: closure called at rate of `interval` that returns the value
    ///     that is being observed for changes
    public init(interval: TimeInterval? = nil, _ read: @autoclosure @escaping ()->T) {
        self.read = read
        self.interval = interval
        self.currentValue = read()
    }
    
    /// Allows callers to create a condition for when observation should cease and
    /// the operation should be removed from the queue and released.
    ///
    /// - Parameter shouldStop: Called on every interval, the return value
    ///   of which determines if observation should cease and the operation should finish
    /// - Returns: itself, for functional-style chaining.
    @discardableResult
    public func until(_ shouldStop: @autoclosure @escaping ()->Bool) -> Observe<T> {
        self.shouldStop = shouldStop
        return self
    }
    
    /// Begins observation.
    ///
    /// - Parameter update: Called on every interval, returns the value to be
    ///   observed for changes.
    /// - Returns: itself, for functional-style chaining.
    @discardableResult
    public func start(update: @escaping (T, T)->()) -> Observe<T> {
        self.update = update
        super.queue()
        onInterval()
        _debugObserverCount += 1
        return self
    }
    
    /// Ceases observation and removes the operation the queue
    /// to be released thereafter unless retained elsewhere.
    func stop() {
        cancel()
    }
    
    override public func cancel() {
        super.cancel()
        _debugObserverCount -= 1
    }
    
    override public func main() {
        assert(!Thread.isMainThread)
        
        while shouldStop?() != true && !isCancelled && !isFinished {
            let interval = max(self.interval ?? minInterval, minInterval)
            Thread.sleep(forTimeInterval: interval)
            DispatchQueue.main.async {
                self.onInterval()
            }
        }
    }
    
    private func onInterval() {
        let lastValue = currentValue
        let nextValue = read()
        if lastValue != nextValue {
            update(nextValue, lastValue)
        }
        currentValue = nextValue
    }
}
