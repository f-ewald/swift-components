//
//  FeedbackView.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 3/4/26.
//

import SwiftUI

/// 1-5 Stars
struct StarRatingView: View {
    @Binding var rating: Int
    let maxRating: Int = 5
    
    var body: some View {
            HStack {
                ForEach(1...maxRating, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundStyle(.clear)
                        .overlay {
                            LinearGradient(
                                colors: [
                                    .yellow.mix(with: .white, by: 0.6),
                                    .yellow,
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .mask {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                            }
                        }
                        .onTapGesture {
                            #if DEBUG
                            print("Selected rating \(star)")
                            #endif
                            rating = star
                        }
                
            }
        }
    }
}

/// Provides a star rating form field.
struct StarRatingField: View {
    let label: String
    @Binding var rating: Int
    var body: some View {
        LabeledContent(label) {
            StarRatingView(rating: $rating)
        }
    }
}

/// Feedback provided by the user
public struct Feedback: Codable, Sendable {
    public let rating: Int
    public let message: String

    public init(rating: Int, message: String) {
        self.rating = rating
        self.message = message
    }
}

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State var rating: Int = 0
    @State var message: String = ""
    
    let onDismiss: (() -> Void)?
    let onSend: (_ feedback: Feedback) -> Void
    
    init(onDismiss: (() -> Void)? = nil, onSend: @escaping (_ feedback: Feedback) -> Void) {
        self.onDismiss = onDismiss
        self.onSend = onSend
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(footer: Text("Your feedback helps to improve this app.")) {
                    StarRatingField(label: "Rate your experience", rating: $rating)
                    TextField("Your Feedback", text: $message, axis: .vertical)
                        .lineLimit(10, reservesSpace: true)
                }
            }
            .navigationTitle("Feedback")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss?()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        let feedback = Feedback(
                            rating: rating,
                            message: message,
                        )
                        onSend(feedback)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview("Default Feedback View") {
    FeedbackView() { feedback in
        print(feedback)
    }
}

#Preview("Dismiss") {
    FeedbackView(onDismiss: { print("Dismissed") }, onSend: {_ in print("Sent") })
}
