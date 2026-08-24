//
//  WizardService.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 4/13/26.
//

import Foundation

public struct WizardService {
    private static let lastSeenVersionKey = "lastSeenAppVersion"

    /// Returns true if the WizardView should be shown, i.e. the app version changed
    /// since last seen **and** there are steps newer than what the user has already
    /// seen. If it returns `false` because there are no matching steps, this also
    /// advances `lastSeenAppVersion` as a side effect, so the check doesn't keep
    /// re-running (and re-decoding `wizard.json`) on every subsequent launch.
    public static func shouldShowWizard(bundle: Bundle = .main) -> Bool {
        let currentVersion: SemVer = currentAppVersion()
        let lastSeen = UserDefaults.standard.string(forKey: lastSeenVersionKey)
        
        #if DEBUG
        print("Current app version is \(currentVersion) and last seen version is \(lastSeen ?? "unknown")")
        #endif
        
        let versionChanged = lastSeen != String(describing: currentVersion)
        let hasNewSteps = !loadSteps(bundle: bundle).isEmpty
        
        if versionChanged && !hasNewSteps {
            markCurrentVersionAsSeen()
        }
        
        return versionChanged && hasNewSteps
    }
    
    /// Load steps strictly newer than `lastSeenAppVersion` and no newer than the
    /// current app version. A missing or malformed `wizard.json` is treated as
    /// "nothing new" and returns `[]`; use `loadStepsOrThrow(bundle:)` if you need
    /// to distinguish a decode failure from that legitimate empty result.
    public static func loadSteps(bundle: Bundle = .main) -> [WizardStep] {
        (try? loadStepsOrThrow(bundle: bundle)) ?? []
    }

    /// Like `loadSteps(bundle:)`, but throws when `wizard.json` exists and fails to
    /// decode, instead of silently returning `[]`. A `wizard.json` that isn't
    /// bundled at all is not an error — that case still returns `[]`.
    public static func loadStepsOrThrow(bundle: Bundle = .main) throws -> [WizardStep] {
        let minStepVersion: SemVer = lastSeenVersion()
        let currentVersion: SemVer = currentAppVersion()
        
        guard let url = bundle.url(forResource: "wizard", withExtension: "json") else {
            #if DEBUG
            print("Unable to load wizard.json from bundle")
            #endif
            
            return []
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let wizardContainer = try decoder.decode(WizardContainer.self, from: data)
        
        let filteredSteps = wizardContainer.steps.filter {
            #if DEBUG
            print("Comparing \($0.version) to \(minStepVersion)")
            #endif
            return $0.version > minStepVersion && $0.version <= currentVersion
        }
        
        #if DEBUG
        print("Loaded \(wizardContainer.steps.count) steps, after filtering \(filteredSteps.count) steps")
        #endif
        
        return filteredSteps
    }

    /// Call this after the What's New screen has been presented.
    public static func markCurrentVersionAsSeen() {
        UserDefaults.standard.set(String(describing: currentAppVersion()), forKey: lastSeenVersionKey)
    }

    /// Return the current app version as SemVer and fall back to 1.0.0 if not known.
    private static func currentAppVersion() -> SemVer {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        if let currentVersionString = currentVersion as? String {
            return SemVer(currentVersionString) ?? SemVer(1, 0, 0)
        }
        return SemVer(1, 0, 0)
    }
    
    private static func lastSeenVersion() -> SemVer {
        let lastSeen = UserDefaults.standard.string(forKey: lastSeenVersionKey)
        if let lastSeenString = lastSeen {
            return SemVer(lastSeenString) ?? SemVer(0, 0, 1)
        }
        
        // Fall back to safe default value
        return SemVer(0, 0, 1)
    }
}
