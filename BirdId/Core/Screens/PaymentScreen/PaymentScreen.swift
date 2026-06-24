//
//  PaymentScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 8/6/1404 AP.
//

import SwiftUI
import RevenueCat

struct PaymentScreen: View {

    @StateObject private var viewModel = SubscriptionViewModel()
    @State private var selectedPlan: PlanType? = .normal
    @State private var isFreeToggleOn: Bool = true
    @State private var isPurchasing = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack{
            Image(.bgImg)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0){
                // MARK: Header
                HStack(){
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .overlay {
                                Image(systemName: "xmark")
                                    .padding(.all, 12)
                                    .foregroundStyle(.text)
                            }
                            .adaptiveGlassEffect(style: .clear,cornerRadius: 99)
                            .frame(width: UIScreen.screenWidth / 8.18, height: UIScreen.screenHeight / 17.75)
                    }
                    Spacer()
                }
                // MARK: Animation
                LottieView(animationName: "PaymentAnimation")
                    .frame(width: UIScreen.screenWidth / 1.965,height: UIScreen.screenHeight / 4.26)
                    .padding(.bottom,16)
                Text("UNLOCK PREMIUM")
                    .font(.app(.Title1))
                    .foregroundStyle(.text)
                    .padding(.bottom,16)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .dynamicTypeSize(.small ... .xxLarge)
                
                // MARK: Features
                VStack(alignment: .leading, spacing: 16) {
                    featureItem(image: .search, text: "Unlimited bird identifications")
                    featureItem(image: .crownMinimalistic, text: "Access to rare species database")
                    featureItem(image: .pulse, text: "Offline recognition mode")
                }
                .padding(.bottom,24)
                
                // MARK: Plans
                VStack(spacing: 16) {
                    if dynamicPlans.isEmpty {
                        ProgressView()
                            .tint(.text)
                            .frame(maxWidth: .infinity)
                            .frame(height: UIScreen.screenHeight / 5)
                    }
                    ForEach(dynamicPlans) { plan in
                        PlanOptionView(
                            type: plan.type,
                            title: plan.title,
                            price: plan.price,
                            discountedPrice: plan.discounted,
                            badgeText: plan.badge,
                            isSelected: selectedPlan == plan.type,
                            isFreeToggleOn: plan.type == .free ? isFreeToggleOn : nil,
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    selectedPlan = plan.type
                                    // Yearly selected: turn the free toggle off
                                    if plan.type == .discount {
                                        isFreeToggleOn = false
                                    }
                                    // Weekly selected: turn the free toggle on
                                    else if plan.type == .normal {
                                        isFreeToggleOn = true
                                    }
                                }
                            },
                            onToggleChange: { isOn in
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    isFreeToggleOn = isOn
                                    // Toggle on -> weekly, toggle off -> yearly
                                    selectedPlan = isOn ? .normal : .discount
                                }
                            }
                        )
                    }
                }
                .padding(.bottom,24)
                // MARK: Continue Button
                Button(action: {
                    handleContinue()
                }, label: {
                    Group {
                        if isPurchasing {
                            ProgressView()
                                .tint(.text)
                        } else {
                            Text("Continue")
                                .font(.app(.Sub1))
                                .foregroundStyle(.text)
                                .minimumScaleFactor(0.75)
                                .dynamicTypeSize(.small ... .xxLarge)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.screenHeight / 16.38)
                    .adaptiveGlassEffect(style: .clear,cornerRadius: 99)
                    .contentShape(Rectangle())
                })
                .padding(.bottom,8)
                .disabled(isPurchasing)


                HStack(spacing: 8) {
                    Button {
                        viewModel.restorePurchases()
                    } label: {
                        Text("Restore")
                            .font(.app(.Micro1))
                            .foregroundStyle(.text)
                            .underline()
                    }

                    ForEach(["Term of Use", "Privacy Policy"], id: \.self) { text in
                        Text(text)
                            .font(.app(.Micro1))
                            .foregroundStyle(.text)
                            .underline()
                    }
                }
            }
            .padding(24)
        }
        .navigationBarBackButtonHidden(true)
    }
}

extension PaymentScreen {

    /// Builds plans from RevenueCat offerings (real prices, not mock).
    /// Returns an empty array until offerings load, so the UI can show a loader.
    private var dynamicPlans: [PlanItem] {
        guard let packages = viewModel.offerings?.current?.availablePackages else {
            return []
        }

        let weekly = packages.first { $0.packageType == .weekly }
        let yearly = packages.first { $0.packageType == .annual }

        var items: [PlanItem] = []

        // Yearly (discounted): striked price = 52 weeks equivalent, final = real yearly price.
        if let yearly {
            let yearlyProduct = yearly.storeProduct
            var strikedPrice: String? = nil
            var badge: String? = nil

            if let weeklyProduct = weekly?.storeProduct {
                let fullYearValue = weeklyProduct.price * 52
                strikedPrice = weeklyProduct.priceFormatter?
                    .string(from: fullYearValue as NSDecimalNumber)

                if fullYearValue > 0 {
                    let ratio = (1 - (yearlyProduct.price / fullYearValue)) * 100
                    let percent = NSDecimalNumber(decimal: ratio).intValue
                    if percent > 0 { badge = "-\(percent)% OFF" }
                }
            }

            items.append(PlanItem(
                type: .discount,
                title: "Yearly",
                price: strikedPrice,
                discounted: "\(yearlyProduct.localizedPriceString)/year",
                badge: badge
            ))
        }

        // Weekly: real price.
        if let weekly {
            items.append(PlanItem(
                type: .normal,
                title: "Weekly",
                price: "\(weekly.storeProduct.localizedPriceString)/week, auto renewable",
                discounted: nil,
                badge: nil
            ))
        }

        // Free: a UI option (trial toggle), not a real package.
        items.append(PlanItem(
            type: .free,
            title: "Free Plan",
            price: nil,
            discounted: nil,
            badge: "Free Trial"
        ))

        return items
    }

    /// Returns the RevenueCat package matching the selected plan.
    private func packageFor(_ plan: PlanType?) -> Package? {
        guard let packages = viewModel.offerings?.current?.availablePackages else { return nil }
        switch plan {
        case .discount:
            return packages.first { $0.packageType == .annual } ?? packages.first
        case .normal, .free, .none:
            return packages.first { $0.packageType == .weekly } ?? packages.first
        }
    }

    /// Purchases the selected plan. Dismisses the screen on success.
    private func handleContinue() {
        guard let package = packageFor(selectedPlan) else {
            print("⚠️ No package found for the selected plan")
            return
        }
        viewModel.selectedPackage = package
        isPurchasing = true

        viewModel.purchaseSelectedPackage { customerInfo in
            isPurchasing = false
            if customerInfo != nil {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    private func featureItem(image: ImageResource, text: String) -> some View {
        HStack(spacing: 8) {
            Image(image)
                .frame(width: 20, height: 20)
            Text(text)
                .font(.app(.Sub1))
                .foregroundStyle(.text)
                .minimumScaleFactor(0.75)
                .dynamicTypeSize(.small ... .xxLarge)
        }
    }
}

#Preview {
    PaymentScreen()
}


struct PlanItem: Identifiable {
    // Stable identity by plan type (each card is unique) so SwiftUI reuses
    // the views across renders and selection animates smoothly.
    var id: PlanType { type }
    let type: PlanType
    let title: String
    let price: String?
    let discounted: String?
    let badge: String?
}
