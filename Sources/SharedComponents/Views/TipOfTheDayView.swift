//
//  TipOfTheDayView.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 3/4/26.
//

import SwiftUI

public struct TipOfTheDayView: View {
    let message: String
    let autoCloseAfter: Duration?
    @Binding var isVisible: Bool
    @State private var startDate: Date?

    public init(message: String, isVisible: Binding<Bool>, autoCloseAfter: Duration? = nil) {
        self.message = message
        self._isVisible = isVisible
        self.autoCloseAfter = autoCloseAfter
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background gradient
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color("TipOfTheDayGradientStart", bundle: .module),
                            Color("TipOfTheDayGradientEnd", bundle: .module)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color("TipOfTheDayGradientStart", bundle: .module).opacity(0.25), radius: 12, x: 0, y: 6)

            VStack(alignment: .leading, spacing: 6) {
                // Title
                Label {
                    Text("Tip of the Day")
                        .font(.headline)
                } icon: {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16))
                }
                .foregroundStyle(Color("TipOfTheDayText", bundle: .module))

                // Message
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color("TipOfTheDaySecondaryText", bundle: .module))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("tipOfTheDay.message")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 20)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)

            // Close button
            if autoCloseAfter != nil {
                TimelineView(.animation) { timeline in
                    closeButtonView(progress: computeProgress(at: timeline.date))
                }
            } else {
                closeButtonView(progress: nil)
            }
        }
        .padding(.horizontal, 0)
        .onAppear {
            if autoCloseAfter != nil {
                startDate = Date()
            }
        }
        .task(id: autoCloseAfter) {
            guard let autoCloseAfter else { return }
            try? await Task.sleep(for: autoCloseAfter)
            withAnimation(.spring(duration: 0.3)) {
                isVisible = false
            }
        }
    }

    @ViewBuilder
    private func closeButtonView(progress: Double?) -> some View {
        Button {
            withAnimation(.spring(duration: 0.3)) {
                isVisible = false
            }
        } label: {
            ZStack {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        Color("TipOfTheDayText", bundle: .module),
                        Color("TipOfTheDaySecondaryText", bundle: .module).opacity(0.3)
                    )

                if let progress {
                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(
                            Color("TipOfTheDayText", bundle: .module),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 22, height: 22)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("tip.close")
        .padding(10)
        .sensoryFeedback(.success, trigger: isVisible)
    }

    private func computeProgress(at currentDate: Date) -> Double {
        guard let startDate, let autoCloseAfter else { return 0 }
        let totalSeconds = Double(autoCloseAfter.components.seconds)
            + Double(autoCloseAfter.components.attoseconds) / 1_000_000_000_000_000_000
        let elapsed = currentDate.timeIntervalSince(startDate)
        return min(max(elapsed / totalSeconds, 0), 1.0)
    }
}

#if os(iOS) || os(macOS)
#Preview("Tip of the day") {
    @Previewable @State var isVisible1: Bool = true
    @Previewable @State var isVisible2: Bool = true
    List {
        VStack {
            if isVisible1 {
                TipOfTheDayView(message: "This is an example that disappears when clicking the button.", isVisible: $isVisible1)
                    .padding(.bottom)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.top)
        .animation(.spring(duration: 0.35), value: isVisible1)
        .listRowSeparator(.hidden)
        
        if isVisible2 {
            TipOfTheDayView(message: "This is another example with a significantly longer text that spans multiple lines. Nothing should be cut off.", isVisible: $isVisible2)
                .padding(.bottom)
                .listRowSeparator(.hidden)
        }

        Button {
            isVisible1 = true
            isVisible2 = true
        } label: {
            Text("Reset")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
        }
        .buttonStyle(.borderedProminent)
        .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
}

#Preview("Tip of the day (Dark)") {
    @Previewable @State var isVisible1: Bool = true
    @Previewable @State var isVisible2: Bool = true
    List {
        VStack {
            if isVisible1 {
                TipOfTheDayView(message: "This is an example that disappears when clicking the button.", isVisible: $isVisible1)
                    .padding(.bottom)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.top)
        .animation(.spring(duration: 0.35), value: isVisible1)
        .listRowSeparator(.hidden)

        if isVisible2 {
            TipOfTheDayView(message: "This is another example with a significantly longer text that spans multiple lines. Nothing should be cut off.", isVisible: $isVisible2)
                .padding(.bottom)
                .listRowSeparator(.hidden)
        }

        Button {
            isVisible1 = true
            isVisible2 = true
        } label: {
            Text("Reset")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
        }
        .buttonStyle(.borderedProminent)
        .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
    .preferredColorScheme(.dark)
}

#Preview("Tip of the day (Auto-close)") {
    @Previewable @State var isVisible: Bool = true
    VStack {
        if isVisible {
            TipOfTheDayView(
                message: "This tip will automatically close in 5 seconds.",
                isVisible: $isVisible,
                autoCloseAfter: .seconds(5)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }

        Button("Reset") { isVisible = true }
            .buttonStyle(.borderedProminent)
    }
    .animation(.spring(duration: 0.35), value: isVisible)
    .padding()
}
#endif
