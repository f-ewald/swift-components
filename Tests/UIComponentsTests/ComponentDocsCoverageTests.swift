//
//  ComponentDocsCoverageTests.swift
//  UIComponents
//

import ComponentDocsCore
import Foundation
import Testing

/// Guards the MCP doc server's hybrid design: source scanning can't drift,
/// but the README section it pairs each component with is hand-maintained
/// and can silently go stale the moment a new public View ships without a
/// matching README heading. This fails loudly instead.
@Test func testEveryPublicViewHasAReadmeSection() throws {
    let packageRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // ComponentDocsCoverageTests.swift
        .deletingLastPathComponent()  // UIComponentsTests
        .deletingLastPathComponent()  // Tests
    let sourcesRoot = packageRoot.appendingPathComponent("Sources")
    let readmeURL = packageRoot.appendingPathComponent("README.md")

    let scanned = try SourceScanner.scan(
        sourcesRoot: sourcesRoot,
        libraries: ["SharedComponents", "UIComponents"]
    )
    let readmeText = try String(contentsOf: readmeURL, encoding: .utf8)
    let components = DocMerger.merge(
        scanned: scanned,
        readmeSections: ReadmeSource.parse(readme: readmeText)
    )

    let undocumented = components.filter { !$0.hasReadmeSection }.map(\.name)
    #expect(
        undocumented.isEmpty,
        "Public View(s) with no matching README section: \(undocumented.joined(separator: ", "))"
    )
}
