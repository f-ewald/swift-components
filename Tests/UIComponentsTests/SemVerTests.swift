//
//  SemVerTests.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 4/28/26.
//

import Testing
@testable import UIComponents

@Test func testInitNumber() async throws {
    let version = SemVer(1, 2, 3)
    assert(version.major == 1)
    assert(version.minor == 2)
    assert(version.patch == 3)
}

@Test func testInitString() async throws {
    let version = SemVer("1.2.3")
    assert(version != nil)
    assert(version?.major == 1)
    assert(version?.minor == 2)
    assert(version?.patch == 3)
}
