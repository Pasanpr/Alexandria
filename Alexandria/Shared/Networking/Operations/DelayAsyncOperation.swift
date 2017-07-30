//
//  DelayAsyncOperation.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/21/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation

class DelayAsyncOperation: AsynchronousOperation {
    private let delay: DispatchTimeInterval
    private let isDelayedAfter: Bool
    private let dispatchStartTime = DispatchTime.now()
    
    init(delay: Double, isDelayedAfter after: Bool) {
        self.delay = DispatchTimeInterval.milliseconds(Int(delay * 1000))
        self.isDelayedAfter = after
    }
    
    override func finish() {
        let deadline = isDelayedAfter ? DispatchTime.now() + delay : dispatchStartTime + delay
        
        DispatchQueue.global(qos: .default).asyncAfter(deadline: deadline) {
            self.state = .finished
        }
        
    }
}
