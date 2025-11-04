import SwiftUI

struct Prompt2View: View {
    @State private var responseText: String = ""
    @State private var currentQuestion: String = ""
    @State private var showTextEditor = false
    @FocusState private var isInputFocused: Bool
    @State private var isButtonPressed = false
    let mood: String
    let prompt1: String

    var body: some View {
        VStack(spacing: 0) {
            // Stack for prompt indicator and question card
            VStack(spacing: 0) {
                // Prompt Indicator
                Text("Prompt 2 of 3")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "#6E6E73"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#F5F5F5"))
                    )
                    .zIndex(1)
                    .offset(y: 12)
                
                // Question Card - NO SERIF, sans-serif only
                Text(currentQuestion)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "#1C1C1E"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 28)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 24)
            }
            .padding(.top, 60)

            // Text Input Preview Box with improved styling
            Button(action: {
                showTextEditor = true
            }) {
                HStack {
                    Text(responseText.isEmpty ? "Write as much or as little as you'd like..." : responseText)
                        .font(.system(size: 16, weight: .regular))
                        .italic(responseText.isEmpty)
                        .foregroundColor(responseText.isEmpty ? Color(hex: "#999999") : Color(hex: "#1C1C1E"))
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(responseText.isEmpty ? 0.8 : 1.0)
                    
                    Spacer()
                }
                .padding(16)
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isInputFocused ? Color(hex: "#A6B4FF").opacity(0.4) : Color(hex: "#E5E5EA"), lineWidth: 1.5)
                        )
                        .shadow(color: isInputFocused ? Color.black.opacity(0.08) : Color.clear, radius: 8, x: 0, y: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .animation(.easeOut(duration: 0.25), value: isInputFocused)

            Spacer()

            // Continue Button with press animation
            NavigationLink(destination: Prompt3View(
                mood: mood,
                prompt1: prompt1,
                prompt2: responseText
            )) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#A6B4FF"))
                            .shadow(color: Color(hex: "#A6B4FF").opacity(0.2), radius: 4, x: 0, y: 2)
                    )
                    .scaleEffect(isButtonPressed ? 0.97 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1.0)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            withAnimation(.easeOut(duration: 0.1)) {
                                isButtonPressed = true
                            }
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.1)) {
                            isButtonPressed = false
                        }
                    }
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(hex: "#FFFCF5"))
        .navigationBarBackButtonHidden(true)
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
                .onDisappear {
                    isInputFocused = !responseText.isEmpty
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isInputFocused = false
                    }
                }
        }
    }
}
