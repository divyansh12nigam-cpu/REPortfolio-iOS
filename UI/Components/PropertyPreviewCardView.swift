import SwiftUI

/// Compact preview card shown in Step 2 header and success screen.
struct PropertyPreviewCardView: View {
    let propertyName: String
    let societyName: String
    var status: String = ""
    var invested: String = ""
    var purchaseDate: String = ""
    var isExpanded: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            if isExpanded && !status.isEmpty {
                Text(status)
                    .font(Typography.bodySmall)
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity)
                Divider()
                    .foregroundColor(.borderSubtle)
                    .padding(.horizontal, Spacing.widgetsM)
                    .padding(.vertical, Spacing.s)
            }

            Text(propertyName)
                .font(Typography.titleSmall)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: isExpanded ? .infinity : nil, alignment: isExpanded ? .center : .leading)

            Text(isExpanded ? "in \(societyName)" : societyName)
                .font(Typography.bodySmallThin)
                .foregroundColor(.textSecondary)
                .frame(maxWidth: isExpanded ? .infinity : nil, alignment: isExpanded ? .center : .leading)
                .padding(.top, Spacing.s)

            if isExpanded && !invested.isEmpty {
                HStack {
                    VStack(alignment: .leading) {
                        Text(invested).font(Typography.bodyLarge).foregroundColor(.textPrimary)
                        Text("Invested").font(Typography.bodySmall).foregroundColor(.textSecondary)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text(purchaseDate).font(Typography.bodyLarge).foregroundColor(.textPrimary)
                        Text("Purchased on").font(Typography.bodySmall).foregroundColor(.textSecondary)
                    }
                }
                .padding(.top, Spacing.xxl)
            }
        }
        .padding(Spacing.xxl)
        .frame(maxWidth: .infinity, alignment: isExpanded ? .center : .leading)
        .background(isExpanded ? Color.surfaceWhite : Color.formFieldBg)
        .clipShape(RoundedRectangle(cornerRadius: Radius.element))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.element)
                .stroke(Color.formFieldBorder, lineWidth: 1)
        )
    }
}
