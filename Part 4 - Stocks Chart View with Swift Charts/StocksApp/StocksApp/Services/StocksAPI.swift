//
//  StocksAPI.swift
//  StocksApp
//
//  Created by Alfian Losari on 01/10/22.
//

import Foundation
import XCAStocksAPI

protocol StocksAPI {
    func searchTickers(query: String, isEquityTypeOnly: Bool) async throws -> [Ticker]
    func fetchQuotes(symbols: String) async throws -> [Quote]
    func fetchChartData(tickerSymbol: String, range: ChartRange) async throws -> ChartData?
    func fetchQuoteSupplement(symbol: String) async throws -> QuoteSupplement?
}

struct QuoteSupplement {
    
    let regularMarketVolume: Double?
    let trailingPE: Double?
    let marketCap: Double?
    let averageDailyVolume3Month: Double?
    let epsTrailingTwelveMonths: Double?
    let companyDescription: String?
    let industry: String?
    let fullTimeEmployees: Int?
    let comparableStocks: [String]
    
}

extension XCAStocksAPI: StocksAPI {
    
    func fetchQuoteSupplement(symbol: String) async throws -> QuoteSupplement? {
        let quoteSupplement = try? await fetchQuoteEndpointSupplement(symbol: symbol)
        let quoteListSupplement = try? await fetchQuoteListEndpointSupplement(symbol: symbol)
        let chartSupplement = try? await fetchChartEndpointSupplement(symbol: symbol)
        let publicCompanyFacts = try? await fetchPublicCompanyFacts(symbol: symbol)
        let publicMarketCap = try? await fetchPublicMarketCap(symbol: symbol)
        let comparableStocks = (try? await fetchComparableStockSymbols(symbol: symbol)) ?? []
        
        guard quoteSupplement != nil || quoteListSupplement != nil || chartSupplement != nil || publicCompanyFacts != nil || publicMarketCap != nil || !comparableStocks.isEmpty else {
            return nil
        }
        
        return QuoteSupplement(
            regularMarketVolume: quoteSupplement?.regularMarketVolume ?? quoteListSupplement?.regularMarketVolume ?? chartSupplement?.regularMarketVolume,
            trailingPE: quoteSupplement?.trailingPE ?? quoteListSupplement?.trailingPE,
            marketCap: quoteSupplement?.marketCap ?? quoteListSupplement?.marketCap ?? publicMarketCap,
            averageDailyVolume3Month: quoteSupplement?.averageDailyVolume3Month ?? quoteListSupplement?.averageDailyVolume3Month ?? chartSupplement?.averageDailyVolume3Month,
            epsTrailingTwelveMonths: quoteSupplement?.epsTrailingTwelveMonths ?? quoteListSupplement?.epsTrailingTwelveMonths,
            companyDescription: quoteSupplement?.companyDescription ?? publicCompanyFacts?.description,
            industry: quoteSupplement?.industry ?? publicCompanyFacts?.industry,
            fullTimeEmployees: quoteSupplement?.fullTimeEmployees ?? publicCompanyFacts?.fullTimeEmployees,
            comparableStocks: quoteSupplement?.comparableStocks.isEmpty == false ? quoteSupplement?.comparableStocks ?? [] : comparableStocks
        )
    }
    
    private func fetchQuoteEndpointSupplement(symbol: String) async throws -> QuoteSupplement? {
        guard var components = URLComponents(string: "https://query2.finance.yahoo.com/v10/finance/quoteSummary/\(symbol)") else {
            return nil
        }
        
        components.queryItems = [
            URLQueryItem(name: "modules", value: "price,summaryDetail,defaultKeyStatistics,assetProfile")
        ]
        
        guard let url = components.url else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(QuoteSummarySupplementResponse.self, from: data)
        return response.supplement
    }
    
    private func fetchQuoteListEndpointSupplement(symbol: String) async throws -> QuoteSupplement? {
        guard var components = URLComponents(string: "https://query1.finance.yahoo.com/v7/finance/quote") else {
            return nil
        }
        
        components.queryItems = [
            URLQueryItem(name: "symbols", value: symbol)
        ]
        
        guard let url = components.url else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(QuoteListSupplementResponse.self, from: data)
        return response.supplement
    }
    
    private func fetchChartEndpointSupplement(symbol: String) async throws -> QuoteSupplement? {
        let intradaySupplement = try? await fetchChartSupplement(symbol: symbol, range: .oneDay)
        let recentDailySupplement = try? await fetchChartSupplement(symbol: symbol, range: .threeMonth, interval: "1d")
        
        guard intradaySupplement != nil || recentDailySupplement != nil else {
            return nil
        }
        
        return QuoteSupplement(
            regularMarketVolume: intradaySupplement?.regularMarketVolume ?? recentDailySupplement?.regularMarketVolume,
            trailingPE: nil,
            marketCap: nil,
            averageDailyVolume3Month: recentDailySupplement?.averageDailyVolume3Month,
            epsTrailingTwelveMonths: nil,
            companyDescription: nil,
            industry: nil,
            fullTimeEmployees: nil,
            comparableStocks: []
        )
    }
    
    private func fetchChartSupplement(symbol: String, range: ChartRange, interval: String? = nil) async throws -> QuoteSupplement? {
        guard var components = URLComponents(string: "https://query1.finance.yahoo.com/v8/finance/chart/\(symbol)") else {
            return nil
        }
        
        components.queryItems = [
            URLQueryItem(name: "range", value: range.rawValue),
            URLQueryItem(name: "interval", value: interval ?? range.interval),
            URLQueryItem(name: "indicators", value: "quote"),
            URLQueryItem(name: "includeTimestamps", value: "true")
        ]
        
        guard let url = components.url else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ChartSupplementResponse.self, from: data)
        return response.supplement
    }
    
    private func fetchPublicCompanyFacts(symbol: String) async throws -> StockAnalysisCompanyFacts? {
        let normalizedSymbol = symbol.lowercased()
            .replacingOccurrences(of: ".", with: "-")
            .replacingOccurrences(of: "^", with: "")
        
        guard let url = URL(string: "https://stockanalysis.com/stocks/\(normalizedSymbol)/company/") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let html = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return html.stockAnalysisCompanyFacts
    }
    
    private func fetchPublicMarketCap(symbol: String) async throws -> Double? {
        let normalizedSymbol = symbol.lowercased()
            .replacingOccurrences(of: ".", with: "-")
            .replacingOccurrences(of: "^", with: "")
        
        guard let url = URL(string: "https://stockanalysis.com/stocks/\(normalizedSymbol)/") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let html = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return html.stockAnalysisMarketCap
    }
    
    private func fetchComparableStockSymbols(symbol: String) async throws -> [String] {
        guard let url = URL(string: "https://query2.finance.yahoo.com/v6/finance/recommendationsbysymbol/\(symbol)") else {
            return []
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ComparableStocksResponse.self, from: data)
        return response.symbols
    }
    
}

private extension String {
    
    var stockAnalysisCompanyFacts: StockAnalysisCompanyFacts? {
        let description = stockAnalysisCompanyDescription
        let industry = stockAnalysisStringValue(after: "industry:{value:\"")
        let fullTimeEmployees = stockAnalysisIntegerValue(after: "employees:{value:")
        
        guard description != nil || industry != nil || fullTimeEmployees != nil else {
            return nil
        }
        
        return StockAnalysisCompanyFacts(
            description: description,
            industry: industry,
            fullTimeEmployees: fullTimeEmployees
        )
    }
    
    var stockAnalysisMarketCap: Double? {
        guard let marketCapText = stockAnalysisStringValue(after: "marketCap:\"") else {
            return nil
        }
        
        return marketCapText.abbreviatedFinancialValue
    }
    
    private var stockAnalysisCompanyDescription: String? {
        guard let encodedDescription = encodedStockAnalysisDescription else { return nil }
        return encodedDescription.decodedStockAnalysisHTMLText
    }
    
    private var encodedStockAnalysisDescription: String? {
        let marker = "description:\"\\u003Cp"
        guard let markerRange = range(of: marker) else {
            return nil
        }
        
        var index = index(markerRange.lowerBound, offsetBy: "description:\"".count)
        var encodedDescription = ""
        var isEscaped = false
        
        while index < endIndex {
            let character = self[index]
            
            if character == "\"" && !isEscaped {
                return encodedDescription
            }
            
            encodedDescription.append(character)
            
            if character == "\\" {
                isEscaped.toggle()
            } else {
                isEscaped = false
            }
            
            index = self.index(after: index)
        }
        
        return nil
    }
    
    private var strippingHTMLTags: String {
        replacingOccurrences(
            of: "<[^>]+>",
            with: " ",
            options: .regularExpression
        )
    }
    
    private var decodedStockAnalysisHTMLText: String? {
        guard let data = "\"\(self)\"".data(using: .utf8),
              let htmlText = try? JSONDecoder().decode(String.self, from: data)
        else {
            return nil
        }
        
        return htmlText
            .replacingOccurrences(of: "</p><p>", with: " ")
            .replacingOccurrences(of: "<br>", with: " ")
            .strippingHTMLTags
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func stockAnalysisStringValue(after marker: String) -> String? {
        guard let markerRange = range(of: marker) else { return nil }
        let startIndex = markerRange.upperBound
        guard let endRange = self[startIndex...].range(of: "\"") else { return nil }
        let value = String(self[startIndex..<endRange.lowerBound])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
    
    private func stockAnalysisIntegerValue(after marker: String) -> Int? {
        guard let markerRange = range(of: marker) else { return nil }
        let startIndex = markerRange.upperBound
        var endIndex = startIndex
        
        while endIndex < self.endIndex, self[endIndex].isNumber {
            endIndex = index(after: endIndex)
        }
        
        guard startIndex < endIndex else { return nil }
        return Int(self[startIndex..<endIndex])
    }
    
    private var abbreviatedFinancialValue: Double? {
        let trimmedText = trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return nil }
        
        let suffix = trimmedText.last
        let multiplier: Double
        let numericText: String
        
        switch suffix {
        case "K", "k":
            multiplier = 1_000
            numericText = String(trimmedText.dropLast())
        case "M", "m":
            multiplier = 1_000_000
            numericText = String(trimmedText.dropLast())
        case "B", "b":
            multiplier = 1_000_000_000
            numericText = String(trimmedText.dropLast())
        case "T", "t":
            multiplier = 1_000_000_000_000
            numericText = String(trimmedText.dropLast())
        default:
            multiplier = 1
            numericText = trimmedText
        }
        
        guard let value = Double(numericText.replacingOccurrences(of: ",", with: "")) else {
            return nil
        }
        
        return value * multiplier
    }
}

private struct StockAnalysisCompanyFacts {
    let description: String?
    let industry: String?
    let fullTimeEmployees: Int?
}

private struct QuoteSummarySupplementResponse: Decodable {
    
    let supplement: QuoteSupplement?
    
    enum CodingKeys: CodingKey {
        case quoteSummary
    }
    
    enum QuoteSummaryKeys: CodingKey {
        case result
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let summary = try container.nestedContainer(keyedBy: QuoteSummaryKeys.self, forKey: .quoteSummary)
        let result = try summary.decodeIfPresent([QuoteSummaryResult].self, forKey: .result)?.first
        supplement = result?.supplement
    }
    
}

private struct QuoteSummaryResult: Decodable {
    
    let price: QuoteSummaryPrice?
    let summaryDetail: QuoteSummaryDetail?
    let defaultKeyStatistics: QuoteSummaryKeyStatistics?
    let assetProfile: QuoteSummaryAssetProfile?
    
    var supplement: QuoteSupplement {
        QuoteSupplement(
            regularMarketVolume: summaryDetail?.volume?.raw,
            trailingPE: summaryDetail?.trailingPE?.raw,
            marketCap: price?.marketCap?.raw,
            averageDailyVolume3Month: summaryDetail?.averageVolume?.raw,
            epsTrailingTwelveMonths: defaultKeyStatistics?.trailingEps?.raw,
            companyDescription: assetProfile?.longBusinessSummary,
            industry: assetProfile?.industry,
            fullTimeEmployees: assetProfile?.fullTimeEmployees,
            comparableStocks: []
        )
    }
    
}

private struct QuoteSummaryPrice: Decodable {
    let marketCap: QuoteSummaryRawValue?
}

private struct QuoteSummaryDetail: Decodable {
    let volume: QuoteSummaryRawValue?
    let trailingPE: QuoteSummaryRawValue?
    let averageVolume: QuoteSummaryRawValue?
}

private struct QuoteSummaryKeyStatistics: Decodable {
    let trailingEps: QuoteSummaryRawValue?
}

private struct QuoteSummaryRawValue: Decodable {
    let raw: Double?
}

private struct QuoteSummaryAssetProfile: Decodable {
    let longBusinessSummary: String?
    let industry: String?
    let fullTimeEmployees: Int?
}

private struct QuoteListSupplementResponse: Decodable {
    
    let supplement: QuoteSupplement?
    
    enum CodingKeys: CodingKey {
        case quoteResponse
    }
    
    enum QuoteResponseKeys: CodingKey {
        case result
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let quoteResponse = try container.nestedContainer(keyedBy: QuoteResponseKeys.self, forKey: .quoteResponse)
        let result = try quoteResponse.decodeIfPresent([QuoteListSupplementResult].self, forKey: .result)?.first
        supplement = result?.supplement
    }
    
}

private struct QuoteListSupplementResult: Decodable {
    
    let regularMarketVolume: Double?
    let trailingPE: Double?
    let marketCap: Double?
    let averageDailyVolume3Month: Double?
    let epsTrailingTwelveMonths: Double?
    
    var supplement: QuoteSupplement {
        QuoteSupplement(
            regularMarketVolume: regularMarketVolume,
            trailingPE: trailingPE,
            marketCap: marketCap,
            averageDailyVolume3Month: averageDailyVolume3Month,
            epsTrailingTwelveMonths: epsTrailingTwelveMonths,
            companyDescription: nil,
            industry: nil,
            fullTimeEmployees: nil,
            comparableStocks: []
        )
    }
    
}

private struct ChartSupplementResponse: Decodable {
    
    let supplement: QuoteSupplement?
    
    enum CodingKeys: CodingKey {
        case chart
    }
    
    enum ChartKeys: CodingKey {
        case result
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let chart = try container.nestedContainer(keyedBy: ChartKeys.self, forKey: .chart)
        let result = try chart.decodeIfPresent([ChartSupplementResult].self, forKey: .result)?.first
        supplement = result?.supplement
    }
    
}

private struct ChartSupplementResult: Decodable {
    
    let meta: ChartSupplementMeta?
    let indicators: ChartSupplementIndicators?
    
    var supplement: QuoteSupplement {
        QuoteSupplement(
            regularMarketVolume: meta?.regularMarketVolume ?? indicators?.quote.first?.volume?.compactMap { $0 }.last,
            trailingPE: nil,
            marketCap: nil,
            averageDailyVolume3Month: averageDailyVolume,
            epsTrailingTwelveMonths: nil,
            companyDescription: nil,
            industry: nil,
            fullTimeEmployees: nil,
            comparableStocks: []
        )
    }
    
    private var averageDailyVolume: Double? {
        let volumes = indicators?.quote.first?.volume?.compactMap { $0 }.filter { $0 > 0 } ?? []
        
        guard !volumes.isEmpty else {
            return nil
        }
        
        return volumes.reduce(0, +) / Double(volumes.count)
    }
    
}

private struct ChartSupplementMeta: Decodable {
    let regularMarketVolume: Double?
}

private struct ChartSupplementIndicators: Decodable {
    let quote: [ChartSupplementQuote]
}

private struct ChartSupplementQuote: Decodable {
    let volume: [Double?]?
}

private struct ComparableStocksResponse: Decodable {
    
    let symbols: [String]
    
    enum CodingKeys: CodingKey {
        case finance
    }
    
    enum FinanceKeys: CodingKey {
        case result
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let finance = try container.nestedContainer(keyedBy: FinanceKeys.self, forKey: .finance)
        let result = try finance.decodeIfPresent([ComparableStocksResult].self, forKey: .result)?.first
        symbols = result?.recommendedSymbols.map(\.symbol) ?? []
    }
    
}

private struct ComparableStocksResult: Decodable {
    let recommendedSymbols: [ComparableStockSymbol]
}

private struct ComparableStockSymbol: Decodable {
    let symbol: String
}
