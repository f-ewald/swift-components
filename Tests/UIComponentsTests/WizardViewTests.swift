//
//  WizardViewTests.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 8/24/26.
//

import Testing
@testable import UIComponents

@MainActor
@Test func testWizardViewWithEmptyStepsDoesNotSubstitutePlaceholder() async throws {
    let view = WizardView(steps: []) {}
    #expect(view.steps.isEmpty)
}
