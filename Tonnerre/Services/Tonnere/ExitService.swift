//
//  ExitService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-10-04.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct ExitService: TonnerreService {
  static let keyword: String = "exit"
  let name: String = "Quit Tonnerre"
  let content: String = "Quit Tonnerre program properly"
  let icon: NSImage = #imageLiteral(resourceName: "tonnerre.icns")
  let argLowerBound: Int = 0
  var priority: DisplayPriority = .low
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    return [self]
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    exit(0)
  }
  
}
