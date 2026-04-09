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
    public let type: String
    public let name: String
    public let email: String
    public let rating: Int
    public let message: String

    public init(type: String, name: String, email: String, rating: Int, message: String) {
        self.type = type
        self.name = name
        self.email = email
        self.rating = rating
        self.message = message
    }
}

/// Feedback view
struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var rating: Int = 0
    @State var message: String = ""
    @State var name: String = ""
    @State var email: String = ""
    @State var feedback: String = "Feedback"
    
    let feedbackType: [String] = [
        "Bug Report",
        "Feature Request",
        "Feedback",
        "Other",
    ]
    
    /// Returns `true` when all required fields contain non-whitespace text.
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !email.trimmingCharacters(in: .whitespaces).isEmpty
            && !message.trimmingCharacters(in: .whitespaces).isEmpty
    }

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
                    Picker("Type", selection: $feedback) {
                        ForEach(feedbackType, id: \.self) { feedbackType in
                            Text("\(feedbackType)")
                        }
                    }
                    .pickerStyle(.menu)
                    TextField("Name", text: $name)
                    TextField("E-Mail", text: $email)
                    TextField("Your Message", text: $message, axis: .vertical)
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
                            type: feedback,
                            name: name,
                            email: email,
                            rating: rating,
                            message: message,
                        )
                        onSend(feedback)
                        dismiss()
                    }
                    .disabled(!isFormValid)
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
    FeedbackView(onDismiss: { print("Dismissed") }, onSend: {feedback in print("Sent \(feedback)") })
}
