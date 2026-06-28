//
//  StockTickerView.swift
//  StocksApp
//
//  Created by Alfian Losari on 16/10/22.
//

import SwiftUI
import XCAStocksAPI

struct StockTickerView: View {
    
    @StateObject var chartVM: ChartViewModel
    @StateObject var quoteVM: TickerQuoteViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView.padding(.horizontal)
            
            Divider()
                .padding(.vertical, 6)
                .padding(.horizontal)
            scrollView
        }
        .padding(.top)
        .background(Color(uiColor: .systemBackground))
        .task(id: chartVM.selectedRange.rawValue) {
            if quoteVM.quote == nil {
                await quoteVM.fetchQuote()
            } else {
                await quoteVM.enrichQuoteIfNeeded()
            }
            await chartVM.fetchData()
        }
    }
    
    private var scrollView: some View {
        ScrollView {
            priceDiffRowView
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                .padding(.horizontal)
            
            Divider()
            
            ZStack {
                DateRangePickerView(selectedRange: $chartVM.selectedRange)
                    .opacity(chartVM.selectedXOpacity)
                
                Text(chartVM.selectedXDateText)
                    .font(.headline)
                    .padding(.vertical, 4)
                    .padding(.horizontal)
            }
            
            
            Divider().opacity(chartVM.selectedXOpacity)
            
            chartView
                .padding(.horizontal)
                .frame(maxWidth: .infinity, minHeight: 220)
            
            periodRangeView
                .padding(.horizontal)
                .padding(.top, 12)
            
            fiftyTwoWeekRangeView
                .padding(.horizontal)
                .padding(.top, 10)
            
            volumeComparisonView
                .padding(.horizontal)
                .padding(.top, 10)
            
            CompanyDescriptionCard(
                companyName: companyDisplayName,
                marketCapText: quoteVM.quote?.mktCapText ?? "-",
                industry: quoteVM.companyIndustry,
                fullTimeEmployees: quoteVM.fullTimeEmployees,
                comparableStocks: quoteVM.comparableStocks,
                description: quoteVM.companyDescription
            )
            .padding(.horizontal)
            .padding(.top, 10)
            
            CompanyInsightsCard(
                companyName: companyDisplayName,
                summary: quoteVM.companyInsight.summary,
                positives: quoteVM.companyInsight.positives,
                watchItems: quoteVM.companyInsight.watchItems
            )
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 16)
                
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var chartView: some View {
        switch chartVM.fetchPhase {
        case .fetching: LoadingStateView()
        case .success(let data):
            ChartView(data: data, vm: chartVM)
        case .failure(let error):
            ErrorStateView(error: error.userFriendlyMessage)
        default: EmptyView()
        }
    }
    
    @ViewBuilder
    private var fiftyTwoWeekRangeView: some View {
        if let quote = quoteVM.quote,
           let currentPrice = quote.regularMarketPrice,
           let week52Low = quote.fiftyTwoWeekLow,
           let week52High = quote.fiftyTwoWeekHigh {
            FiftyTwoWeekRangeView(
                currentPrice: currentPrice,
                week52Low: week52Low,
                week52High: week52High
            )
        }
    }
    
    @ViewBuilder
    private var volumeComparisonView: some View {
        switch quoteVM.phase {
        case .fetching: LoadingStateView()
        case .failure(let error): ErrorStateView(error: error.userFriendlyMessage)
                .padding(.horizontal)
        case .success(let quote):
            VolumeComparisonView(
                volume: quote.regularMarketVolume,
                averageVolume: quote.averageDailyVolume3Month
            )
        default: EmptyView()
        }
    }
    
    private var priceDiffRowView: some View {
        HStack {
            if let currentPrice = currentPrice {
                priceDiffStackView(
                    price: Utils.format(value: currentPrice) ?? "-",
                    performance: periodPerformance(currentPrice: currentPrice)
                )
            }
            
            Spacer()
        }
        .animation(.easeInOut(duration: 0.25), value: chartVM.chart?.id)
        .animation(.easeInOut(duration: 0.25), value: chartVM.selectedRange.rawValue)
    }
    
    @ViewBuilder
    private var periodRangeView: some View {
        if let low = chartVM.periodLow,
           let high = chartVM.periodHigh,
           let currentPrice {
            SelectedPeriodRangeView(
                title: "\(chartVM.selectedRange.title) Range",
                currentPrice: currentPrice,
                periodLow: low,
                periodHigh: high
            )
        }
    }
    
    private func priceDiffStackView(price: String, performance: PeriodPerformance?) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .lastTextBaseline, spacing: 16) {
                Text(price).font(.headline.bold())
                
                Text(performance?.text ?? "-")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(performance?.color ?? Color(uiColor: .secondaryLabel))
            }
        }
    }
    
    private var currentPrice: Double? {
        quoteVM.quote?.regularMarketPrice ?? chartVM.chart?.items.last?.value
    }
    
    private var companyDisplayName: String {
        let name = quoteVM.ticker.shortname ?? quoteVM.ticker.symbol
        let suffixes = [
            " Inc.",
            " Incorporated",
            " Corporation",
            " Corp.",
            " Company",
            " Co.",
            " Ltd.",
            " Limited",
            " PLC",
            " plc"
        ]
        
        return suffixes.reduce(name) { currentName, suffix in
            currentName.hasSuffix(suffix) ? String(currentName.dropLast(suffix.count)) : currentName
        }
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func periodPerformance(currentPrice: Double) -> PeriodPerformance? {
        guard let startPrice = chartVM.chart?.periodSummary?.startPrice,
              startPrice != 0
        else {
            return nil
        }
        
        let change = currentPrice - startPrice
        let percent = change / startPrice * 100
        let changeText = signedPriceText(change)
        let percentText = String(format: "%+.2f%%", percent)
        return PeriodPerformance(
            text: "\(changeText) (\(percentText))",
            color: change < 0 ? .red : .green
        )
    }
    
    private func signedPriceText(_ value: Double) -> String {
        let formattedValue = Utils.format(value: abs(value)) ?? String(format: "%.2f", abs(value))
        return value < 0 ? "-\(formattedValue)" : "+\(formattedValue)"
    }
    
    private var headerView: some View {
        HStack(alignment: .lastTextBaseline, spacing: 8) {
            Text(quoteVM.ticker.symbol).font(.title.bold())
            if let shortName = quoteVM.ticker.shortname {
                let exchangeText = quoteVM.ticker.exchDisp.map { " (\($0))" } ?? ""
                Text("\(shortName)\(exchangeText)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .lineLimit(1)
            }
            Spacer()
        }
    }
}

private struct PeriodPerformance {
    
    let text: String
    let color: Color
    
}

private struct VolumeComparisonView: View {
    
    let volume: Double?
    let averageVolume: Double?
    
    private struct DisplayUnit {
        let threshold: Double
        let divisor: Double
        let suffix: String
    }
    
    private static let displayUnits = [
        DisplayUnit(threshold: 0, divisor: 1, suffix: ""),
        DisplayUnit(threshold: 1_000, divisor: 1_000, suffix: "K"),
        DisplayUnit(threshold: 100_000, divisor: 1_000_000, suffix: "M"),
        DisplayUnit(threshold: 100_000_000, divisor: 1_000_000_000, suffix: "B"),
        DisplayUnit(threshold: 100_000_000_000, divisor: 1_000_000_000_000, suffix: "T")
    ]
    
    private var ratio: Double? {
        guard let volume,
              let averageVolume,
              averageVolume > 0
        else {
            return nil
        }
        
        return volume / averageVolume
    }
    
    private var progress: Double {
        guard let ratio else { return 0 }
        return min(max(ratio, 0), 1.5) / 1.5
    }
    
    private var sharedDisplayUnit: DisplayUnit? {
        guard let volume,
              let averageVolume
        else {
            return nil
        }
        
        let smallestValue = min(abs(volume), abs(averageVolume))
        return Self.displayUnits.last { smallestValue >= $0.threshold }
    }
    
    private var ratioText: String {
        guard let ratio else { return "Unavailable" }
        return "\(ratio.formatted(.percent.precision(.fractionLength(0)))) of avg"
    }
    
    private var volumeText: String {
        formattedVolume(volume)
    }
    
    private var averageVolumeText: String {
        formattedVolume(averageVolume)
    }
    
    private func formattedVolume(_ value: Double?) -> String {
        guard let value else { return "-" }
        guard let sharedDisplayUnit else {
            return value.formatUsingAbbrevation()
        }
        
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 3
        formatter.decimalSeparator = ","
        formatter.positiveSuffix = sharedDisplayUnit.suffix
        formatter.negativeSuffix = sharedDisplayUnit.suffix
        
        let displayValue = value / sharedDisplayUnit.divisor
        return formatter.string(from: NSNumber(value: displayValue)) ?? "-"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text("Volume")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(uiColor: .label))
                
                Spacer(minLength: 12)
                
                Text(ratioText)
                    .font(.caption2.weight(.bold))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color(uiColor: .tertiarySystemBackground), in: Capsule())
            }
            
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(uiColor: .tertiarySystemFill))
                    
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 8)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: progress)
            
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                    Text(volumeText)
                        .font(.caption.weight(.bold))
                        .foregroundColor(Color(uiColor: .label))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Avg Vol")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                    Text(averageVolumeText)
                        .font(.caption.weight(.bold))
                        .foregroundColor(Color(uiColor: .label))
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Volume \(volumeText), average volume \(averageVolumeText)")
    }
}

private struct SelectedPeriodRangeView: View {
    
    let title: String
    let currentPrice: Double
    let periodLow: Double
    let periodHigh: Double
    
    private var progress: Double {
        guard periodHigh > periodLow else { return 0 }
        let rawValue = (currentPrice - periodLow) / (periodHigh - periodLow)
        return min(max(rawValue, 0), 1)
    }
    
    private var percentText: String {
        progress.formatted(.percent.precision(.fractionLength(0)))
    }
    
    private var currentPriceText: String {
        Utils.format(value: currentPrice) ?? "-"
    }
    
    private var lowText: String {
        Utils.format(value: periodLow) ?? "-"
    }
    
    private var highText: String {
        Utils.format(value: periodHigh) ?? "-"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Text(title)
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

struct StockTickerView_Previews: PreviewProvider {
    
    static var tradingStubsQuoteVM: TickerQuoteViewModel = {
       var mockAPI = MockStocksAPI()
        mockAPI.stubbedFetchQuotesCallback = {
            [Quote.stub(isTrading: true)]
        }
        return TickerQuoteViewModel(ticker: .stub, stocksAPI: mockAPI)
    }()
    
    static var closedStubsQuoteVM: TickerQuoteViewModel = {
       var mockAPI = MockStocksAPI()
        mockAPI.stubbedFetchQuotesCallback = {
            [Quote.stub(isTrading: false)]
        }
        return TickerQuoteViewModel(ticker: .stub, stocksAPI: mockAPI)
    }()
    
    
    static var loadingStubsQuoteVM: TickerQuoteViewModel = {
       var mockAPI = MockStocksAPI()
        mockAPI.stubbedFetchQuotesCallback = {
            await withCheckedContinuation { _ in
                
            }
        }
        return TickerQuoteViewModel(ticker: .stub, stocksAPI: mockAPI)
    }()
    
    
    static var errorStubsQuoteVM: TickerQuoteViewModel = {
       var mockAPI = MockStocksAPI()
        mockAPI.stubbedFetchQuotesCallback = {
            throw NSError(domain: "error", code: 0, userInfo: [NSLocalizedDescriptionKey: "An error has been occured"])
        }
        return TickerQuoteViewModel(ticker: .stub, stocksAPI: mockAPI)
    }()
    
    static var chartVM: ChartViewModel {
        ChartViewModel(ticker: .stub, apiService: MockStocksAPI())
    }
    
    static var previews: some View {
        Group {
            StockTickerView(chartVM: chartVM, quoteVM: tradingStubsQuoteVM)
                .previewDisplayName("Trading")
                .frame(height: 700)
            
            StockTickerView(chartVM: chartVM, quoteVM: closedStubsQuoteVM)
                .previewDisplayName("Closed")
                .frame(height: 700)
            
            StockTickerView(chartVM: chartVM, quoteVM: loadingStubsQuoteVM)
                .previewDisplayName("Loading Quote")
                .frame(height: 700)
            
            StockTickerView(chartVM: chartVM, quoteVM: errorStubsQuoteVM)
                .previewDisplayName("Error Quote")
                .frame(height: 700)
            
        }.previewLayout(.sizeThatFits)
    }
}
