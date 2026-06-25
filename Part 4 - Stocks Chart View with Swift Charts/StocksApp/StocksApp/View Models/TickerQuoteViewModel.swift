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
                phase = .success(quote)
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
            
            phase = .success(fallbackQuote)
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
    
}
