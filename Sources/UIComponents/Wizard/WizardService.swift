//
//  WizardService.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 4/13/26.
//

import Foundation

public struct WizardService {
    private static let lastSeenVersionKey = "lastSeenAppVersion"

    /// Returns true if the WizardView should be shown.
    /// If the Wizard has never been shown, true will be returned.
    public static func shouldShowWizard() -> Bool {
        let currentVersion: SemVer = currentAppVersion()
        let lastSeen = UserDefaults.standard.string(forKey: lastSeenVersionKey)
        
        #if DEBUG
        print("Current app version is \(currentVersion) and last seen version is \(lastSeen ?? "unknown")")
        #endif
        
        return lastSeen != String(describing: currentVersion)
    }
    
    /// Load steps equal or greater than current version
    public static func loadSteps() -> [WizardStep] {
        let minStepVersion: SemVer = lastSeenVersion()
        
        guard let url = Bundle.main.url(forResource: "wizard", withExtension: "json") else {
            #if DEBUG
            print("Unable to load wizard.json from main bundle")
            #endif
            
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let wizardContainer = try decoder.decode(WizardContainer.self, from: data)
            
            let filteredSteps = wizardContainer.steps.filter {
                #if DEBUG
                print("Comparing \($0.version) to \(minStepVersion)")
                #endif
                return $0.version >= minStepVersion
            }
            
            #if DEBUG
            print("Loaded \(wizardContainer.steps.count) steps, after filtering \(filteredSteps.count) steps")
            #endif
            
            return filteredSteps
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        
        return []
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
