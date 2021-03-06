//
//  WebServiceList.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-03-29.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

struct WebServiceList {
  /// Shared instance for WebServiceList that links to the webServiceList.plist
  static let shared = WebServiceList()
  private let suggestionList: [String: String]
  private let servicesList: [String: [String: String]]
  
  private let _RESOURCE_NAME = "webServices"
  private let _SUGGESTION_KEY = "suggestionTemplate"
  private let _TEMPLATE_KEY = "template"
  
  private init() {
    let (baseSuggestion, baseServices) = WebServiceList.readWebList(resourceName: _RESOURCE_NAME)
    if let regionCode = Locale.current.regionCode?.lowercased() {
      let (regionalSuggestion, regionalServices) = WebServiceList.readWebList(resourceName: "\(_RESOURCE_NAME)_\(regionCode)")
      suggestionList = baseSuggestion.merging(regionalSuggestion) { $1 }
      servicesList = baseServices.merging(regionalServices) { $1 }
    } else {
      suggestionList = baseSuggestion
      servicesList = baseServices
    }
  }
  
  private static func readWebList(resourceName: String) -> ([String:String], [String:[String:String]]) {
    let content: Result<[String:Any], Error> = PropertyListSerialization.read(fileName: resourceName)
    let suggestionList: [String : String]
    let servicesList: [String : [String : String]]
    switch content {
    case .success(let listObj):
      suggestionList = listObj[Attribute.suggestionsTemplate.rawValue] as? [String : String] ?? [:]
      servicesList = listObj[Attribute.serviceTemplate.rawValue] as? [String : [String : String]] ?? [:]
    case .failure(let error):
      Logger.error(file: WebServiceList.self, "Reading %{PUBLIC}@ Error: %{PUBLIC}@", resourceName, error.localizedDescription)
      (suggestionList, servicesList) = ([:], [:])
    }
    return (suggestionList, servicesList)
  }
  
  /// The attribute from the webServiceList, either suggestion or service
  enum Attribute: String {
    case suggestionsTemplate = "Suggestions"
    case serviceTemplate = "Services"
  }
  
  /// Retrieve attribute value from the list
  subscript(_ service: WebService, attribute: Attribute) -> String {
    let typeName = "\(type(of: service))"
    let serviceMod = servicesList[typeName]
    switch attribute {
    case .serviceTemplate: return serviceMod?[_TEMPLATE_KEY] ?? ""
    case .suggestionsTemplate:
      let suggestionMod = serviceMod?[_SUGGESTION_KEY] ?? ""
      return suggestionList[suggestionMod] ?? ""
    }
  }
}
