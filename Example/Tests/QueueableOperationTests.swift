import XCTest
import CovertOps

class QueueableOperationTests: XCTestCase {
    
    let testQueue = OperationQueue()
    
    func testQueueOperation() {
        let expectation = XCTestExpectation(description: "QueueableOperation")
        ConvertToFloat(string: "1.0").queue() { output in
            XCTAssert(Thread.isMainThread)
            guard let output = output else {
                XCTFail()
                return
            }
            XCTAssertEqual(output, 1.0)
            expectation.fulfill()
        }
        XCTAssertEqual(testQueue.operations.count, 0)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testQueueWithQueue() {
        let expectation = XCTestExpectation(description: "QueueableOperation")
        ConvertToFloat(string: "1.4").queue(on: testQueue) { output in
            XCTAssert(Thread.isMainThread)
            guard let output = output else {
                XCTFail()
                return
            }
            XCTAssertEqual(output, 1.4)
            expectation.fulfill()
        }
        XCTAssertEqual(testQueue.operations.count, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPreferredQueue() {
        let expectation = XCTestExpectation(description: "QueueableOperation")
        ConvertToInt(float: 0.01, providedPreferredQueue: testQueue).queue() { output in
            XCTAssert(Thread.isMainThread)
            guard let output = output else {
                XCTFail()
                return
            }
            XCTAssertEqual(output, 0)
            expectation.fulfill()
        }
        XCTAssertEqual(testQueue.operations.count, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetDependencies() {
        let toFloat = ConvertToFloat(string: "1.4")
        let toInt = ConvertToInt(float: 0.01)
        toInt.addDependency(toFloat)
        
        let expectation = XCTestExpectation(description: "QueueableOperation")
        toFloat.queue() { _ in
            guard let _: ConvertToFloat = toInt.typedDependency() else {
                XCTFail()
                return
            }
            guard let _: Float = toInt.outputFromDependency() else {
                XCTFail()
                return
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}

class ConvertToFloat: QueueableOperation<Float> {
    let string: String
    
    init(string: String) {
        self.string = string
    }
    
    override func main() {
        output = Float(string)
    }
}

class ConvertToInt: QueueableOperation<Int> {
    let float: Float
    let providedPreferredQueue: OperationQueue?
    
    init(float: Float, providedPreferredQueue: OperationQueue? = nil) {
        self.float = float
        self.providedPreferredQueue = providedPreferredQueue
    }
    
    override var preferredQueue: OperationQueue {
        if let queue = providedPreferredQueue {
            return queue
        } else {
            return super.preferredQueue
        }
    }
    
    override func main() {
        output = Int(float)
    }
}
