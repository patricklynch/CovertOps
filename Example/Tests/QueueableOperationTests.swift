import XCTest
import CovertOps

class QueueableOperationTests: XCTestCase {
    
    let testQueue = OperationQueue()
    
    func testQueueOperation() {
        let expectation = XCTestExpectation(description: "QueueableOperation")
        let operation = ConvertToFloat(string: "1.0")
        operation.queue() { operationParam, output in
            XCTAssert(Thread.isMainThread)
            guard let output = output else {
                XCTFail()
                return
            }
            XCTAssertEqual(operation, operationParam)
            XCTAssertEqual(output, 1.0)
            expectation.fulfill()
        }
        XCTAssertEqual(testQueue.operations.count, 0)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testQueueWithQueue() {
        let expectation = XCTestExpectation(description: "QueueableOperation")
        ConvertToFloat(string: "1.4").queue(on: testQueue) { _, output in
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
        ConvertToInt(float: 0.01, providedPreferredQueue: testQueue).queue() { _, output in
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
        toFloat.queue() { _,_ in
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
    
    func testWillStartAndFinish() {
        let toFloat = ConvertToFloat(string: "1.4")
        let toInt = ConvertToInt(float: 1.4)
        toInt.addDependency(toFloat)
        
        let expectation = XCTestExpectation(description: "QueueableOperation")
        toInt.queue() { _,_ in
            XCTAssertEqual(toInt.operationWillStartCalledCount, 1)
            XCTAssertEqual(toInt.operationDidfinishCalledCount, 1)
            XCTAssertEqual(toInt.output, toInt.outputProvidedOnFinish)
            XCTAssertNotNil(toFloat.output)
            XCTAssertEqual(toFloat.output, toInt.outputFromDependency())
            
            XCTAssertEqual(toFloat.operationWillStartCalledCount, 1)
            XCTAssertEqual(toFloat.operationDidfinishCalledCount, 1)
            XCTAssertNotNil(toFloat.output)
            XCTAssertEqual(toFloat.output, toFloat.outputProvidedOnFinish)

            expectation.fulfill()
        }
        toFloat.queue()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testWillStartAndFinishArray() {
        let operations = [
            ConvertToFloat(string: "1.9"),
            ConvertToFloat(string: "2.8"),
            ConvertToFloat(string: "3.7"),
            ConvertToFloat(string: "4.6")
        ]
        
        let expectation = XCTestExpectation(description: "QueueableOperation")
        operations.queue() { operationsParam in
            XCTAssertEqual(operationsParam.count, operations.count)
            for op in operations {
                XCTAssertEqual(op.operationWillStartCalledCount, 1)
                XCTAssertEqual(op.operationDidfinishCalledCount, 1)
                XCTAssertNotNil(op.output)
                XCTAssertEqual(op.output, op.outputProvidedOnFinish)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}

class ConvertToFloat: SyncOperation<Float> {
    let string: String
    
    private(set) var operationWillStartCalledCount: Int = 0
    private(set) var operationDidfinishCalledCount: Int = 0
    private(set) var outputProvidedOnFinish: Float?
    
    init(string: String) {
        self.string = string
    }
    
    override func execute() -> Float? {
        return Float(string)
    }
    
    override func operationWillStart() {
        operationWillStartCalledCount += 1
    }
    
    override func operationDidFinish(output: Float?) {
        operationDidfinishCalledCount += 1
        outputProvidedOnFinish = output
    }
}

class ConvertToInt: SyncOperation<Int> {
    let float: Float
    let providedPreferredQueue: OperationQueue?
    
    private(set) var operationWillStartCalledCount: Int = 0
    private(set) var operationDidfinishCalledCount: Int = 0
    private(set) var outputProvidedOnFinish: Int?
    
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
    
    override func execute() -> Int? {
        return Int(float)
    }
    
    override func operationWillStart() {
        operationWillStartCalledCount += 1
    }
    
    override func operationDidFinish(output: Int?) {
        operationDidfinishCalledCount += 1
        outputProvidedOnFinish = output
    }
}

