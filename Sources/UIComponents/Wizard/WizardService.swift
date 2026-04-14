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
    public static func shouldShowWizard() -> Bool {
        let currentVersion = currentAppVersion()
        let lastSeen = UserDefaults.standard.string(forKey: lastSeenVersionKey)
        return lastSeen != String(describing: currentVersion)
    }
    
    /// Load steps equal or greater than current version
    public static func loadSteps() -> [WizardStep] {
        let minStepVersion = currentAppVersion()
        
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
            
            let filteredSteps = wizardContainer.steps.filter { $0.version >= minStepVersion }
            return filteredSteps
        } catch {
            print(error)
        }
        
        return []
    }

    /// Call this after the What's New screen has been presented.
    public static func markCurrentVersionAsSeen() {
        UserDefaults.standard.set(String(describing: currentAppVersion()), forKey: lastSeenVersionKey)
    }

    private static func currentAppVersion() -> SemVer {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? SemVer ?? SemVer("1.0.0")!
    }
}
