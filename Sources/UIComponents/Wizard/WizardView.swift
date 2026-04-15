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
    var onComplete: () -> Void
    
    @State private var currentStep = 0
    
    private var step: WizardStep { steps[currentStep] }
    private var isLastStep: Bool { currentStep == steps.count - 1 }
    
    public init(steps: [WizardStep], onComplete: @escaping () -> Void) {
        // Safeguard against not defined steps
        if steps.count == 0 {
            self.steps = [WizardStep(title: "ERROR", subtitle: "No steps are defined. Please define them in wizard.json", imageName: "exclamationmark.triangle", buttonLabel: "OK", version: SemVer("0.0.1")!)]
        } else {
            self.steps = steps
        }
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
                                colors: [
                                    .blue, .purple
                                ],
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
                .buttonStyle(.glassProminent)
                
            }
            .padding()
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
