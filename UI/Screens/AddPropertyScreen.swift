import SwiftUI

private let totalSteps = 2

struct AddPropertyScreen: View {
    let onComplete: () -> Void
    let onBack: () -> Void
    var editingIndex: Int? = nil
    var initialFormState: OnboardingFormState? = nil

    @StateObject private var repository = PropertyRepository.shared
    @State private var currentStep = 1
    @State private var formState = OnboardingFormState()
    @State private var showSuccess = false

    private var isEditMode: Bool { editingIndex != nil }

    private func handleBack() {
        if currentStep > 1 {
            currentStep -= 1
        } else {
            onBack()
        }
    }

    var body: some View {
        if showSuccess {
            SuccessView(formState: formState, onComplete: onComplete)
        } else {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        StepProgressHeaderView(
                            currentStep: currentStep,
                            totalSteps: totalSteps,
                            title: currentStep == 1
                                ? (isEditMode ? "Edit property details" : "Basic details of your property")
                                : (isEditMode ? "Update property info" : "Your net-worth is almost ready!"),
                            onBack: handleBack
                        )

                        if currentStep == 1 {
                            AddPropertyStep1View(formState: $formState)
                        } else {
                            AddPropertyStep2View(formState: $formState)
                        }
                    }
                }

                // Bottom CTA
                BottomCtaBar(
                    currentStep: currentStep,
                    formState: formState,
                    isEditMode: isEditMode,
                    onContinue: { currentStep = 2 },
                    onAddProperty: {
                        let input = buildPropertyInput(formState)
                        if let index = editingIndex {
                            repository.updateProperty(at: index, with: input)
                            onComplete()
                        } else {
                            repository.addProperty(input)
                            showSuccess = true
                        }
                    }
                )
            }
            .background(Color.surfaceWhite)
            .onAppear {
                if let initial = initialFormState {
                    formState = initial
                }
            }
        }
    }
}

// MARK: - Bottom CTA Bar

private struct BottomCtaBar: View {
    let currentStep: Int
    let formState: OnboardingFormState
    var isEditMode: Bool = false
    let onContinue: () -> Void
    let onAddProperty: () -> Void

    private var isStep1Valid: Bool {
        !formState.city.isEmpty && !formState.locality.isEmpty
    }

    private var isStep2Valid: Bool {
        formState.usageType != nil &&
        !formState.purchasePrice.isEmpty &&
        !formState.purchaseYear.isEmpty
    }

    private var isEnabled: Bool { currentStep == 1 ? isStep1Valid : isStep2Valid }
    private var buttonText: String {
        if currentStep == 1 { return "Continue" }
        return isEditMode ? "Save Changes" : "Add Property"
    }

    var body: some View {
        Button(action: currentStep == 1 ? onContinue : onAddProperty) {
            Text(buttonText)
                .font(Typography.bodyLarge)
                .foregroundColor(isEnabled ? .surfaceWhite : .textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: Spacing.widgetsM + Spacing.xxl)
                .background(isEnabled ? Color.brandPrimary : Color.formFieldBorder)
                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
        }
        .disabled(!isEnabled)
        .padding(.horizontal, Spacing.xxxl)
        .padding(.vertical, Spacing.xxl)
        .background(Color.surfaceWhite)
    }
}

// MARK: - Success Screen

private enum SuccessPhase {
    case calculating, generating, success
}

private struct SuccessView: View {
    let formState: OnboardingFormState
    let onComplete: () -> Void

    @State private var phase: SuccessPhase = .calculating
    @State private var countdown = 3
    @State private var progress: CGFloat = 0

    var body: some View {
        VStack {
            Spacer()

            if phase != .success {
                VStack(spacing: Spacing.xxxxl) {
                    Text(phase == .calculating ? "Calculating networth..." : "Generating insights...")
                        .font(Typography.titleSmall)
                        .foregroundColor(.textPrimary)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: Radius.full)
                                .fill(Color.formFieldBorder)
                                .frame(height: Spacing.l)
                            RoundedRectangle(cornerRadius: Radius.full)
                                .fill(Color.brandPrimary)
                                .frame(width: geo.size.width * progress, height: Spacing.l)
                                .animation(.easeInOut(duration: 1.5), value: progress)
                        }
                    }
                    .frame(height: Spacing.l)

                    Spacer().frame(height: Spacing.xxl)

                    PropertyPreviewCardView(
                        propertyName: buildPropertyName(formState),
                        societyName: formState.societyName.isEmpty ? formState.locality : formState.societyName
                    )
                }
                .transition(.opacity)
            }

            if phase == .success {
                VStack(spacing: Spacing.xxxxl) {
                    // Green checkmark
                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.surfaceWhite)
                        .frame(width: 64, height: 64)
                        .background(Color.successGreen)
                        .clipShape(Circle())

                    Text("Your real-estate wealth is ready!")
                        .font(Typography.titleSmall)
                        .foregroundColor(.textPrimary)

                    PropertyPreviewCardView(
                        propertyName: buildPropertyName(formState),
                        societyName: formState.societyName.isEmpty ? formState.locality : formState.societyName,
                        status: formState.usageType?.rawValue ?? "",
                        invested: formatPurchasePrice(formState.purchasePrice),
                        purchaseDate: formState.purchaseYear,
                        isExpanded: true
                    )

                    Spacer().frame(height: Spacing.l)

                    Text("Taking you to portfolio in \(countdown)")
                        .font(Typography.bodySmall)
                        .foregroundColor(.textSecondary)
                }
                .transition(.opacity)
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.xxxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(phase == .success ? Color.successScreenBg : Color.surfaceWhite)
        .animation(.easeInOut(duration: 0.5), value: phase)
        .task {
            progress = 0.5
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            phase = .generating
            progress = 0.85
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            phase = .success
            progress = 1.0
            for _ in 0..<3 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                countdown -= 1
            }
            onComplete()
        }
    }
}

// MARK: - Helpers

private func buildPropertyName(_ form: OnboardingFormState) -> String {
    var result = ""
    if let fp = form.floorPlan { result += "\(fp.rawValue) " }
    result += "Apartment"
    if !form.areaSqft.isEmpty { result += ", \(form.areaSqft) sq.ft" }
    return result
}

private func buildPropertyInput(_ form: OnboardingFormState) -> PropertyInput {
    var autoName = ""
    if let fp = form.floorPlan { autoName += "\(fp.rawValue) " }
    let location = form.societyName.isEmpty ? form.locality : form.societyName
    if !location.isEmpty { autoName += "in \(location)" }
    if autoName.isEmpty { autoName = "My Property" }

    return PropertyInput(
        projectName: form.customName.isEmpty ? autoName : form.customName,
        city: form.city,
        locality: form.locality,
        areaSqft: Int(form.areaSqft) ?? 0,
        purchasePrice: Int64(form.purchasePrice.replacingOccurrences(of: ",", with: "")) ?? 0,
        purchaseYear: Int(form.purchaseYear) ?? 2024,
        monthlyRent: form.usageType == .rentLease
            ? Int(form.monthlyRent.replacingOccurrences(of: ",", with: "")) ?? 0
            : 0,
        societyName: form.societyName,
        floorPlan: form.floorPlan,
        customName: form.customName,
        purchaseMonth: form.purchaseMonth,
        usageType: form.usageType
    )
}

private func formatPurchasePrice(_ priceStr: String) -> String {
    guard let price = Double(priceStr.replacingOccurrences(of: ",", with: "")) else { return priceStr }
    return Formatters.formatAmount(price)
}
