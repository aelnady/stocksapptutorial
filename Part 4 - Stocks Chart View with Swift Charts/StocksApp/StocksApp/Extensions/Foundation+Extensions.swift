//
//  Foundation+Extensions.swift
//  StocksApp
//
//  Created by Alfian Losari on 16/10/22.
//

import Foundation
import XCAStocksAPI

extension Error {
    
    var userFriendlyMessage: String {
        if let apiError = self as? APIServiceError {
            switch apiError {
            case .invalidURL, .invalidResponseType:
                return "Market data is temporarily unavailable."
            case let .httpStatusCodeFailed(statusCode, error):
                if statusCode == 401 || error?.code.localizedCaseInsensitiveContains("unauthorized") == true {
                    return "Quote details are temporarily unavailable."
                }
                return "Unable to load market data. Please try again."
            }
        }
        
        return "Something went wrong. Please try again."
    }
    
    func logForDebug(context: String) {
        #if DEBUG
        print("[\(context)] \(localizedDescription)")
        #endif
    }
}

extension Double {
    
    //https://stackoverflow.com/questions/18267211/ios-convert-large-numbers-to-smaller-format
    //    gbitaudeau
        func formatUsingAbbrevation () -> String {
            let numFormatter = NumberFormatter()
            
            typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
            let abbreviations:[Abbrevation] = [(0, 1, ""),
                                               (1000.0, 1000.0, "K"),
                                               (100_000.0, 1_000_000.0, "M"),
                                               (100_000_000.0, 1_000_000_000.0, "B"),
                                               (100_000_000_000.0, 1_000_000_000_000.0, "T")]
            let startValue = Double (abs(self))
            let abbreviation:Abbrevation = {
                var prevAbbreviation = abbreviations[0]
                for tmpAbbreviation in abbreviations {
                    if (startValue < tmpAbbreviation.threshold) {
                        break
                    }
                    prevAbbreviation = tmpAbbreviation
                }
                return prevAbbreviation
            } ()
            
            let value = Double(self) / abbreviation.divisor
            numFormatter.positiveSuffix = abbreviation.suffix
            numFormatter.negativeSuffix = abbreviation.suffix
            numFormatter.allowsFloats = true
            numFormatter.minimumIntegerDigits = 1
            numFormatter.minimumFractionDigits = 0
            numFormatter.maximumFractionDigits = 3
            numFormatter.decimalSeparator = ","
            
            return numFormatter.string(from: NSNumber (value:value))!
        }
    
}

extension Double {
    var roundedString: String {
        String(format: "%.2f", self)
    }
}

extension Date {
    
    func dateComponents(timeZone: TimeZone, rangeType: ChartRange, calendar: Calendar = .current) -> DateComponents {
        let current = calendar.dateComponents(in: timeZone, from: self)
        
        var dc = DateComponents(timeZone: timeZone, year: current.year, month: current.month)
        
        if rangeType == .oneMonth || rangeType == .oneWeek || rangeType == .oneDay {
            dc.day = current.day
        }
        
        if rangeType == .oneDay {
            dc.hour = current.hour
        }
        
        return dc
    }
    
}
