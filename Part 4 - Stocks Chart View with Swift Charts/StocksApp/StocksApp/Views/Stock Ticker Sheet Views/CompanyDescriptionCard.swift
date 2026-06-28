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
    let description: String?
    
    private var marketValueText: String {
        guard marketCapText != "-" else { return "-" }
        return marketCapText.hasPrefix("$") ? marketCapText : "$\(marketCapText)"
    }
    
    private var employeeText: String {
        guard let fullTimeEmployees else { return "-" }
        let countText = Self.integerFormatter.string(from: NSNumber(value: fullTimeEmployees)) ?? "-"
        return "\(countText) employees"
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
        
        return symbols.isEmpty ? "-" : symbols.joined(separator: " • ")
    }
    
    private var summaryText: String? {
        description?.shortCompanySummary(companyName: companyName)
    }
    
    private static let integerFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(companyName) at a Glance")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color(uiColor: .label))
            
            if let summaryText {
                Text(summaryText)
                    .font(.caption)
                    .lineSpacing(3)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: false)
            }
            
            VStack(spacing: 8) {
                factRow(title: "Market Value", value: marketValueText)
                factRow(title: "Industry", value: industryText)
                factRow(title: "Company Size", value: employeeText)
                factRow(title: "Similar Companies", value: comparableStocksText)
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
                comparableStocks: ["MSFT", "GOOGL", "META", "AMZN"],
                description: "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide. The company offers iPhone, Mac, iPad, Apple Watch, AirPods, and services."
            )
            
            CompanyDescriptionCard(
                companyName: "Example",
                marketCapText: "-",
                industry: nil,
                fullTimeEmployees: nil,
                comparableStocks: [],
                description: nil
            )
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .previewLayout(.sizeThatFits)
    }
}

private extension String {
    
    func shortCompanySummary(companyName: String) -> String? {
        let cleanedText = simplifiedCompanyDescription
        guard !cleanedText.isEmpty else { return nil }
        
        let firstSentence = cleanedText.companyDescriptionSentences.first ?? cleanedText
        return firstSentence
            .replacingOccurrences(of: "The company", with: companyName, options: .caseInsensitive)
            .condensedCompanySentence(maxLength: 170)
    }
    
    private var simplifiedCompanyDescription: String {
        var text = trimmingCharacters(in: .whitespacesAndNewlines)
        let replacements = [
            ("designs, manufactures, and markets", "makes and sells"),
            ("designs, manufactures, and sells", "makes and sells"),
            ("designs, develops, and sells", "makes and sells"),
            ("develops, manufactures, and markets", "makes and sells"),
            ("engages in the development and delivery of", "develops and delivers"),
            ("manufactures and markets", "makes and sells"),
            ("personal computers", "computers"),
            ("smartphones", "phones"),
            ("worldwide", "")
        ]
        
        for (formalPhrase, plainPhrase) in replacements {
            text = text.replacingOccurrences(
                of: formalPhrase,
                with: plainPhrase,
                options: [.caseInsensitive, .diacriticInsensitive]
            )
        }
        
        return text
            .replacingOccurrences(of: " ,", with: ",")
            .replacingOccurrences(of: " .", with: ".")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var companyDescriptionSentences: [String] {
        let protectedText = replacingCommonAbbreviationsForSentenceSplitting
        
        return protectedText
            .components(separatedBy: ". ")
            .map { sentence in
                let restoredSentence = sentence
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .restoringCommonAbbreviationsAfterSentenceSplitting
                guard !restoredSentence.isEmpty else { return "" }
                return restoredSentence.hasSuffix(".") ? restoredSentence : "\(restoredSentence)."
            }
            .filter { !$0.isEmpty }
    }
    
    private var replacingCommonAbbreviationsForSentenceSplitting: String {
        replacingOccurrences(of: "Inc.", with: "Inc<period>")
            .replacingOccurrences(of: "Corp.", with: "Corp<period>")
            .replacingOccurrences(of: "Co.", with: "Co<period>")
            .replacingOccurrences(of: "Ltd.", with: "Ltd<period>")
            .replacingOccurrences(of: "U.S.", with: "U<period>S<period>")
    }
    
    private var restoringCommonAbbreviationsAfterSentenceSplitting: String {
        replacingOccurrences(of: "Inc<period>", with: "Inc.")
            .replacingOccurrences(of: "Corp<period>", with: "Corp.")
            .replacingOccurrences(of: "Co<period>", with: "Co.")
            .replacingOccurrences(of: "Ltd<period>", with: "Ltd.")
            .replacingOccurrences(of: "U<period>S<period>", with: "U.S.")
    }
    
    private func condensedCompanySentence(maxLength: Int) -> String {
        let trimmedText = trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedText.count > maxLength else { return trimmedText }
        
        let prefixText = String(trimmedText.prefix(maxLength))
        if let boundaryRange = prefixText.rangeOfCharacter(from: CharacterSet(charactersIn: ",;"), options: .backwards) {
            return "\(prefixText[..<boundaryRange.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines))."
        }
        
        if let spaceRange = prefixText.range(of: " ", options: .backwards) {
            return "\(prefixText[..<spaceRange.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines))."
        }
        
        return "\(prefixText)."
    }
}
