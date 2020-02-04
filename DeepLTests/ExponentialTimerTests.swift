/*
 Copyright (c) 2015-2019 Spotify AB.
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
   http://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

// https://github.com/spotify/SPTDataLoader/blob/master/Tests/SPTDataLoaderExponentialTimerTest.m

@testable import DeepL

import XCTest

class ExponentialTimerTests: XCTestCase {
    var timer: ExponentialTimer?

    override func setUp() {
        super.setUp()
        timer = ExponentialTimer(initialTime: 1, maxTime: 10)
    }

    func testReset() {
        var currentTimerInterval = 0.0
        for _ in 0 ..< 3 {
            currentTimerInterval = timer!.timeIntervalAndCalculateNext()
        }
        XCTAssertGreaterThan(currentTimerInterval, 0.0)
        timer?.reset()
        XCTAssertEqual(timer!.timeInterval, 1.0, accuracy: .ulpOfOne)
    }

    func testInitialTimeOfZeroResultsInZeroAlways() {
        timer = ExponentialTimer(initialTime: 0, maxTime: 10, jitter: 0)
        var currentTimerInterval = 0.0
        for _ in 0 ..< 10 {
            currentTimerInterval = timer!.timeIntervalAndCalculateNext()
        }
        XCTAssertEqual(currentTimerInterval, 0.0, accuracy: .ulpOfOne)
    }

    func testMaxTimeReached() {
        var currentTimerInterval = 0.0
        for _ in 0 ..< 100 {
            currentTimerInterval = timer!.timeIntervalAndCalculateNext()
        }
        XCTAssertLessThanOrEqual(currentTimerInterval, 10.0)
    }
}
