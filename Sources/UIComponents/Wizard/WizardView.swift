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
        // Safeguard against not defined steps
        if steps.count == 0 {
            self.steps = [WizardStep(title: "ERROR", subtitle: "No steps are defined. Please define them in wizard.json", imageName: "exclamationmark.triangle", buttonLabel: "OK", version: SemVer("0.0.1")!)]
        } else {
            self.steps = steps
        }
        self.gradientColors = gradientColors ?? [.blue, .purple]
        self.onComplete = onComplete
    }
    
    public var body: some View {
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
