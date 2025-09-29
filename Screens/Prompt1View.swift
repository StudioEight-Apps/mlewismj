import SwiftUI

struct Prompt1View: View {
    @State private var responseText: String = ""
    @State private var currentQuestion: String = ""
    @State private var showTextEditor = false
    @FocusState private var isInputFocused: Bool
    @State private var isButtonPressed = false
    let mood: String

    var body: some View {
        VStack(spacing: 0) {
            // Stack for prompt indicator and question card
            VStack(spacing: 0) {
                // Prompt Indicator - Caption typography
                Text("Prompt 1 of 3")
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
                
                // Question Card - Reduced size and padding - NO SERIF
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
            NavigationLink(destination: Prompt2View(
                mood: mood,
                prompt1: responseText
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
                .onDisappear {
                    // Simulate focus state when returning from editor
                    isInputFocused = !responseText.isEmpty
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isInputFocused = false
                    }
                }
        }
    }
}

// Custom back button
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
            .foregroundColor(Color(hex: "#A6B4FF"))
        }
    }
}

// Enhanced full screen text editor with premium design
struct TextEditorView: View {
    @Binding var text: String
    let question: String
    @Environment(\.dismiss) var dismiss
    @FocusState private var isEditorFocused: Bool
    @State private var characterCount: Int = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "#FFFCF5")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Question header - more minimal and elegant
                    VStack(alignment: .leading, spacing: 8) {
                        Text(question)
                            .font(.system(size: 19, weight: .medium))
                            .foregroundColor(Color(hex: "#1C1C1E"))
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    
                    // Subtle divider
                    Rectangle()
                        .fill(Color(hex: "#E5E5EA").opacity(0.5))
                        .frame(height: 0.5)
                        .padding(.horizontal, 24)
                    
                    // Text editor area
                    ZStack(alignment: .topLeading) {
                        // Elegant placeholder
                        if text.isEmpty {
                            Text("Share your thoughts...")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(Color(hex: "#B0B3BA"))
                                .padding(.horizontal, 28)
                                .padding(.top, 24)
                                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                        }
                        
                        // Text editor with better padding
                        TextEditor(text: $text)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(Color(hex: "#1C1C1E"))
                            .lineSpacing(6)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .scrollContentBackground(.hidden)
                            .focused($isEditorFocused)
                            .onChange(of: text) { newValue in
                                withAnimation(.easeOut(duration: 0.2)) {
                                    characterCount = newValue.count
                                }
                            }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Your Response")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: "#6E6E73"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(hex: "#A6B4FF"))
                    }
                }
            }
            .onAppear {
                characterCount = text.count
                // Auto-focus keyboard with slight delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isEditorFocused = true
                }
            }
        }
    }
}
