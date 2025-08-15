import SwiftUI

struct Prompt2View: View {
    @State private var responseText: String = ""
    @State private var currentQuestion: String = ""
    @State private var showTextEditor = false
    let mood: String
    let prompt1: String

    var body: some View {
        VStack(spacing: 0) {
            // Stack for prompt indicator and question card
            VStack(spacing: 0) {
                Text("Prompt 2 of 3")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#6E6E73"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#F5F5F5"))
                    )
                    .zIndex(1)
                    .offset(y: 15)

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
            NavigationLink(destination: Prompt3View(
                mood: mood,
                prompt1: prompt1,
                prompt2: responseText
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
            currentQuestion = PromptQuestionBank.getQuestion(for: mood, phase: 2)
        }
        .sheet(isPresented: $showTextEditor) {
            TextEditorView(text: $responseText, question: currentQuestion)
        }
    }
}
