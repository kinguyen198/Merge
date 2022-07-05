//
// Copyright (c) Vatsal Manot
//

@testable import Merge

import Swallow
import XCTest

final class ObservableTaskTests: XCTestCase {
    func testTaskSuccessCompletion() {
        let task = PassthroughTask<Int, EmptyError>()
        
        task.send(status: .success(0))
        
        XCTAssert(task.successPublisher.subscribeAndWaitUntilDone() == .success(0))
    }
    
    func testTaskFailureCompletion() {
        let task = PassthroughTask<Void, Error>()
        
        task.send(status: .canceled)
        
        _ = task.successPublisher.reduceAndMapTo(()).subscribeAndWaitUntilDone()
    }
    
    func testTaskMap() {
        let task = PassthroughTask<Int, Never>()
        
        task.send(status: .success(0))
        
        XCTAssert(task.map({ $0 + 1 }).successPublisher.subscribeAndWaitUntilDone() == .success(1))
    }
}
