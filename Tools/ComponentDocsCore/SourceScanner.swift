import Foundation
import SwiftParser
import SwiftSyntax

/// Scans package source files for public SwiftUI `View` types and their
/// public initializer signatures, so documentation can be generated from
/// what the code actually exposes instead of a hand-maintained duplicate.
public enum SourceScanner {
    /// Scans every `.swift` file under `sourcesRoot/<library>` for each given
    /// library name (e.g. `SharedComponents`, `UIComponents`) and returns one
    /// `ScannedView` per public `View`-conforming type found.
    public static func scan(sourcesRoot: URL, libraries: [String]) throws -> [ScannedView] {
        var results: [ScannedView] = []
        for library in libraries {
            let libraryRoot = sourcesRoot.appendingPathComponent(library)
            for file in swiftFiles(under: libraryRoot) {
                let source = try String(contentsOf: file, encoding: .utf8)
                let tree = Parser.parse(source: source)
                let visitor = ViewDeclVisitor(
                    library: library,
                    sourcePath: relativePath(of: file, to: sourcesRoot.deletingLastPathComponent())
                )
                visitor.walk(tree)
                results.append(contentsOf: visitor.foundViews)
            }
        }
        return results.sorted { $0.name < $1.name }
    }

    private static func swiftFiles(under directory: URL) -> [URL] {
        guard
            let enumerator = FileManager.default.enumerator(
                at: directory,
                includingPropertiesForKeys: nil
            )
        else { return [] }
        return enumerator.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
    }

    private static func relativePath(of file: URL, to root: URL) -> String {
        let filePath = file.standardizedFileURL.path
        let rootPath = root.standardizedFileURL.path
        guard filePath.hasPrefix(rootPath) else { return filePath }
        return String(filePath.dropFirst(rootPath.count))
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
}

/// Walks a parsed source file for `public struct`/`public class` declarations
/// that conform to `View`, collecting their doc comment and public
/// initializer signatures.
private final class ViewDeclVisitor: SyntaxVisitor {
    private let library: String
    private let sourcePath: String
    private(set) var foundViews: [ScannedView] = []

    init(library: String, sourcePath: String) {
        self.library = library
        self.sourcePath = sourcePath
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        collect(
            name: node.name.text,
            modifiers: node.modifiers,
            inheritance: node.inheritanceClause,
            members: node.memberBlock.members,
            leadingTrivia: node.leadingTrivia
        )
        return .visitChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        collect(
            name: node.name.text,
            modifiers: node.modifiers,
            inheritance: node.inheritanceClause,
            members: node.memberBlock.members,
            leadingTrivia: node.leadingTrivia
        )
        return .visitChildren
    }

    private func collect(
        name: String,
        modifiers: DeclModifierListSyntax,
        inheritance: InheritanceClauseSyntax?,
        members: MemberBlockItemListSyntax,
        leadingTrivia: Trivia
    ) {
        guard modifiers.contains(where: { $0.name.tokenKind == .keyword(.public) }) else { return }
        guard
            let inheritance,
            inheritance.inheritedTypes.contains(where: { $0.type.trimmedDescription == "View" })
        else { return }

        let initializers: [InitSignature] = members.compactMap { member in
            guard
                let initDecl = member.decl.as(InitializerDeclSyntax.self),
                initDecl.modifiers.contains(where: { $0.name.tokenKind == .keyword(.public) })
            else { return nil }

            let parameters = initDecl.signature.parameterClause.parameters.map { param in
                InitParameter(
                    name: (param.secondName ?? param.firstName).text,
                    type: param.type.trimmedDescription,
                    defaultValue: param.defaultValue?.value.trimmedDescription
                )
            }
            return InitSignature(
                parameters: parameters,
                whereClause: initDecl.genericWhereClause?.trimmedDescription
            )
        }

        foundViews.append(
            ScannedView(
                name: name,
                library: library,
                sourcePath: sourcePath,
                docComment: docComment(from: leadingTrivia),
                initializers: initializers
            )
        )
    }

    private func docComment(from trivia: Trivia) -> String? {
        let lines = trivia.compactMap { piece -> String? in
            guard case .docLineComment(let text) = piece else { return nil }
            return String(text.dropFirst(3)).trimmingCharacters(in: .whitespaces)
        }
        return lines.isEmpty ? nil : lines.joined(separator: " ")
    }
}
