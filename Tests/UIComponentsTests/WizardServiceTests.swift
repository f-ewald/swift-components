//
//  WizardServiceTests.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 8/24/26.
//

import Foundation
import Testing
@testable import UIComponents

/// Builds a temp-directory `Bundle` containing a `wizard.json`, so `WizardService`
/// can be exercised without depending on `Bundle.main` or `Package.swift` resources.
private func makeWizardBundle(json: String) -> Bundle {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let fileURL = directory.appendingPathComponent("wizard.json")
    try! json.write(to: fileURL, atomically: true, encoding: .utf8)
    return Bundle(url: directory)!
}

private let lastSeenVersionKey = "lastSeenAppVersion"

/// Runs `body` with a clean `lastSeenAppVersion` state, restoring whatever was
/// there before so tests never leak `UserDefaults` state into each other.
private func withIsolatedLastSeenVersion(_ lastSeen: String?, _ body: () -> Void) {
    let previous = UserDefaults.standard.string(forKey: lastSeenVersionKey)
    defer {
        if let previous {
            UserDefaults.standard.set(previous, forKey: lastSeenVersionKey)
        } else {
            UserDefaults.standard.removeObject(forKey: lastSeenVersionKey)
        }
    }
    if let lastSeen {
        UserDefaults.standard.set(lastSeen, forKey: lastSeenVersionKey)
    } else {
        UserDefaults.standard.removeObject(forKey: lastSeenVersionKey)
    }
    body()
}

// Serialized: these tests share the real UserDefaults.standard `lastSeenAppVersion`
// key (that's WizardService's actual, non-injectable storage), so they must not
// run concurrently with each other.
@Suite(.serialized)
struct WizardServiceTests {
    @Test func loadStepsReturnsEmptyWhenAllStepsAtOrBelowLastSeen() async throws {
        withIsolatedLastSeenVersion("1.0.0") {
            let bundle = makeWizardBundle(json: """
            { "steps": [
                { "title": "A", "subtitle": "a", "imageName": null, "buttonLabel": "OK", "version": "0.5.0" },
                { "title": "B", "subtitle": "b", "imageName": null, "buttonLabel": "OK", "version": "1.0.0" }
            ] }
            """)
            #expect(WizardService.loadSteps(bundle: bundle).isEmpty)
        }
    }

    @Test func loadStepsReturnsAllStepsOnFreshInstall() async throws {
        withIsolatedLastSeenVersion(nil) {
            let bundle = makeWizardBundle(json: """
            { "steps": [
                { "title": "A", "subtitle": "a", "imageName": null, "buttonLabel": "OK", "version": "0.5.0" },
                { "title": "B", "subtitle": "b", "imageName": null, "buttonLabel": "OK", "version": "1.0.0" }
            ] }
            """)
            #expect(WizardService.loadSteps(bundle: bundle).count == 2)
        }
    }

    @Test func loadStepsExcludesStepAtExactlyLastSeenVersion() async throws {
        // Locks in the `>` fix: a step at exactly lastSeenAppVersion has already been seen.
        withIsolatedLastSeenVersion("1.0.0") {
            let bundle = makeWizardBundle(json: """
            { "steps": [
                { "title": "A", "subtitle": "a", "imageName": null, "buttonLabel": "OK", "version": "1.0.0" }
            ] }
            """)
            #expect(WizardService.loadSteps(bundle: bundle).isEmpty)
        }
    }

    @Test func loadStepsExcludesStepAboveCurrentAppVersion() async throws {
        // Locks in the upper-bound fix. `swift test`'s Bundle.main has no
        // CFBundleShortVersionString, so WizardService falls back to current version 1.0.0.
        withIsolatedLastSeenVersion("0.5.0") {
            let bundle = makeWizardBundle(json: """
            { "steps": [
                { "title": "A", "subtitle": "a", "imageName": null, "buttonLabel": "OK", "version": "2.0.0" }
            ] }
            """)
            #expect(WizardService.loadSteps(bundle: bundle).isEmpty)
        }
    }

    @Test func loadStepsOrThrowThrowsOnMalformedWizardJSON() async throws {
        withIsolatedLastSeenVersion("0.5.0") {
            let bundle = makeWizardBundle(json: "{ not valid json")
            #expect(throws: (any Error).self) {
                try WizardService.loadStepsOrThrow(bundle: bundle)
            }
            // The non-throwing variant treats the same failure as "nothing new".
            #expect(WizardService.loadSteps(bundle: bundle).isEmpty)
        }
    }

    @Test func shouldShowWizardFalseWhenVersionChangedButNoMatchingSteps() async throws {
        withIsolatedLastSeenVersion("0.9.0") {
            let bundle = makeWizardBundle(json: """
            { "steps": [
                { "title": "A", "subtitle": "a", "imageName": null, "buttonLabel": "OK", "version": "0.5.0" }
            ] }
            """)
            #expect(WizardService.shouldShowWizard(bundle: bundle) == false)
            // Side effect: lastSeenAppVersion should have been advanced so this doesn't
            // keep re-triggering (and re-decoding wizard.json) on every launch.
            #expect(UserDefaults.standard.string(forKey: lastSeenVersionKey) == "1.0.0")
        }
    }

    @Test func shouldShowWizardTrueWhenVersionChangedAndStepsMatch() async throws {
        withIsolatedLastSeenVersion("0.9.0") {
            let bundle = makeWizardBundle(json: """
            { "steps": [
                { "title": "A", "subtitle": "a", "imageName": null, "buttonLabel": "OK", "version": "1.0.0" }
            ] }
            """)
            #expect(WizardService.shouldShowWizard(bundle: bundle) == true)
        }
    }
}
