//
//  AmazonSearch.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-03.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct AmazonSearch: WebService {
  let icon: NSImage = #imageLiteral(resourceName: "amazon")
  let name: String = "Amazon"
  let template: String = "https://www.amazon.com/s/?field-keywords=%@"
  let suggestionTemplate: String = "https://completion.amazon.com/search/complete?search-alias=aps&client=amazon-search-ui&mkt=1&q=%@"
  let content: String = "Shopping on amazon for what you like"
  let keyword: String = "amazon"
  let arguments: [String] = ["item name"]
  let hasPreview: Bool = false
  let loadSuggestion: Bool
  
  init() {
    loadSuggestion = true
  }
  
  init(suggestion: Bool) {
    loadSuggestion = suggestion
  }

  func processJSON(data: Data?) -> [String : Any] {
    guard
      let jsonData = data,
      let jsonObject = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? NSArray,
      let queriedWord = jsonObject[0] as? String,
      let suggestions = jsonObject[1] as? [String]
    else { return [:] }
    return ["suggestions": suggestions, "queriedWord": queriedWord, "queriedKey": keyword]
  }
}
