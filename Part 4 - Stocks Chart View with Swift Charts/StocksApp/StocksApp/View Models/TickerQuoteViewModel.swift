//
//  TickerQuoteViewModel.swift
//  StocksApp
//
//  Created by Alfian Losari on 16/10/22.
//

import Foundation
import SwiftUI
import XCAStocksAPI

@MainActor
class TickerQuoteViewModel: ObservableObject {
    
    @Published var phase = FetchPhase<Quote>.initial
    @Published var companyDescription: String?
    @Published var companyIndustry: String?
    @Published var fullTimeEmployees: Int?
    @Published var comparableStocks: [String] = []
    var quote: Quote? { phase.value }
    var error: Error? { phase.error }
    var companyInsight: CompanyInsight {
        CompanyInsight.placeholder(companyName: ticker.shortname ?? ticker.symbol, symbol: ticker.symbol)
    }
    
    let ticker: Ticker
    let stocksAPI: StocksAPI
    
    init(ticker: Ticker, stocksAPI: StocksAPI = XCAStocksAPI(), initialQuote: Quote? = nil) {
        self.ticker = ticker
        self.stocksAPI = stocksAPI
        if let initialQuote {
            self.phase = .success(initialQuote)
        }
    }
    
    func fetchQuote() async {
        phase = .fetching
        
        do {
            let response = try await stocksAPI.fetchQuotes(symbols: ticker.symbol)
            if let quote = response.first {
                phase = .success(await preparedQuote(quote))
            } else {
                phase = .empty
            }
        } catch {
            error.logForDebug(context: "TickerQuoteViewModel.fetchQuote")
            await fetchQuoteFromChartData(fallbackError: error)
        }
    }
    
    func enrichQuoteIfNeeded() async {
        guard let quote else { return }
        phase = .success(await preparedQuote(quote))
    }
    
    private func fetchQuoteFromChartData(fallbackError: Error) async {
        do {
            guard let chartData = try await stocksAPI.fetchChartData(tickerSymbol: ticker.symbol, range: .oneDay),
                  let fallbackQuote = makeFallbackQuote(from: chartData)
            else {
                phase = .failure(fallbackError)
                return
            }
            
            phase = .success(await preparedQuote(fallbackQuote))
        } catch {
            error.logForDebug(context: "TickerQuoteViewModel.fetchQuoteFromChartData")
            phase = .failure(fallbackError)
        }
    }
    
    private func makeFallbackQuote(from chartData: ChartData) -> Quote? {
        let price = chartData.meta.regularMarketPrice ?? chartData.indicators.last?.close
        let previousClose = chartData.meta.previousClose
        let change: Double?
        if let price, let previousClose {
            change = price - previousClose
        } else {
            change = nil
        }
        
        return Quote(
            symbol: ticker.symbol,
            currency: chartData.meta.currency.isEmpty ? nil : chartData.meta.currency,
            regularMarketPrice: price,
            regularMarketChange: change,
            regularMarketOpen: chartData.indicators.first?.open,
            regularMarketDayHigh: chartData.indicators.map(\.high).max(),
            regularMarketDayLow: chartData.indicators.map(\.low).min()
        )
    }
    
    private func preparedQuote(_ quote: Quote) async -> Quote {
        let supplementedQuote = await quoteWithSupplementIfNeeded(quote)
        return await quoteWithFiftyTwoWeekRangeIfNeeded(supplementedQuote)
    }
    
    private func quoteWithSupplementIfNeeded(_ quote: Quote) async -> Quote {
        guard quote.regularMarketVolume == nil ||
                quote.trailingPE == nil ||
                quote.marketCap == nil ||
                quote.averageDailyVolume3Month == nil ||
                quote.epsTrailingTwelveMonths == nil ||
                companyDescription == nil ||
                companyIndustry == nil ||
                fullTimeEmployees == nil ||
                comparableStocks.isEmpty
        else {
            return quote
        }
        
        do {
            guard let supplement = try await stocksAPI.fetchQuoteSupplement(symbol: ticker.symbol) else {
                return quote
            }
            
            companyDescription = supplement.companyDescription ?? companyDescription
            companyIndustry = supplement.industry ?? companyIndustry
            fullTimeEmployees = supplement.fullTimeEmployees ?? fullTimeEmployees
            if !supplement.comparableStocks.isEmpty {
                comparableStocks = supplement.comparableStocks
            }
            
            return copyQuote(
                quote,
                regularMarketVolume: quote.regularMarketVolume ?? supplement.regularMarketVolume,
                trailingPE: quote.trailingPE ?? supplement.trailingPE,
                marketCap: quote.marketCap ?? supplement.marketCap,
                averageDailyVolume3Month: quote.averageDailyVolume3Month ?? supplement.averageDailyVolume3Month,
                epsTrailingTwelveMonths: quote.epsTrailingTwelveMonths ?? supplement.epsTrailingTwelveMonths
            )
        } catch {
            error.logForDebug(context: "TickerQuoteViewModel.quoteWithSupplementIfNeeded")
            return quote
        }
    }
    
    private func quoteWithFiftyTwoWeekRangeIfNeeded(_ quote: Quote) async -> Quote {
        guard quote.fiftyTwoWeekLow == nil || quote.fiftyTwoWeekHigh == nil else {
            return quote
        }
        
        do {
            guard let range = try await fetchFiftyTwoWeekRange() else {
                return quote
            }
            
            return copyQuote(
                quote,
                fiftyTwoWeekLow: quote.fiftyTwoWeekLow ?? range.low,
                fiftyTwoWeekHigh: quote.fiftyTwoWeekHigh ?? range.high
            )
        } catch {
            error.logForDebug(context: "TickerQuoteViewModel.quoteWithFiftyTwoWeekRangeIfNeeded")
            return quote
        }
    }
    
    private func fetchFiftyTwoWeekRange() async throws -> (low: Double, high: Double)? {
        guard let chartData = try await stocksAPI.fetchChartData(tickerSymbol: ticker.symbol, range: .oneYear) else {
            return nil
        }
        
        guard let low = chartData.indicators.map(\.low).min(),
              let high = chartData.indicators.map(\.high).max(),
              high > low
        else {
            return nil
        }
        
        return (low, high)
    }
    
    private func copyQuote(
        _ quote: Quote,
        regularMarketVolume: Double? = nil,
        trailingPE: Double? = nil,
        marketCap: Double? = nil,
        fiftyTwoWeekLow: Double? = nil,
        fiftyTwoWeekHigh: Double? = nil,
        averageDailyVolume3Month: Double? = nil,
        epsTrailingTwelveMonths: Double? = nil
    ) -> Quote {
        Quote(
            symbol: quote.symbol,
            currency: quote.currency,
            marketState: quote.marketState,
            fullExchangeName: quote.fullExchangeName,
            displayName: quote.displayName,
            regularMarketPrice: quote.regularMarketPrice,
            regularMarketChange: quote.regularMarketChange,
            regularMarketChangePercent: quote.regularMarketChangePercent,
            regularMarketChangePreviousClose: quote.regularMarketChangePreviousClose,
            regularMarketTime: quote.regularMarketTime,
            postMarketPrice: quote.postMarketPrice,
            postMarketChange: quote.postMarketChange,
            regularMarketOpen: quote.regularMarketOpen,
            regularMarketDayHigh: quote.regularMarketDayHigh,
            regularMarketDayLow: quote.regularMarketDayLow,
            regularMarketVolume: regularMarketVolume ?? quote.regularMarketVolume,
            trailingPE: trailingPE ?? quote.trailingPE,
            marketCap: marketCap ?? quote.marketCap,
            fiftyTwoWeekLow: fiftyTwoWeekLow ?? quote.fiftyTwoWeekLow,
            fiftyTwoWeekHigh: fiftyTwoWeekHigh ?? quote.fiftyTwoWeekHigh,
            averageDailyVolume3Month: averageDailyVolume3Month ?? quote.averageDailyVolume3Month,
            trailingAnnualDividendYield: quote.trailingAnnualDividendYield,
            epsTrailingTwelveMonths: epsTrailingTwelveMonths ?? quote.epsTrailingTwelveMonths
        )
    }
    
}

struct CompanyInsight {
    
    let summary: String
    let positives: [String]
    let watchItems: [String]
    
    static func placeholder(companyName: String, symbol: String) -> CompanyInsight {
        let displayName = companyName
            .replacingOccurrences(of: " Inc.", with: "")
            .replacingOccurrences(of: " Corporation", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if symbol.uppercased() == "QBTS" {
            return CompanyInsight(
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
        }
        
        return CompanyInsight(
            summary: "\(displayName) is being watched by investors for its market position, growth potential, and recent business momentum.",
            positives: [
                "Has a clear business focus investors can follow",
                "May benefit if demand in its industry grows",
                "Comparable companies give investors a way to benchmark performance"
            ],
            watchItems: [
                "Future revenue growth and profitability remain important",
                "Stock performance can change quickly with news and market sentiment"
            ]
        )
    }
    
}
