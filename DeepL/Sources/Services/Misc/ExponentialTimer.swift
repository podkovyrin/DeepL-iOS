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

// https://github.com/spotify/SPTDataLoader/blob/master/Sources/SPTDataLoaderExponentialTimer.m

import Foundation

final class ExponentialTimer {
    /// The current delay time interval.
    private(set) var timeInterval: TimeInterval

    private let maxTime: TimeInterval
    private let initialTime: TimeInterval
    private let jitter: Double
    private let growFactor = M_E

    init(initialTime: TimeInterval, maxTime: TimeInterval, jitter: Double = 0.11304999836) {
        timeInterval = initialTime
        self.initialTime = initialTime
        self.maxTime = maxTime
        self.jitter = jitter
    }

    func reset() {
        timeInterval = initialTime
    }

    @discardableResult
    func calculateNext() -> TimeInterval {
        var nextTime = timeInterval * growFactor

        if nextTime > maxTime {
            nextTime = maxTime
        }

        if jitter < 0.0001 {
            timeInterval = nextTime
        }
        else {
            let sigma = jitter * nextTime
            timeInterval = ExponentialTimer.normalWithMu(nextTime, sigma: sigma)
        }

        if timeInterval > maxTime {
            timeInterval = maxTime
        }

        return timeInterval
    }

    func timeIntervalAndCalculateNext() -> TimeInterval {
        let ti = timeInterval
        calculateNext()
        return ti
    }

    // MARK: Private

    private static let EXPT_MODULO = UInt32.max
    private static let EXPT_MODULO_F64 = Double(EXPT_MODULO)

    private static func exptRandom() -> Double {
        Double(arc4random_uniform(EXPT_MODULO))
    }

    private static func normalWithMu(_ mu: Double, sigma: Double) -> TimeInterval {
        /**
         Uses Kinderman and Monahan method. Reference: Kinderman,
         A.J. and Monahan, J.F., "Computer generation of random
         variables using the ratio of uniform deviates", ACM Trans
         Math Software, 3, (1977), pp257-260.
         */

        let attempts = 20
        for _ in 0 ..< attempts {
            let a = exptRandom() / EXPT_MODULO_F64
            let b = 1.0 - (exptRandom() / EXPT_MODULO_F64)
            let c = 1.7155277699214135 * (a - 0.5) / b
            let d = c * c / 4.0

            if d <= -1.0 * log(b) {
                return mu + c * sigma
            }
        }

        return mu + 2.0 * sigma * (exptRandom() / EXPT_MODULO_F64)
    }
}
