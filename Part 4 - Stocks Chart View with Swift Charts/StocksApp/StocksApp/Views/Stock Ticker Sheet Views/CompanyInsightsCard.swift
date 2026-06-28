//
//  CompanyInsightsCard.swift
//  StocksApp
//
//  Created by Codex on 28/06/26.
//

import SwiftUI

struct CompanyInsightsCard: View {
    
    let companyName: String
    let summary: String
    let positives: [String]
    let watchItems: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Investment Highlights")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color(uiColor: .label))
            
            Text(summary)
                .font(.caption)
                .lineSpacing(3)
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .fixedSize(horizontal: false, vertical: true)
            
            insightSection(
                title: "What investors like",
                symbol: "✓",
                symbolColor: .green,
                items: positives
            )
            
            insightSection(
                title: "Things to watch",
                symbol: "◉",
                symbolColor: .accentColor,
                items: watchItems
            )
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
    }
    
    private func insightSection(
        title: String,
        symbol: String,
        symbolColor: Color,
        items: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(Color(uiColor: .label))
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(items.prefix(3).enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .firstTextBaseline, spacing: 7) {
                        Text(symbol)
                            .font(.caption.weight(.bold))
                            .foregroundColor(symbolColor)
                            .frame(width: 14, alignment: .center)
                        
                        Text(item)
                            .font(.caption)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

struct CompanyInsightsCard_Previews: PreviewProvider {
    
    static var previews: some View {
        CompanyInsightsCard(
            companyName: "D-Wave Quantum",
            summary: "D-Wave is an early quantum computing company focused on solving complex optimization problems.",
            positives: [
                "Early player in quantum computing",
                "Focuses on real-world optimization problems",
                "Works with enterprise and government customers"
            ],
            watchItems: [
                "Quantum computing adoption is still early",
                "Revenue growth and customer wins remain important"
            ]
        )
        .padding()
        .background(Color(uiColor: .systemBackground))
        .previewLayout(.sizeThatFits)
    }
}
