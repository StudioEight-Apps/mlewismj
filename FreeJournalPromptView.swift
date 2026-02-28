import SwiftUI

struct FreeJournalPromptView: View {
    @State private var responseText: String = ""
    @State private var showTextEditor = false
    @FocusState private var isInputFocused: Bool
    @State private var isButtonPressed = false
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }
    let mood: String

    var body: some View {
        VStack(spacing: 0) {
            // Header section with title and body text
            VStack(spacing: 12) {
                Text("What's on your mind?")
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .foregroundColor(colors.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("A judgment-free space to let it out and breathe easier.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(colors.descriptionText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)

            // Text Input Preview Box
            Button(action: {
                showTextEditor = true
            }) {
                HStack {
                    Text(responseText.isEmpty ? "Write as much or as little as you'd like..." : responseText)
                        .font(.system(size: 16, weight: .regular))
                        .italic(responseText.isEmpty)
                        .foregroundColor(responseText.isEmpty ? colors.placeholder : colors.primaryText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(responseText.isEmpty ? 0.8 : 1.0)

                    Spacer()
                }
                .padding(16)
                .frame(minHeight: 200)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colors.questionCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isInputFocused ? colors.inputFocusBorder : colors.inputBorder, lineWidth: 1.5)
                        )
                        .shadow(color: isInputFocused ? colors.cardShadow : colors.cardShadowLight, radius: 8, x: 0, y: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .animation(.easeOut(duration: 0.25), value: isInputFocused)

            Spacer()

            // Continue Button
            NavigationLink(destination: LoadingView(
                mood: mood,
                freeJournalText: responseText
            )) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(colors.buttonText)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(colors.buttonBackground)
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
        .background(colors.secondaryBackground)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
        .sheet(isPresented: $showTextEditor) {
            FreeJournalTextEditorView(text: $responseText)
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

// Full screen text editor specifically for free journal
struct FreeJournalTextEditorView: View {
    @Binding var text: String
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }
    @FocusState private var isEditorFocused: Bool
    @State private var characterCount: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                colors.editorBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with question - SERIF FONT
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What's on your mind?")
                            .font(.system(size: 19, weight: .medium, design: .serif))
                            .foregroundColor(colors.primaryText)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)

                    // Subtle divider
                    Rectangle()
                        .fill(colors.divider)
                        .frame(height: 0.5)
                        .padding(.horizontal, 24)

                    // Text editor area
                    ZStack(alignment: .topLeading) {
                        // Elegant placeholder
                        if text.isEmpty {
                            Text("Share your thoughts...")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(colors.placeholder)
                                .padding(.horizontal, 28)
                                .padding(.top, 24)
                                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                        }

                        // Text editor with better padding
                        TextEditor(text: $text)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(colors.primaryText)
                            .lineSpacing(6)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .scrollContentBackground(.hidden)
                            .focused($isEditorFocused)
                            .onChange(of: text) { oldValue, newValue in
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
                    Text("Your Journal")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(colors.mutedText)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(colors.primaryText)
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

// BackButton is already defined in Prompt1View.swift - reusing it
