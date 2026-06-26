//
//  FiftyTwoWeekRangeView.swift
//  StocksApp
//
//  Created by Codex on 26/06/26.
//

import SwiftUI

struct FiftyTwoWeekRangeView: View {
    
    let currentPrice: Double
    let week52Low: Double
    let week52High: Double
    
    private var progress: Double {
        guard week52High > week52Low else { return 0 }
        let rawValue = (currentPrice - week52Low) / (week52High - week52Low)
        return min(max(rawValue, 0), 1)
    }
    
    private var percentText: String {
        progress.formatted(.percent.precision(.fractionLength(0)))
    }
    
    private var currentPriceText: String {
        Utils.format(value: currentPrice) ?? "-"
    }
    
    private var lowText: String {
        Utils.format(value: week52Low) ?? "-"
    }
    
    private var highText: String {
        Utils.format(value: week52High) ?? "-"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Text("52 Week Range")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(uiColor: .label))
                
                Spacer(minLength: 12)
                
                Text("\(percentText) of range")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color(uiColor: .tertiarySystemBackground), in: Capsule())
            }
            
            HStack(alignment: .top, spacing: 8) {
                Text(lowText)
                    .frame(width: 54, alignment: .leading)
                
                rangeBarView
                    .frame(height: 36)
                
                Text(highText)
                    .frame(width: 54, alignment: .trailing)
            }
            .font(.caption.weight(.bold))
            .foregroundColor(Color(uiColor: .label))
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: progress)
    }
    
    private var rangeBarView: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let markerRadius = 8.0
            let markerX = markerRadius + ((width - markerRadius * 2) * progress)
            let priceLabelX = min(max(markerX, 28), max(28, width - 28))
            
            ZStack(alignment: .topLeading) {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.red.opacity(0.75), .yellow.opacity(0.75), .green.opacity(0.75)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 7)
                    .position(x: width / 2, y: 9)
                
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 15, height: 15)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
                    .shadow(color: Color.black.opacity(0.18), radius: 3, y: 1)
                    .position(x: markerX, y: 9)
                
                Text(currentPriceText)
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .position(x: priceLabelX, y: 27)
            }
        }
        .accessibilityHidden(true)
    }
}

struct FiftyTwoWeekRangeView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            FiftyTwoWeekRangeView(currentPrice: 275.15, week52Low: 164.08, week52High: 294.29)
                .previewDisplayName("Light")
            
            FiftyTwoWeekRangeView(currentPrice: 275.15, week52Low: 164.08, week52High: 294.29)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
