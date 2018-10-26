import XCTest
import CovertOps

class ObserveTests: XCTestCase {
    
    var property: Bool = false
    var expectedValue: Bool = false
    var updateCount: Int = 0
    var expectedUpdateCount: Int = 0
    var shouldEnd: Bool = false
    
    override func setUp() {
        super.setUp()
        
        property = false
        expectedValue = false
        updateCount = 0
        expectedUpdateCount = 0
        shouldEnd = false
    }
    
    func testChangingValue() {
        let expectation = XCTestExpectation(description: "")
        
        let observer = Observe(self.property).start { _, value in
            XCTAssertEqual(value, self.expectedValue)
            self.updateCount += 1
        }
        let operations = [
            Wait(duration: 0.1),
            SyncMain { _ in
                self.expectedUpdateCount += 1
                self.expectedValue = true
                self.property = true
            },
            Wait(duration: 0.1),
            SyncMain { _ in
                self.expectedValue = true
                self.property = true
            },
            Wait(duration: 0.1),
            SyncMain { _ in
                self.expectedUpdateCount += 1
                self.expectedValue = false
                self.property = false
            },
            Wait(duration: 0.1),
            SyncMain { _ in
                self.expectedValue = false
                self.property = false
            },
            Wait(duration: 0.1),
            SyncMain { _ in
                self.expectedUpdateCount += 1
                self.expectedValue = true
                self.property = true
            },
            Wait(duration: 0.1)
        ]
        operations.chained().queue() { _ in
            DispatchQueue.main.async {
                self.property = false
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(self.updateCount, self.expectedUpdateCount)
        observer.cancel()
    }
    
    func testConditionalStop() {
        let expectation = XCTestExpectation(description: "")
        
        property = false
        let observer = Observe(self.property).until(self.shouldEnd).start { _, value in
            XCTAssertEqual(value, self.expectedValue)
            self.updateCount += 1
        }
        let operations = [
            Wait(duration: 0.1),
            SyncMain { _ in
                self.expectedUpdateCount += 1
                self.expectedValue = true
                self.property = true
            },
            Wait(duration: 0.1),
            SyncMain { _ in
                self.shouldEnd = true
            },
            Wait(duration: 0.1),
            SyncMain { _ in
                self.expectedValue = false
                self.property = false
            }
        ]
        operations.chained().queue() { _ in
            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(self.updateCount, self.expectedUpdateCount)
        observer.cancel()
    }
}
