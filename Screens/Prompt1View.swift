import SwiftUI

struct Prompt1View: View {
    @State private var responseText: String = ""
    @State private var currentQuestion: String = ""
    @State private var showTextEditor = false
    let mood: String

    var body: some View {
        VStack(spacing: 0) {
            // Stack for prompt indicator and question card
            VStack(spacing: 0) {
                // Prompt Indicator - sits on top edge of question card
                Text("Prompt 1 of 3")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#6E6E73"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#F5F5F5"))
                    )
                    .zIndex(1)
                    .offset(y: 15) // Overlap with question card
                
                // Question Card - FIXED: System serif font, consistent corner radius
                Text(currentQuestion)
                    .font(.system(size: 18, weight: .medium, design: .serif)) // ✅ System serif like logo
                    .foregroundColor(Color(hex: "#1C1C1E"))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18) // ✅ Consistent card radius
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 24)
            }
            .padding(.top, 80)

            // Text Input Preview Box
            Button(action: {
                showTextEditor = true
            }) {
                HStack {
                    Text(responseText.isEmpty ? "Write as much or as little as you'd like..." : responseText)
                        .font(.system(size: 16)) // ✅ System sans-serif for body
                        .foregroundColor(responseText.isEmpty ? Color(hex: "#B0B3BA") : Color(hex: "#1C1C1E"))
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
                .padding(16)
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#E9E5F4"), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 24)
            .padding(.top, 32)

            Spacer()

            // Continue Button - FIXED: Consistent color and radius
            NavigationLink(destination: Prompt2View(
                mood: mood,
                prompt1: responseText
            )) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold)) // ✅ System sans-serif for buttons
                    .foregroundColor(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12) // ✅ Consistent button radius
                            .fill(Color(hex: "#A6B4FF")) // ✅ Consistent primary color
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.3 : 1.0)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(hex: "#FFFCF5")) // ✅ Consistent background
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
        .onAppear {
            currentQuestion = PromptQuestionBank.getQuestion(for: mood, phase: 1)
        }
        .sheet(isPresented: $showTextEditor) {
            TextEditorView(text: $responseText, question: currentQuestion)
        }
    }
}

// Custom back button to avoid double back issue
struct BackButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button(action: {
            dismiss()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .medium))
                Text("Back")
                    .font(.system(size: 17))
            }
            .foregroundColor(Color(hex: "#A6B4FF")) // ✅ Consistent primary color
        }
    }
}

// Full screen text editor - FIXED: Consistent styling
struct TextEditorView: View {
    @Binding var text: String
    let question: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Show the question for context - FIXED: System serif
                Text(question)
                    .font(.system(size: 18, weight: .medium, design: .serif)) // ✅ System serif
                    .foregroundColor(Color(hex: "#1C1C1E"))
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                // Full text editor
                TextEditor(text: $text)
                    .font(.system(size: 16)) // ✅ System sans-serif for input
                    .foregroundColor(Color(hex: "#1C1C1E"))
                    .padding(.horizontal, 8)
                
                Spacer()
            }
            .background(Color(hex: "#FFFCF5")) // ✅ Consistent background
            .navigationTitle("Your Response")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "#A6B4FF")) // ✅ Consistent primary color
                }
            }
        }
    }
}
