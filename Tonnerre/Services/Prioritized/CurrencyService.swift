//
//  CurrencyService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-11.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct CurrencyService: TonnerreService {
  static let keyword: String = ""
  let icon: NSImage = .calculator
  let name: String = "Currency Exchange"
  let content: String = "Currency change from %@ to %@"
  let argLowerBound: Int = 2
  let argUpperBound: Int = 4
  let template: String = "https://free.currencyconverterapi.com/api/v5/convert?q=%@&compact=ultra"//USD_CAD,USD_JPY
  private let currencyCodes: Set<String>
  private let popularCurrencies = ["USD", "EUR", "GBP", "JPY", "CHF", "CNY"]
  
  init() {
    currencyCodes = Set(Locale.isoCurrencyCodes)
  }
  
  /**
   Extract the fromCurrency, toCurrency, and amount fromn the raw input
   - parameter input: the raw input passed to this service
   - returns: (fromCurrency, toCurrency, amount). This function may also return nil if it does not match the format
  */
  private func extractInfomation(from input: [String]) -> (String, String, Double)? {
    let (fromCurrency, toCurrency, amount): (String, String, Double)
    switch input.count {
    case 2:
      let currentCode = Locale.current.currencyCode ?? "..."
      if let convertedNumber = Double(input[0]), currencyCodes.contains(input[1].uppercased()) {
        (amount, fromCurrency, toCurrency) = (convertedNumber, input[1].uppercased(), input[1].uppercased() == currentCode ? "USD" : currentCode)
      } else if let convertedNumber = Double(input[1]), currencyCodes.contains(input[0].uppercased()) {
        (amount, fromCurrency, toCurrency) = (convertedNumber, input[0].uppercased(), input[0].uppercased() == currentCode ? "USD" : currentCode)
      } else if currencyCodes.contains(input[0].uppercased()) && currencyCodes.contains(input[1].uppercased()) {
        (amount, fromCurrency, toCurrency) = (1, input[0].uppercased(), input[1].uppercased())
      } else { return nil }
    case 3, 4:
      if let convertedNumber = Double(input[0]) { (amount, fromCurrency) = (convertedNumber, input[1].uppercased()) }
      else if let convertedNumber = Double(input[1]) { (amount, fromCurrency) = (convertedNumber, input[0].uppercased()) }
      else { return nil }
      guard currencyCodes.contains(fromCurrency) else { return nil }
      let existTo = input[2].lowercased() == "to"
      if input.count == 3 && currencyCodes.contains(input[2].uppercased()) {
        toCurrency = input[2].uppercased()
      } else if input.count == 4 && existTo && currencyCodes.contains(input[3].uppercased()) {
        toCurrency = input[3].uppercased()
      } else { return nil }
    default: return nil
    }
    return (fromCurrency, toCurrency, amount)
  }
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    guard let (fromCurrency, toCurrency, amount) = extractInfomation(from: input) else { return [] }
    // The async function to setup the view
    let label = "\(amount) \(fromCurrency) = %@ "
    let viewSetupGenerator: (String, String, String) -> ((ServiceCell) -> Void)? = { fromCurrency, toCurrency, label in
      if !self.currencyCodes.contains(fromCurrency) || !self.currencyCodes.contains(toCurrency) { return nil }
      return { cell in
          let key = [fromCurrency, toCurrency].joined(separator: "_")
          let url = URL(string: String(format: self.template, key))!
          let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60 * 30)
          URLSession(configuration: .default).dataTask(with: request) { (data, response, error) in
            guard
              let jsonData = data,
              let jsonObj = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? [String: Double],
              let rate = jsonObj[key]
            else { return }
            DispatchQueue.main.async {
              cell.serviceLabel.stringValue = String(format: label, "\(rate * amount)")
            }
          }.resume()
      }
    }
    let populars = popularCurrencies.filter { $0 != fromCurrency && $0 != toCurrency }
    return ([toCurrency] + populars).map {
      let asyncViewSetup = viewSetupGenerator(fromCurrency, $0, label + $0)
      return AsyncedDisplayableContainer(name: String(format: label + $0, "..."), content: String(format: content, fromCurrency, $0), icon: icon, innerItem: [fromCurrency, $0], viewSetup: asyncViewSetup)
    }
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    guard let innerItem = (source as? AsyncedDisplayableContainer<[String]>)?.innerItem else { return }
    let encoded = innerItem.joined(separator: "+")
    let url = URL(string: "https://google.com/search?q=\(encoded)")!
    NSWorkspace.shared.open(url)
  }
}