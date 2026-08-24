//
//  WizardView.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 3/4/26.
//

import SwiftUI

/// Container for wizard json data
struct WizardContainer: Decodable {
    let steps: [WizardStep]
}

/// A single step for the wizard
public struct WizardStep: Codable {
    let title: String
    let subtitle: String
    let imageName: String?
    let buttonLabel: String
    let version: SemVer
}

public struct WizardView: View {
    let steps: [WizardStep]
    let gradientColors: [Color]
    var onComplete: () -> Void
    
    @State private var currentStep = 0
    
    private var step: WizardStep { steps[currentStep] }
    private var isLastStep: Bool { currentStep == steps.count - 1 }
    
    /// Instantiates a new WizardView with given steps, colors and callbacks
    ///
    /// - Parameters:
    ///     - steps: Ordered list of wizard steps
    ///     - gradientColors: Default colors if none are given
    ///     - onComplete: Callback that is called after the wizard completes
    public init(steps: [WizardStep], gradientColors: [Color]? = nil, onComplete: @escaping () -> Void) {
        self.steps = steps
        self.gradientColors = gradientColors ?? [.blue, .purple]
        self.onComplete = onComplete
    }
    
    public var body: some View {
        if steps.isEmpty {
            #if DEBUG
            // Surface a visible diagnostic in debug builds only — an empty `steps`
            // array reaching WizardView usually means wizard.json is missing/malformed
            // or the version filter is misconfigured, and that shouldn't fail silently
            // during development. Release builds fall through to EmptyView() below.
            emptyStateDebugView
            #else
            EmptyView()
            #endif
        } else {
            content
        }
    }
    
    private var content: some View {
        ZStack(alignment: .bottom) {
            // Content
            VStack(spacing: 32) {
                Spacer()
                
                if let imageName = step.imageName {
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .overlay {
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .mask {
                                Image(systemName: imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 180)
                            }
                        }
                        
                }
                
                VStack(spacing: 12) {
                    Text(step.title)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    Text(step.subtitle)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                Spacer()
            }
            .padding()
            
            // Glass button at bottom
            VStack(spacing: 16) {
                // Step indicators
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentStep ? Color.primary : Color.secondary.opacity(0.3))
                            .frame(width: index == currentStep ? 20 : 8, height: 8)
                            .animation(.spring(), value: currentStep)
                    }
                }
                
                Button {
                    if isLastStep {
                        onComplete()
                    } else {
                        withAnimation(.spring()) {
                            currentStep += 1
                        }
                    }
                } label: {
                    Text(step.buttonLabel)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        
                }
                .modifier(WizardButtonStyleModifier())

            }
            .padding()
        }
    }
    
    #if DEBUG
    /// Debug-only diagnostic screen shown when `steps` is empty — never compiled
    /// into release builds. Dismissing it calls `onComplete()`, same as a normal
    /// wizard completion, so a host app testing this path still unwinds cleanly.
    private var emptyStateDebugView: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .foregroundStyle(.yellow)
            
            VStack(spacing: 12) {
                Text("WizardView: No Steps")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                Text("WizardView received an empty steps array. Check that wizard.json exists, decodes successfully, and that WizardService's version filtering isn't excluding everything. This screen only appears in debug builds.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button("OK") {
                onComplete()
            }
            .modifier(WizardButtonStyleModifier())
        }
        .padding()
    }
    #endif
}

/// Applies Liquid Glass styling on iOS/macOS/watchOS 26+, falling back to
/// `.borderedProminent` on older OS versions where `.glassProminent` doesn't exist.
private struct WizardButtonStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, watchOS 26, *) {
            content.buttonStyle(.glassProminent)
        } else {
            content.buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    WizardView(steps: [
        WizardStep(title: "Feedback", subtitle: "Shake your phone to provide feedback", imageName: "bubble.circle", buttonLabel: "Done", version: SemVer("1.0.0")!),
        WizardStep(title: "Add Readings", subtitle: "Log your readings each morning", imageName: "plus.circle.fill", buttonLabel: "Next", version: SemVer("1.0.0")!),
        WizardStep(title: "You're all set!", subtitle: "Let's start tracking", imageName: "checkmark.seal.fill", buttonLabel: "Done", version: SemVer("1.0.0")!)
    ]) {
        // handle completion
    }
}
