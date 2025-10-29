import SwiftUI

struct FreeJournalPromptView: View {
    @State private var responseText: String = ""
    @State private var showTextEditor = false
    @FocusState private var isInputFocused: Bool
    @State private var isButtonPressed = false
    let mood: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Question Card - larger for free journal
            VStack(spacing: 0) {
                Text("What's on your mind?")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color(hex: "#1C1C1E"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 24)
            }
            .padding(.top, 60)
            
            // Text Input Preview Box
            Button(action: {
                showTextEditor = true
            }) {
                HStack {
                    Text(responseText.isEmpty ? "Write as much or as little as you'd like..." : responseText)
                        .font(.system(size: 16, weight: .regular))
                        .italic(responseText.isEmpty)
                        .foregroundColor(responseText.isEmpty ? Color(hex: "#999999") : Color(hex: "#1C1C1E"))
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
            NavigationLink(destination: LoadingView(
                mood: mood,
                freeJournalText: responseText
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
    @FocusState private var isEditorFocused: Bool
    @State private var characterCount: Int = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "#FFFCF5")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with question
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What's on your mind?")
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
                    Text("Your Journal")
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

// BackButton is already defined in Prompt1View.swift - reusing it
