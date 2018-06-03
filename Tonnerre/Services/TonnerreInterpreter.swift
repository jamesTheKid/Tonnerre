//
//  TonnerreInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct TonnerreInterpreter {
  private static var loader = TonnerreServiceLoader()
  
  private func tokenize(rawCmd: String) -> [String] {
    return rawCmd.components(separatedBy: .whitespaces)
  }
  
  private func parse(tokens: [String]) -> [TonnerreService] {
    if tokens.count == 1 {
      return TonnerreInterpreter.loader.autoComplete(key: tokens.first!) + [LaunchService()]
    } else {
      return TonnerreInterpreter.loader.exactMatch(key: tokens.first!)
    }
  }
  
  func interpret(rawCmd: String) -> [ServiceResult] {
    guard !rawCmd.isEmpty else { return [] }
    let tokens = tokenize(rawCmd: rawCmd)
    let services = parse(tokens: tokens)
    let possibleServices: [ServiceResult] = services.map { service in
      let keywordCount = (service.keyword != "").hashValue
      let filteredTokens = tokens.filter({ !$0.isEmpty })
      if filteredTokens.count >= keywordCount + service.arguments.count {
        return service.prepare(input: Array(filteredTokens[keywordCount...])).map { queryResult in
          ServiceResult(service: service, value: queryResult)
        }
      } else {
        return [ServiceResult(service: service)]
      }
    }.reduce([], +)
    if possibleServices.isEmpty {
      let services: [WebService] = [GoogleSearch(suggestion: false), AmazonSearch(suggestion: false), WikipediaSearch(suggestion: false)]
      let values = services.map { $0.prepare(input: tokens) }
      return zip(services, values).map { ServiceResult(service: $0.0, value: $0.1.first!) }
    } else {
      return possibleServices
    }
  }
}
