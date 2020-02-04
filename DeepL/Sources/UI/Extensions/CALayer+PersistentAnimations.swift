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

// Based on https://gist.github.com/matej/9639064

import UIKit

extension CALayer {
    private static var persistentHelperKey = "CALayer.LayerAnimationsPersistentHelper"

    func makeAnimationsPersistent() {
        var object = objc_getAssociatedObject(self, &CALayer.persistentHelperKey)
        if object == nil {
            object = LayerAnimationsPersistentHelper(layer: self)
            let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            objc_setAssociatedObject(self, &CALayer.persistentHelperKey, object, nonatomic)
        }
    }
}

/// Pause animations of layer tree
/// https://developer.apple.com/library/content/qa/qa1673/_index.html#//apple_ref/doc/uid/DTS40010053
private extension CALayer {
    func pauseAnimations() {
        let isAnimationsPaused = speed == 0.0
        if !isAnimationsPaused {
            let currentTime = CACurrentMediaTime()
            let pausedTime = convertTime(currentTime, from: nil)
            speed = 0.0
            timeOffset = pausedTime
        }
    }

    func resumeAnimations() {
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let currentTime = CACurrentMediaTime()
        let timeSincePause = convertTime(currentTime, from: nil) - pausedTime
        beginTime = timeSincePause
    }
}

private class LayerAnimationsPersistentHelper {
    private var persistentAnimations: [String: CAAnimation] = [:]
    private var persistentSpeed: Float = 0.0
    private weak var layer: CALayer?

    init(layer: CALayer) {
        self.layer = layer

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(applicationWillEnterForegroundNotification),
                                       name: UIApplication.willEnterForegroundNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(applicationDidEnterBackgroundNotification),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func persistAnimations(with keys: [String]?) {
        guard let layer = self.layer else { return }
        keys?.forEach { key in
            if let animation = layer.animation(forKey: key) {
                persistentAnimations[key] = animation
            }
        }
    }

    private func restoreAnimations(with keys: [String]?) {
        guard let layer = self.layer else { return }
        keys?.forEach { key in
            if let animation = persistentAnimations[key] {
                layer.add(animation, forKey: key)
            }
        }
    }

    @objc
    private func applicationWillEnterForegroundNotification() {
        guard let layer = self.layer else { return }
        restoreAnimations(with: Array(persistentAnimations.keys))
        persistentAnimations.removeAll()
        if persistentSpeed == 1.0 { // if layer was playing before background, resume it
            layer.resumeAnimations()
        }
    }

    @objc
    private func applicationDidEnterBackgroundNotification() {
        guard let layer = self.layer else { return }
        persistentSpeed = layer.speed
        layer.speed = 1.0 // in case layer was paused from outside, set speed to 1.0 to get all animations
        persistAnimations(with: layer.animationKeys())
        layer.speed = persistentSpeed // restore original speed
        layer.pauseAnimations()
    }
}
