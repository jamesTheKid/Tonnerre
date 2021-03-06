//
//  StringExtensionTest.swift
//  TonnerreTests
//
//  Created by Yaxin Cheng on 2018-12-31.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import XCTest
@testable import Tonnerre

class StringExtensionTest: XCTestCase {

  func testFilledWithEqualArgs() {
    let template = "%@=%@"
    XCTAssertEqual(template.filled(arguments: ["Key", "Value"]), "Key=Value")
  }
  
  func testFilledWithMoreArgs() {
    let template = "%@=%@"
    XCTAssertEqual(template.filled(arguments: ["Key", "Value", "1"]), "Key=Value 1")
  }
  
  func testFilledWithMoreArgsPlusSeparator() {
    let template = "%@=%@"
    XCTAssertEqual(template.filled(arguments: ["Key", "Value", "1"], separator: "+"), "Key=Value+1")
  }

  func testFilledWithLessArgs() {
    let template = "%@=%@"
    XCTAssertEqual(template.filled(arguments: "Key"), template)
  }
  
  func testTruncatedLeadingSpaces() {
    let leadingSpaces = "      string"
    XCTAssertEqual(leadingSpaces.truncatedSpaces, "string")
  }
  
  func testTruncatedTrailingSpaces() {
    let trailingSpaces = "string    "
    XCTAssertEqual(trailingSpaces.truncatedSpaces, "string ")
  }
  
  func testTruncatedTrailingSpace() {
    let trailingSpace = "string "
    XCTAssertEqual(trailingSpace.truncatedSpaces, trailingSpace)
  }
  
  func testTruncatedLeadingAndTrailingSpaces() {
    let mixString = "    string    "
    XCTAssertEqual(mixString.truncatedSpaces, "string ")
  }
  
  func testRegexMatchExist() {
    let base = "hello world"
    let matched = base.match(regex: try! NSRegularExpression(pattern: "\\w+o"))
    XCTAssertNotNil(matched)
  }
  
  func testRegexMatchCorrectness() {
    let base = "hello world"
    let matched = base.match(regex: try! NSRegularExpression(pattern: "\\w+o"))!
    XCTAssertEqual(matched, "hello")
  }
  
  func testStringDifferenceSuccess() {
    let base = "hello"
    let difference = base.formDifference(with: "he")
    XCTAssertEqual(difference, "llo")
  }
  
  func testStringDifferenceEmpty() {
    let base = "hello"
    let empty = base.formDifference(with: "llo")
    XCTAssertEqual("", empty)
  }
  
  func testStringDifferenceWithEmpty() {
    let base = "hello"
    let difference = base.formDifference(with: "")
    XCTAssertEqual(base, difference)
  }
  
  func testCamelCaseSplit() {
    let origin = "helloWorld"
    let expected = ["hello", "World"] as [Substring]
    XCTAssertEqual(origin.splitCamelCase(), expected)
  }
}
