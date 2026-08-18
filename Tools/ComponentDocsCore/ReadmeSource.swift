import Foundation

/// One hand-authored documentation section parsed out of README.md, keyed
/// by every component/type name mentioned in its heading (a heading like
/// "FeedbackView / FeedbackService" names two symbols).
public struct ReadmeSection: Sendable, Equatable {
    public let headingNames: [String]
    public let description: String
    public let codeExamples: [String]

    public init(headingNames: [String], description: String, codeExamples: [String]) {
        self.headingNames = headingNames
        self.description = description
        self.codeExamples = codeExamples
    }
}

/// Parses swift-components' README.md into per-heading sections so its
/// existing, human-maintained descriptions and usage examples can be reused
/// as documentation content instead of duplicated by hand.
public enum ReadmeSource {
    public static func parse(readme: String) -> [ReadmeSection] {
        let lines = readme.components(separatedBy: .newlines)
        var sections: [ReadmeSection] = []

        var index = 0
        while index < lines.count {
            guard let heading = headingText(of: lines[index]) else {
                index += 1
                continue
            }
            var cursor = index + 1
            var bodyLines: [String] = []
            while cursor < lines.count, headingText(of: lines[cursor]) == nil {
                bodyLines.append(lines[cursor])
                cursor += 1
            }
            sections.append(
                ReadmeSection(
                    headingNames: candidateNames(from: heading),
                    description: description(from: bodyLines),
                    codeExamples: swiftCodeBlocks(in: bodyLines)
                )
            )
            index = cursor
        }
        return sections
    }

    /// Returns the heading text for a `##`/`###`/`####` line, or `nil`.
    private static func headingText(of line: String) -> String? {
        for prefix in ["#### ", "### ", "## "] where line.hasPrefix(prefix) {
            return String(line.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    /// A heading like "RatingsView / AppLaunchState" or
    /// "Shake Detection (iOS only)" names one or more Swift symbols.
    private static func candidateNames(from heading: String) -> [String] {
        let withoutParenthetical = heading.replacingOccurrences(
            of: #"\s*\([^)]*\)"#,
            with: "",
            options: .regularExpression
        )
        return withoutParenthetical
            .components(separatedBy: "/")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private static func description(from bodyLines: [String]) -> String {
        var result: [String] = []
        var inCodeBlock = false
        for line in bodyLines {
            if line.hasPrefix("```") {
                inCodeBlock.toggle()
                continue
            }
            if inCodeBlock { continue }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("<img") { continue }
            result.append(trimmed)
        }
        return result.joined(separator: " ")
    }

    private static func swiftCodeBlocks(in bodyLines: [String]) -> [String] {
        var blocks: [String] = []
        var current: [String]?
        for line in bodyLines {
            if line.hasPrefix("```swift") {
                current = []
            } else if line.hasPrefix("```"), current != nil {
                blocks.append(current!.joined(separator: "\n"))
                current = nil
            } else if current != nil {
                current!.append(line)
            }
        }
        return blocks
    }
}
