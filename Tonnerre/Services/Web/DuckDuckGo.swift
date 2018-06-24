//
//  DuckDuckGo.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct DuckDuckGoSearch: WebService {
  let name: String = "DuckDuckGo"
  let template: String = "https://duckduckgo.com/?q=%@"
  static let keyword: String = "duck"
  let suggestionTemplate: String = "https://duckduckgo.com/ac/?&q=%@"
  let contentTemplate: String = "Search %@ on DuckDuckGo"
  let argLowerBound: Int = 1
  let argUpperBound: Int = Int.max
  let loadSuggestion: Bool = true
  let icon: NSImage = #imageLiteral(resourceName: "duck")
  
  func parseSuggestions(data: Data?) -> [String : Any] {
    guard
      let jsonData = data,
      let jsonObj = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? [[String: String]]
    else { return [:] }
    let suggestions = jsonObj.compactMap { $0["phrase"] }
    return ["suggestions": suggestions]
  }
}