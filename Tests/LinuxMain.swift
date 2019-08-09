import XCTest

import MonkeyTests

var tests = [XCTestCaseEntry]()
tests += MonkeyTests.allTests()
XCTMain(tests)
