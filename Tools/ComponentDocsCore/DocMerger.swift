/// Combines source-derived `ScannedView`s with README's hand-authored prose
/// and examples into the `ComponentDoc`s served by the MCP tools.
public enum DocMerger {
    public static func merge(
        scanned: [ScannedView],
        readmeSections: [ReadmeSection]
    ) -> [ComponentDoc] {
        scanned
            .map { view in
                let section = readmeSections.first { $0.headingNames.contains(view.name) }
                let description =
                    section?.description
                    ?? view.docComment
                    ?? "No description available yet — add a doc comment or a README section for \(view.name)."
                return ComponentDoc(
                    name: view.name,
                    library: view.library,
                    sourcePath: view.sourcePath,
                    summary: firstSentence(of: description),
                    description: description,
                    usageExamples: section?.codeExamples ?? [],
                    initializers: view.initializers,
                    hasReadmeSection: section != nil
                )
            }
            .sorted { $0.name < $1.name }
    }

    private static func firstSentence(of text: String) -> String {
        guard let range = text.range(of: ". ") else { return text }
        return String(text[..<range.lowerBound]) + "."
    }
}

extension ComponentDoc {
    /// Full Markdown documentation for `get_component_docs`, mirroring the
    /// shape of the reference `@f-ewald/components` MCP server's output.
    public var markdown: String {
        var out = "# `\(name)`\n\n\(description)\n\n"

        out += "## Usage\n\n"
        if usageExamples.isEmpty {
            out += "_No usage example in README yet._\n\n"
        } else {
            for example in usageExamples {
                out += "```swift\n\(example)\n```\n\n"
            }
        }

        out += "## Initializers\n\n"
        if initializers.isEmpty {
            out += "_No public initializer found._\n\n"
        }
        for (index, initSig) in initializers.enumerated() {
            if initializers.count > 1 {
                out += "**Overload \(index + 1)**\n\n"
            }
            if initSig.parameters.isEmpty {
                out += "No parameters.\n\n"
            } else {
                out += "| Parameter | Type | Default |\n| --- | --- | --- |\n"
                for param in initSig.parameters {
                    let defaultText = param.defaultValue.map { "`\($0)`" } ?? "_required_"
                    out += "| `\(param.name)` | `\(param.type)` | \(defaultText) |\n"
                }
                out += "\n"
            }
            if let whereClause = initSig.whereClause {
                out += "`\(whereClause)`\n\n"
            }
        }

        out += "## Source\n\n`\(sourcePath)` (`\(library)`)\n"
        return out
    }
}
