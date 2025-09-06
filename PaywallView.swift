import SwiftUI

struct PaywallView: View {
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @State private var selectedPlan: SubscriptionPlan?
    @State private var navigateToWelcome = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFFCF5").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 40)
                        
                        // Header
                        VStack(spacing: 16) {
                            Text("Unlock Your Full\nJournaling Experience")
                                .font(.system(size: 28, weight: .semibold, design: .serif))
                                .foregroundColor(Color(hex: "#2A2A2A"))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                            
                            Text("Get 3 days free when you\nselect your plan")
                                .font(.system(size: 18, weight: .regular, design: .default))
                                .foregroundColor(Color(hex: "#5B5564"))
                                .multilineTextAlignment(.center)
                                .lineSpacing(2)
                        }
                        .padding(.bottom, 50)
                        
                        // Subscription Cards
                        VStack(spacing: 16) {
                            ForEach(SubscriptionPlan.allCases, id: \.self) { plan in
                                subscriptionCard(for: plan)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        
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
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .frame(width: UIScreen.main.bounds.width * 0.9)
                                .frame(height: 52)
                                .background(selectedPlan != nil ? Color(hex: "#A6B4FF") : Color.gray.opacity(0.4))
                                .cornerRadius(18)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(selectedPlan == nil || subscriptionManager.isLoading)
                        .padding(.bottom, 20)
                        
                        // Restore Purchases
                        Button(action: {
                            Task {
                                await subscriptionManager.restorePurchases()
                            }
                        }) {
                            Text("Restore Purchases")
                                .font(.system(size: 16, weight: .medium, design: .default))
                                .foregroundColor(Color(hex: "#7A6EFF"))
                        }
                        .padding(.bottom, 10)
                        
                        // Terms
                        Text("Cancel anytime. No commitment.")
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(Color(hex: "#7A7A7A"))
                            .padding(.bottom, 40)
                        
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
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $navigateToWelcome) {
            WelcomeView()
        }
    }
    
    @ViewBuilder
    private func subscriptionCard(for plan: SubscriptionPlan) -> some View {
        let isSelected = selectedPlan == plan
        
        Button(action: {
            selectedPlan = plan
        }) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.displayName)
                            .font(.system(size: 24, weight: .semibold, design: .serif))
                            .foregroundColor(Color(hex: "#2A2A2A"))
                        
                        Text(plan.price)
                            .font(.system(size: 20, weight: .medium, design: .default))
                            .foregroundColor(Color(hex: "#2A2A2A"))
                    }
                    
                    Spacer()
                    
                    if let badge = plan.badge {
                        Text(badge)
                            .font(.system(size: 12, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "#A6B4FF"))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color(hex: "#A6B4FF") : Color.clear, lineWidth: 2)
            )
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
    }
}
