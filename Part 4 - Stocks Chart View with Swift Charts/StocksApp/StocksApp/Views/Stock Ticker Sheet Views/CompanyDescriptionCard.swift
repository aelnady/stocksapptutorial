//
//  CompanyDescriptionCard.swift
//  StocksApp
//
//  Created by Codex on 28/06/26.
//

import SwiftUI

struct CompanyDescriptionCard: View {
    
    let companyName: String
    let marketCapText: String
    let industry: String?
    let fullTimeEmployees: Int?
    let comparableStocks: [String]
    
    private var employeeText: String {
        guard let fullTimeEmployees else { return "-" }
        return Self.integerFormatter.string(from: NSNumber(value: fullTimeEmployees)) ?? "-"
    }
    
    private var industryText: String {
        let trimmedIndustry = industry?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedIndustry?.isEmpty == false ? trimmedIndustry ?? "-" : "-"
    }
    
    private var comparableStocksText: String {
        let symbols = comparableStocks
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .prefix(6)
        
        return symbols.isEmpty ? "-" : symbols.joined(separator: ", ")
    }
    
    private static let integerFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(companyName)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color(uiColor: .label))
            
            VStack(spacing: 8) {
                factRow(title: "Market Capital", value: marketCapText)
                factRow(title: "Industry", value: industryText)
                factRow(title: "Employees", value: employeeText)
                factRow(title: "Comparable Stocks", value: comparableStocksText)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
    }
    
    private func factRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundColor(Color(uiColor: .label))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

struct CompanyDescriptionCard_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            CompanyDescriptionCard(
                companyName: "Apple",
                marketCapText: "2.30T",
                industry: "Consumer Electronics",
                fullTimeEmployees: 164_000,
                comparableStocks: ["MSFT", "GOOGL", "META", "AMZN"]
            )
            
            CompanyDescriptionCard(
                companyName: "Example",
                marketCapText: "-",
                industry: nil,
                fullTimeEmployees: nil,
                comparableStocks: []
            )
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .previewLayout(.sizeThatFits)
    }
}
