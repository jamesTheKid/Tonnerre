//
//  TonnerreServiceLoader.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct TonnerreServiceLoader {
  private let normalServiceTrie: Trie<TonnerreService.Type>
  private let systemServiceTrie: Trie<TonnerreService.Type>
  private let interpreterServicesDict: [String: [TonnerreService.Type]]
  private let prioritizedServices: [TonnerreService]
  private let extensionServices: [TonnerreService]
  
  enum serviceType {
    case normal
    case system
    case interpreter
  }
  
  func autoComplete(key: String, type: serviceType = .normal, includeExtra: Bool = true) -> [TonnerreService] {
    if type == .normal {
      let prioritized = includeExtra ? prioritizedServices : []
      let extended = includeExtra ? extensionServices : []
      let fetchedServices = normalServiceTrie.find(value: key)
        .filter { !$0.isDisabled || !includeExtra }
        .map { $0.init() }
      return fetchedServices + extended + prioritized
    } else if type == .system {
      return systemServiceTrie.find(value: key).filter { !$0.isDisabled || !includeExtra } .map { $0.init() }
    } else if type == .interpreter {
      return (interpreterServicesDict[key] ?? []).map { $0.init() }
    } else { return [] }
  }
  
  init() {
    prioritizedServices = [LaunchService(), CalculationService(), URLService(), CurrencyService()]
    extensionServices = [DynamicService(), DynamicWebService()]
    let normalServices: [TonnerreService.Type] = [FileNameSearchService.self, FileContentSearchService.self, GoogleSearch.self, AmazonSearch.self, WikipediaSearch.self, GoogleImageSearch.self, YoutubeSearch.self, GoogleMapService.self, TrashEmptyService.self, DictionarySerivce.self, GoogleTranslateService.self, BingSearch.self, DuckDuckGoSearch.self, LockService.self, ScreenSaverService.self, SafariBMService.self, ChromeBMService.self, TerminalService.self]
    let systemServices: [TonnerreService.Type] = [ApplicationService.self, VolumeService.self, ClipboardService.self]
    let interpreterServices: [TonnerreService.Type] = [ServicesService.self, ReloadService.self/*, DefaultService.self*/]
    normalServiceTrie = Trie(values: normalServices) { $0.keyword }
    systemServiceTrie = Trie(values: systemServices) { $0.keyword }
    interpreterServicesDict = Dictionary(interpreterServices.map { ($0.keyword, [$0]) }, uniquingKeysWith: +)
    if ClipboardService.isDisabled == false {
      ClipboardService.monitor.start()
    }
  }
  
  func reload() {
    extensionServices.compactMap { $0 as? DynamicProtocol }.forEach { $0.reload() }
  }
}
