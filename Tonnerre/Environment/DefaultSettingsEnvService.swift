//
//  DefaultSettingsEnvService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

struct DefaultSettingEnvService: EnvService {
  let defaultSettings: [(key: SettingKey, value: SettingValue)] = [
    (.python, "/usr/bin/python"),
    (.defaultProvider, "Tonnerre.Provider.BuiltIn.GoogleSearch"),
    (.clipboardLimit, 9),
    (.warnBeforeExit, true),
    (.disabledServices, ["Tonnerre.Provider.BuiltIn.SafariBMService",
                         "Tonnerre.Provider.BuiltIn.ChromeBMService"])
  ]
  
  func setup() {
    let doneExecuting = UserDefaults.standard.bool(forKey: "settings:finished")
    guard !doneExecuting else { return }
    for (key, value) in defaultSettings {
      TonnerreSettings.set(value, forKey: key)
    }
    UserDefaults.standard.set(true, forKey: "settings:finished")
  }
}
