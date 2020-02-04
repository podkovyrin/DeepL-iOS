//
//  Created by Andrew Podkovyrin
//  Copyright © 2020 Andrew Podkovyrin. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

final class NetworkActivityIndicator {
    private let updateDelay: TimeInterval = 0.17
    private let queue = DispatchQueue(label: "com.deepl.network-activity-indicator")
    private var timer: Timer?
    private var _activityCount: Int = 0
    private var activityCount: Int {
        get {
            queue.sync {
                _activityCount
            }
        }
        set {
            queue.sync {
                _activityCount = newValue
            }
        }
    }

    private var isActivityIndicatorVisible: Bool {
        activityCount > 0
    }

    func incrementActivityCount() {
        activityCount += 1

        updateNetworkActivityIndicatorVisibilityDelayed()
    }

    func decrementActivityCount() {
        activityCount = max(activityCount - 1, 0)

        updateNetworkActivityIndicatorVisibilityDelayed()
    }

    // MARK: Private

    private func updateNetworkActivityIndicatorVisibilityDelayed() {
        if isActivityIndicatorVisible {
            DispatchQueue.main.async {
                self.updateNetworkActivityIndicatorVisibility()
            }
        }
        else {
            timer?.invalidate()
            let timer = Timer(timeInterval: updateDelay,
                              target: self,
                              selector: #selector(updateNetworkActivityIndicatorVisibility),
                              userInfo: nil,
                              repeats: false)
            self.timer = timer
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    @objc
    private func updateNetworkActivityIndicatorVisibility() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = isActivityIndicatorVisible
    }
}
