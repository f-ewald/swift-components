import ComponentDocsCore
import Foundation
import MCP

// Located relative to this file rather than the process's working directory,
// so the server works regardless of where `swift run` is invoked from.
let packageRoot =
    URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()  // main.swift
    .deletingLastPathComponent()  // ComponentDocsServer
    .deletingLastPathComponent()  // Tools
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
let componentsByName = Dictionary(uniqueKeysWithValues: components.map { ($0.name, $0) })

let server = Server(
    name: "swift-components",
    version: "1.0.0",
    capabilities: .init(tools: .init(listChanged: false))
)

await server.withMethodHandler(ListTools.self) { _ in
    .init(tools: [
        Tool(
            name: "list_components",
            description:
                "Lists every public SwiftUI View in swift-components (SharedComponents and "
                + "UIComponents) with a one-line summary and which library it lives in. Call "
                + "get_component_docs(name) for the full usage example, parameters, and source "
                + "location of a specific component.",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([:]),
            ])
        ),
        Tool(
            name: "get_component_docs",
            description:
                "Returns full Markdown documentation (description, usage example, initializer "
                + "parameters, source path) for one swift-components View. Use list_components "
                + "first to find a valid name.",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "name": .object([
                        "type": .string("string"),
                        "description": .string(#"Component type name, e.g. "StatusBannerView"."#),
                    ])
                ]),
                "required": .array([.string("name")]),
            ])
        ),
    ])
}

await server.withMethodHandler(CallTool.self) { params in
    switch params.name {
    case "list_components":
        let listing =
            components
            .map { "- \($0.name) (\($0.library)): \($0.summary)" }
            .joined(separator: "\n")
        return .init(content: [.text(text: listing, annotations: nil, _meta: nil)], isError: false)

    case "get_component_docs":
        guard let name = params.arguments?["name"]?.stringValue else {
            return .init(
                content: [.text(text: "Missing \"name\" argument.", annotations: nil, _meta: nil)],
                isError: true
            )
        }
        guard let doc = componentsByName[name] else {
            let available = components.map(\.name).sorted().joined(separator: ", ")
            return .init(
                content: [
                    .text(
                        text: "No component named \"\(name)\". Available: \(available)",
                        annotations: nil,
                        _meta: nil
                    )
                ],
                isError: true
            )
        }
        return .init(content: [.text(text: doc.markdown, annotations: nil, _meta: nil)], isError: false)

    default:
        return .init(
            content: [.text(text: "Unknown tool \"\(params.name)\".", annotations: nil, _meta: nil)],
            isError: true
        )
    }
}

let transport = StdioTransport()
try await server.start(transport: transport)
try await Task.sleep(for: .seconds(60 * 60 * 24 * 365 * 100))
