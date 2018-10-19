import Foundation

/// An operation that uses a repeating interval so observe changes in a value.
public final class Observe<T: Equatable>: QueueableOperation<Void> {
    
    private var update: ((Observe<T>, T)->())!
    private let read: (()->T)
    private var shouldStop: (()->Bool)?
    
    private var currentValue: T?
    private let interval: TimeInterval?
    let minInterval: TimeInterval = 0.02
    
    /// - Parameters:
    ///   - interval: rate at which to check for changes in output of `read`
    ///   - read: closure called at rate of `interval` that returns the value
    ///     that is being observed for changes
    public init(interval: TimeInterval? = nil, _ read: @autoclosure @escaping ()->T) {
        self.read = read
        self.interval = interval
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
    /// - Parameter update: Called on every interval, returns the value being observed for changes.
    /// - Returns: itself, for functional-style chaining.
    @discardableResult
    public func start(update: @escaping (Observe<T>, T)->()) -> Observe<T> {
        self.update = update
        super.queue()
        return self
    }
    
    /// Ceases observation and removes the operation from the queue,
    /// thereafter to be released unless retained elsewhere.
    public func stop() {
        cancel()
    }
    
    override public func main() {
        assert(!Thread.isMainThread)
        
        while shouldStop?() != true && !isCancelled && !isFinished {
            let interval = max(self.interval ?? minInterval, minInterval)
            Thread.sleep(forTimeInterval: interval)
            DispatchQueue.main.async { [weak self] in
                self?.onInterval()
            }
        }
    }
    
    /// Forces a call to the `update` closure provided when calling `start`.  This is particularly
    /// useful to ensure that the observer's `update` method is called at least once, such as
    /// immeidately after creating and starting an `Observe`.
    @discardableResult
    public func trigger() -> Observe<T> {
        DispatchQueue.main.async { [weak self] in
            self?.onInterval(force: true)
        }
        return self
    }
    
    private func onInterval(force: Bool = false) {
        guard !isCancelled && !isFinished else { return }
        let nextValue = read()
        if force {
            update(self, nextValue)
            
        } else if let lastValue = currentValue, lastValue != nextValue {
            update(self, nextValue)
        }
        currentValue = nextValue
    }
}
