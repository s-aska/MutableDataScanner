//
//  MutableDataScannerTests.swift
//  MutableDataScannerTests
//
//  Created by Shinichiro Aska on 8/20/15.
//  Copyright © 2015 Shinichiro Aska. All rights reserved.
//

import XCTest
import MutableDataScanner

class MutableDataScannerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testReadLength() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let scanner = MutableDataScanner()
        let data = "12345\n12345\r\n12345\n12345\n12345\r\n12345".dataUsingEncoding(NSUTF8StringEncoding)!
        scanner.appendData(data)
        assert(NSString(data: scanner.read(length: 11)!, encoding: NSUTF8StringEncoding)! == "12345\n12345", "read length")
        assert(NSString(data: scanner.read(length: 11)!, encoding: NSUTF8StringEncoding)! == "\r\n12345\n123", "read length")
        scanner.read(length: 20)
        assert(scanner.read(length: 1) == nil)
    }
    
    func testReadOffsetLength() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let scanner = MutableDataScanner()
        let data = "12345\n12345\r\n12345\n12345\n12345\r\n12345".dataUsingEncoding(NSUTF8StringEncoding)!
        scanner.appendData(data)
        assert(NSString(data: scanner.read(offset: 3, length: 11)!, encoding: NSUTF8StringEncoding)! == "45\n12345\r\n1", "read offset length")
        assert(NSString(data: scanner.read(offset: 3, length: 11)!, encoding: NSUTF8StringEncoding)! == "5\n12345\n123", "read offset length")
        scanner.read(length: 20)
        assert(scanner.read(length: 1) == nil)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let scanner = MutableDataScanner()
        let data = "12345\n12345\r\n12345\n12345\n12345\r\n12345".dataUsingEncoding(NSUTF8StringEncoding)!
        var count = 0
        scanner.appendData(data)
        while let line = scanner.nextLine() {
            let string = NSString(data: line, encoding: NSUTF8StringEncoding)!
            assert(string == "12345", "CRLF or LF mode")
            count++
        }
        assert(count == 5, "line number")
    }
    
    func testPerformanceAutoDelimiter() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
            let scanner = MutableDataScanner()
            let data = "12345\n12345\r\n12345\r12345\n12345\r\n12345".dataUsingEncoding(NSUTF8StringEncoding)!
            for _ in 1...10000 {
                scanner.appendData(data)
                while let _ = scanner.nextLine() {
                }
            }
        }
    }
    
    func testPerformanceSpecificDelimiter() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
            let scanner = MutableDataScanner(delimiter: "\n")
            let data = "12345\n12345\r\n12345\r12345\n12345\r\n12345".dataUsingEncoding(NSUTF8StringEncoding)!
            for _ in 1...10000 {
                scanner.appendData(data)
                while let _ = scanner.next() {
                }
            }
        }
    }
    
    func testPerformanceSplitReader() {
        // This is an example of a performance test case.
        let data = "12345\n12345\r\n12345\r12345\n12345\r\n12345".dataUsingEncoding(NSUTF8StringEncoding)!
        let buffer = NSMutableData()
        self.measureBlock {
            // Put the code you want to measure the time of here.
            for _ in 1...10000 {
                buffer.appendData(data)
                if let string = NSString(data: buffer, encoding: NSUTF8StringEncoding) {
                    var array = string.componentsSeparatedByString("\n")
                    if let last = array.popLast()?.dataUsingEncoding(NSUTF8StringEncoding)! {
                        buffer.setData(last)
                    } else {
                        buffer.setData(NSData())
                    }
                    for _ in array {
                    }
                }
            }
        }
    }
}
