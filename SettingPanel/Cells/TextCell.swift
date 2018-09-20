//
//  TextCell.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class TextCell: NSView, SettingCell {
  @IBOutlet weak var titleLabel: NSTextField!
  @IBOutlet weak var detailLabel: NSTextField!
  @IBOutlet weak var textField: NSTextField! {
    didSet {
      textField.delegate = self
    }
  }
  
  let type: SettingCellType = .text
  var settingKey: String!
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    let userDefault = UserDefaults.shared
    let text = userDefault.string(forKey: settingKey) ?? ""
    textField.stringValue = text
    window?.makeFirstResponder(nil)
  }
}

extension TextCell: NSTextFieldDelegate {
  func controlTextDidEndEditing(_ obj: Notification) {
    guard let field = obj.object as? NSTextField, field === textField else { return }
    let userDefault = UserDefaults.shared
    userDefault.set(field.stringValue, forKey: settingKey)
    DispatchQueue.main.async {
      field.currentEditor()?.selectedRange = NSRange(location: field.stringValue.count, length: 0)
    }
  }
}
