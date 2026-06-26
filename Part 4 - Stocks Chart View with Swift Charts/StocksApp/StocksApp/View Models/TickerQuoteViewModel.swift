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
    var quote: Quote? { phase.value }
    var error: Error? { phase.error }
    
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
                phase = .success(await quoteWithFiftyTwoWeekRangeIfNeeded(quote))
            } else {
                phase = .empty
            }
        } catch {
            error.logForDebug(context: "TickerQuoteViewModel.fetchQuote")
            await fetchQuoteFromChartData(fallbackError: error)
        }
    }
    
    private func fetchQuoteFromChartData(fallbackError: Error) async {
        do {
            guard let chartData = try await stocksAPI.fetchChartData(tickerSymbol: ticker.symbol, range: .oneDay),
                  let fallbackQuote = makeFallbackQuote(from: chartData)
            else {
                phase = .failure(fallbackError)
                return
            }
            
            phase = .success(await quoteWithFiftyTwoWeekRangeIfNeeded(fallbackQuote))
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
    
    private func copyQuote(_ quote: Quote, fiftyTwoWeekLow: Double?, fiftyTwoWeekHigh: Double?) -> Quote {
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
            regularMarketVolume: quote.regularMarketVolume,
            trailingPE: quote.trailingPE,
            marketCap: quote.marketCap,
            fiftyTwoWeekLow: fiftyTwoWeekLow,
            fiftyTwoWeekHigh: fiftyTwoWeekHigh,
            averageDailyVolume3Month: quote.averageDailyVolume3Month,
            trailingAnnualDividendYield: quote.trailingAnnualDividendYield,
            epsTrailingTwelveMonths: quote.epsTrailingTwelveMonths
        )
    }
    
}
