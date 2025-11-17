import SwiftUI

struct PaywallView: View {
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @State private var selectedPlan: SubscriptionPlan?
    @State private var expandedPlan: SubscriptionPlan?
    @State private var navigateToWelcome = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "#FFFCF5").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 32)
                    
                    // Header
                    VStack(spacing: 0) {
                        Text("Start your")
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundColor(Color(hex: "#2A2A2A"))
                            .multilineTextAlignment(.center)
                        Text("journaling journey")
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundColor(Color(hex: "#2A2A2A"))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 16)
                    }
                    .padding(.bottom, 8)
                    
                    // Free trial badge
                    Text("Try it 3 days free.")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(Color(hex: "#A6B4FF"))
                        .padding(.bottom, 20)
                    
                    // Subscription Cards
                    VStack(spacing: 14) {
                        ForEach(SubscriptionPlan.allCases, id: \.self) { plan in
                            subscriptionCard(for: plan)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                    
                    // Purchase Button
                    Button(action: {
                        if let selectedPlan = selectedPlan {
                            Task {
                                await subscriptionManager.purchase(plan: selectedPlan)
                                if subscriptionManager.hasActiveSubscription {
                                    navigateToWelcome = true
                                }
                            }
                        }
                    }) {
                        Text("Start 3-Day Free Trial")
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                            .frame(height: 54)
                            .background(selectedPlan != nil ? Color(hex: "#A6B4FF") : Color.gray.opacity(0.4))
                            .cornerRadius(18)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(selectedPlan == nil || subscriptionManager.isLoading)
                    .padding(.bottom, 24)
                    
                    // Subscription info - shorter version
                    if let selectedPlan = selectedPlan {
                        Text("Your subscription starts after the 3 day free trial and renews automatically at \(selectedPlan.price) per \(billingPeriod(for: selectedPlan)) until canceled.")
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .foregroundColor(Color(hex: "#999999"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .padding(.horizontal, 30)
                            .padding(.bottom, 20)
                    } else {
                        Text("Your subscription starts after the 3 day free trial and renews automatically until canceled.")
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .foregroundColor(Color(hex: "#999999"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .padding(.horizontal, 30)
                            .padding(.bottom, 20)
                    }
                    
                    // Restore Purchases
                    Button(action: {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }) {
                        Text("Restore Purchases")
                            .font(.system(size: 13, weight: .medium, design: .default))
                            .foregroundColor(Color(hex: "#7A6EFF"))
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 16)
                    
                    // Legal Links
                    HStack(spacing: 16) {
                        Link("Privacy Policy", destination: URL(string: "https://www.studioeight.app/privacy.html")!)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "#A6B4FF"))
                        
                        Link("Terms of Use", destination: URL(string: "https://www.studioeight.app/terms.html")!)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "#A6B4FF"))
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 30)
                    
                    // Error Message
                    if let errorMessage = subscriptionManager.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $navigateToWelcome) {
            WelcomeView()
        }
    }
    
    @ViewBuilder
    private func subscriptionCard(for plan: SubscriptionPlan) -> some View {
        let isSelected = selectedPlan == plan
        let isExpanded = expandedPlan == plan
        
        VStack(alignment: .leading, spacing: 0) {
            // Main card content - tappable for selection
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.displayName)
                        .font(.system(size: 23, weight: .semibold, design: .serif))
                        .foregroundColor(Color(hex: "#2A2A2A"))
                    
                    Text(priceText(for: plan))
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(Color(hex: "#5B5564"))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                if let badge = plan.badge {
                    Text(badge)
                        .font(.system(size: 11, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(hex: "#A6B4FF"))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 25)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedPlan = plan
            }
            
            // Expandable feature section
            if isExpanded {
                VStack(alignment: .leading, spacing: 18) {
                    FeatureBullet(text: "Mood-based prompts that help you journal with purpose")
                    FeatureBullet(text: "Smart widgets that send personalized advice throughout your day")
                    FeatureBullet(text: "Editable Mantra cards to revisit, save, or share anytime")
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 18)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Expand/Collapse button - entire bottom area clickable
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    expandedPlan = isExpanded ? nil : plan
                }
            } label: {
                VStack(spacing: 12) {
                    // Short centered divider - 50% of card width
                    Rectangle()
                        .fill(Color(hex: "#7A7A7A").opacity(0.2))
                        .frame(width: UIScreen.main.bounds.width * 0.5, height: 1)
                        .frame(maxWidth: .infinity)
                    
                    // Chevron
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#7A7A7A"))
                        .rotationEffect(.degrees(0))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color(hex: "#A6B4FF") : Color.clear, lineWidth: 2)
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
        .scaleEffect(isSelected ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private func priceText(for plan: SubscriptionPlan) -> String {
        switch plan {
        case .weekly:
            return "\(plan.price) per week after free trial"
        case .monthly:
            return "\(plan.price) per month after free trial"
        case .annual:
            return "\(plan.price) per year after free trial"
        }
    }
    
    private func billingPeriod(for plan: SubscriptionPlan) -> String {
        switch plan {
        case .weekly:
            return "week"
        case .monthly:
            return "month"
        case .annual:
            return "year"
        }
    }
}

// MARK: - Feature Bullet Component
struct FeatureBullet: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(hex: "#A6B4FF"))
                .font(.system(size: 18))
            
            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(hex: "#5B5564"))
        }
    }
}

// MARK: - Preview
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
    }
}
