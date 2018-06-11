//
//  TonnerreServiceLoader.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct TonnerreServiceLoader {
  private lazy var trie: Trie = {
    return Trie(values: keywords)
  }()
  private let sysSeviceTrie: Trie
  
  private let normalServices: [TonnerreService.Type]
  private let systemServices: [TonnerreService.Type]
  
  lazy var services: [String: [TonnerreService]] = {// keyword : instance
    let loadedServices = normalServices.map { (type) -> (String, [TonnerreService]) in
      let instance = type.init()
      return (instance.keyword, [instance])
    }
    let generalWebServices: [(String, [TonnerreService])] = GeneralWebService.load().map { ($0.keyword, [$0]) }
    return Dictionary(loadedServices + generalWebServices, uniquingKeysWith: +)
  }()
  private let keywordToSysServices: [String: TonnerreService.Type]
  
  lazy var keywords: Set<String> = {
    return Set(normalServices.map { $0.init().keyword } + GeneralWebService.load().map { $0.keyword } )
  }()
  
  mutating func autoComplete(key: String) -> [TonnerreService] {
    let fetchedServices = trie.find(value: key).compactMap({ services[$0] }).reduce([], +)
    return fetchedServices + (services[""] ?? [])
  }
  
  mutating func exactMatch(key: String) -> [TonnerreService] {
    guard keywords.contains(key) else { return services[""] ?? [] }
    return services[key] ?? services[""] ?? []
  }
  
  func loadSystemService(baseOn keyword: String) -> [SystemService] {
    let matchedKeyword = sysSeviceTrie.find(value: keyword)
    return matchedKeyword.compactMap { keywordToSysServices[$0]?.init() } as! [SystemService]
  }
  
  init() {
    normalServices = [LaunchService.self, CalculationService.self, URLService.self, /*CurrencyService.self,*/ FileNameSearchService.self, FileContentSearchService.self, GoogleSearch.self, AmazonSearch.self, WikipediaSearch.self, GoogleImageSearch.self, YoutubeSearch.self, GoogleMapService.self, TrashEmptyService.self, DictionarySerivce.self, GoogleTranslateService.self]
    systemServices = [ApplicationService.self, VolumeService.self]
    sysSeviceTrie = Trie(values: Set(systemServices.map { $0.init().keyword }))
    keywordToSysServices = Dictionary(uniqueKeysWithValues: systemServices.map { ($0.init().keyword, $0) })
  }
}
