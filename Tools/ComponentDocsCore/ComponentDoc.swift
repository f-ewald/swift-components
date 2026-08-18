/// A single labeled parameter of a public initializer.
public struct InitParameter: Sendable, Equatable {
    public let name: String
    public let type: String
    public let defaultValue: String?

    public init(name: String, type: String, defaultValue: String?) {
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
    }
}

/// One public initializer overload discovered on a component's source.
public struct InitSignature: Sendable, Equatable {
    public let parameters: [InitParameter]
    public let whereClause: String?

    public init(parameters: [InitParameter], whereClause: String? = nil) {
        self.parameters = parameters
        self.whereClause = whereClause
    }
}

/// A public SwiftUI `View` type found by scanning package sources.
public struct ScannedView: Sendable, Equatable {
    public let name: String
    public let library: String
    public let sourcePath: String
    public let docComment: String?
    public let initializers: [InitSignature]

    public init(
        name: String,
        library: String,
        sourcePath: String,
        docComment: String?,
        initializers: [InitSignature]
    ) {
        self.name = name
        self.library = library
        self.sourcePath = sourcePath
        self.docComment = docComment
        self.initializers = initializers
    }
}

/// The merged, agent-facing documentation for one component: source-derived
/// signatures (which can't drift from the code) plus README's hand-authored
/// prose and usage example (which carries the "why this one, not that one"
/// guidance a signature alone can't express).
public struct ComponentDoc: Sendable, Equatable {
    public let name: String
    public let library: String
    public let sourcePath: String
    public let summary: String
    public let description: String
    public let usageExamples: [String]
    public let initializers: [InitSignature]
    public let hasReadmeSection: Bool

    public init(
        name: String,
        library: String,
        sourcePath: String,
        summary: String,
        description: String,
        usageExamples: [String],
        initializers: [InitSignature],
        hasReadmeSection: Bool
    ) {
        self.name = name
        self.library = library
        self.sourcePath = sourcePath
        self.summary = summary
        self.description = description
        self.usageExamples = usageExamples
        self.initializers = initializers
        self.hasReadmeSection = hasReadmeSection
    }
}
