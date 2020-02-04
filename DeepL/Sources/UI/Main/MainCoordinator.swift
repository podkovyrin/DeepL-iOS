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

import ANOperations
import UIKit

extension MainViewController: LanguageSelectionTarget {}

final class MainCoordinator: Coordinating {
    var primaryViewController: UIViewController { bouncingController }

    private let router: AppRouter
    private let services: Services

    private let mainController: MainViewController
    private let keyboardController: KeyboardViewController
    private let bouncingController: BouncingViewController

    private let operationQueue: OperationQueue
    private let inputDebouncer: Debouncer
    private let languageSelector: LanguageSelector
    private weak var translateOperation: Operation?
    private var translation: Translation?

    init(router: AppRouter, services: Services, operationQueue: OperationQueue) {
        self.router = router
        self.services = services
        self.operationQueue = operationQueue

        mainController = MainViewController()
        mainController.maxSourceCharacters = services.configuration.maxSourceTextCharacters
        keyboardController = KeyboardViewController(contentController: mainController)
        bouncingController = BouncingViewController(contentController: keyboardController)

        let delay = UIAccessibility.isVoiceOverRunning
            ? services.configuration.textInputDelayVoiceOver
            : services.configuration.textInputDelay
        inputDebouncer = Debouncer(delay: delay)

        languageSelector = LanguageSelector(router: router,
                                            userDefaults: services.userDefaults,
                                            storage: services.languageStorage,
                                            target: mainController)

        mainController.delegate = self
    }

    func start() {
        updateLanguages()

        router.showViewController(primaryViewController)
    }

    func updateLanguages() {
        languageSelector.resetLanguages()
        mainController.sourcePlaceholderBuilder = services.languageStorage.sourcePlaceholderBuilder
    }

    // MARK: Private

    private func performTranslation(text: String?, initiatedByUserInput: Bool) {
        guard let text = text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            translateOperation?.cancel()
            inputDebouncer.cancel()
            mainController.targetText = nil
            return
        }

        if initiatedByUserInput {
            inputDebouncer.action = { [weak self] in
                guard let self = self else { return }
                self.translate(text: text)
            }
        }
        else {
            translate(text: text)
        }
    }

    private func translate(text: String) {
        translateOperation?.cancel()

        // can't translate until languages are fetched for the very first app start
        guard let target = mainController.targetLanguage else { return }

        let source: Language?
        if mainController.sourceLanguage != languageSelector.anyLanguage {
            source = mainController.sourceLanguage
        }
        else {
            source = nil
        }

        mainController.startTargetTextViewAnimating()
        UIAccessibility.post(notification: .announcement,
                             argument: NSLocalizedString("Translating", comment: ""))

        let operation = TranslationOperation(text: text, source: source, target: target, services: services)
        operation.addCompletionObserver { [weak self] operation, _ in
            guard let self = self, !operation.isCancelled else { return }

            guard let translation = operation.translation else {
                preconditionFailure("Inconsistent state")
            }

            let mainController = self.mainController

            self.translation = translation
            mainController.targetText = translation.attributedText

            if let source = translation.source {
                let detected = mainController.sourceLanguage != source
                mainController.setSourceLanguage(source, detected: detected)
            }

            UIAccessibility.post(notification: .announcement,
                                 argument: NSLocalizedString("Translation complete", comment: ""))
        }
        operationQueue.addOperation(operation)
        translateOperation = operation
    }
}

extension MainCoordinator: MainViewControllerDelegate {
    func sourceTextDidChange(text: String?) {
        performTranslation(text: text, initiatedByUserInput: true)
    }

    func showSourceLanguageSelector(sender: UIButton) {
        languageSelector.showSourceLanguageSelector(sender: sender) { result in
            guard result == .updated else { return }

            self.performTranslation(text: self.mainController.sourceText, initiatedByUserInput: false)
        }
    }

    func showTargetLanguageSelector(sender: UIButton) {
        languageSelector.showTargetLanguageSelector(sender: sender) { result in
            guard result == .updated else { return }

            self.performTranslation(text: self.mainController.sourceText, initiatedByUserInput: false)
        }
    }

    func handle(url: URL) -> Bool {
        let urlString = url.absoluteString
        if urlString == NetworkErrorClassificationURL.retriable {
            // Currently, since text to translation is truncated to 5000 characters,
            // GroupTranslationOperation should not produce any children
            // because it's below the documented request size limit of 30 Kbytes.
            // There is no need in retrying failed chunks of the whole text, though it's possible.
            performTranslation(text: mainController.sourceText, initiatedByUserInput: false)
            return true
        }
        else if urlString == NetworkErrorClassificationURL.unrecoverable {
            // NOP
            return true
        }
        return false
    }

    func shareTargetTextAction(text: String, sender: UIBarButtonItem) {
        let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            let presentationController = controller.popoverPresentationController
            presentationController?.barButtonItem = sender
        }
        router.showViewController(controller)
    }
}
