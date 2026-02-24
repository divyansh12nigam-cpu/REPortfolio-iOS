import SwiftUI

struct StepProgressHeaderView: View {
    let currentStep: Int
    let totalSteps: Int
    var title: String = ""
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.xxl)
                    .padding(.top, Spacing.xxl)
                    .padding(.bottom, Spacing.l)
            }

            // Back arrow + step indicator
            HStack(spacing: Spacing.l) {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .frame(width: Spacing.widgetsXs, height: Spacing.widgetsXs)
                        .overlay(
                            Circle().stroke(Color.borderSubtle, lineWidth: 1)
                        )
                }

                Text("STEP \(currentStep) OF \(totalSteps)")
                    .font(Typography.overline)
                    .tracking(0.88)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.xxl)
            .padding(.vertical, Spacing.xl)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.formFieldBorder)
                        .frame(height: Spacing.xs)
                    Rectangle()
                        .fill(Color.brandPrimary)
                        .frame(width: geo.size.width * CGFloat(currentStep) / CGFloat(totalSteps), height: Spacing.xs)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .frame(height: Spacing.xs)
        }
        .background(Color.surfaceWhite)
    }
}
