import SwiftUI

struct WidgetSetupHomeScreen: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentStep = 1
    @State private var navigateToWelcome = false
    var isFromSettings: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    if currentStep == 1 && isFromSettings {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                                .frame(width: 30, height: 30)
                                .background(.white.opacity(0.08))
                                .clipShape(Circle())
                        }
                    } else if currentStep == 2 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                currentStep = 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }

                    Spacer()

                    Text("\(currentStep) of 2")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 60)

                        // Icon
                        Group {
                            if currentStep == 1 {
                                Image(systemName: "square.grid.2x2")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundColor(Color(hex: "#C4A574"))
                            } else {
                                Image("paywall-icon-device-mobile")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(Color(hex: "#C4A574"))
                            }
                        }
                        .padding(.bottom, 20)

                        // Title
                        Text(currentStep == 1
                             ? "Add Whisper to your\nHome Screen"
                             : "Now add it to your\nLock Screen")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.bottom, 36)

                        // Steps
                        VStack(alignment: .leading, spacing: 20) {
                            if currentStep == 1 {
                                stepRow(number: "1", text: "Long press any empty space on your Home Screen")
                                stepRow(number: "2", text: "Tap the + button in the top corner")
                                stepRow(number: "3", text: "Search for \"Whisper\" and select a widget size")
                            } else {
                                stepRow(number: "1", text: "Long press your Lock Screen and tap Customize")
                                stepRow(number: "2", text: "Tap the widget area below the clock")
                                stepRow(number: "3", text: "Search for \"Whisper\" and add the widget")
                            }
                        }
                        .padding(.horizontal, 32)

                        Spacer().frame(height: 40)
                    }
                }

                // Button
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    if currentStep == 1 {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            currentStep = 2
                        }
                    } else {
                        UserDefaults.standard.set(true, forKey: "hasSeenWidgetSetup")
                        if isFromSettings {
                            dismiss()
                        } else {
                            navigateToWelcome = true
                        }
                    }
                }) {
                    Text(currentStep == 1 ? "Next" : "Done")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(.white)
                        .cornerRadius(27)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

                if !isFromSettings && currentStep == 1 {
                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "hasSeenWidgetSetup")
                        dismiss()
                    }) {
                        Text("Skip")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.35))
                    }
                    .padding(.bottom, 28)
                } else {
                    Spacer().frame(height: 28)
                }
            }
        }
        .fullScreenCover(isPresented: $navigateToWelcome) {
            WelcomeView()
        }
    }

    private func stepRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 28, height: 28)
                .background(Color(hex: "#C4A574"))
                .clipShape(Circle())

            Text(text)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct WidgetCard: View {
    let background: String
    let height: CGFloat
    let text: String
    let fontSize: CGFloat

    var body: some View {
        ZStack {
            Image(background)
                .resizable()
                .scaledToFill()
                .frame(height: height)
                .clipped()

            VStack(spacing: 4) {
                Image("whisper-widget-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: fontSize == 14 ? 12 : 10)
                    .opacity(0.8)

                Text(text)
                    .font(.custom("NewYork-Medium", size: fontSize))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 12)
            }
        }
        .cornerRadius(16)
    }
}
