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
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitDefault() {
        let scanner = MutableDataScanner()
        assert(scanner.delimiter == nil)
    }
    
    func testInitWithData() {
        let data = NSMutableData()
        let scanner = MutableDataScanner(data: data)
        data.appendData("012345".dataValue)
        assert(scanner.data == data)
    }
    
    func testInitWithDataAndDelimiterString() {
        let data = NSMutableData()
        let scanner = MutableDataScanner(data: data, delimiter: "\t")
        data.appendData("012345".dataValue)
        assert(scanner.data == data)
        assert(scanner.delimiter?.stringValue == "\t")
    }
    
    func testInitWithDelimiterData() {
        let scanner = MutableDataScanner(delimiter: "\t".dataValue)
        assert(scanner.delimiter?.stringValue == "\t")
    }
    
    func testInitWithDelimiterString() {
        let scanner = MutableDataScanner(delimiter: "\t")
        assert(scanner.delimiter?.stringValue == "\t")
    }
    
    func testReadLength() {
        let scanner = MutableDataScanner()
        let data = "0123456789abcdefghijklmnopqrstuvwxyz".dataValue
        scanner.appendData(data)
        assert(scanner.read(length: 10)!.stringValue == "0123456789", "read length")
        assert(scanner.read(length: 10)!.stringValue == "abcdefghij", "read length")
        assert(scanner.read(length: scanner.data.length)!.stringValue == "klmnopqrstuvwxyz", "read length")
        assert(scanner.read(length: 1) == nil)
    }
    
    func testReadLengthOver() {
        let scanner = MutableDataScanner()
        let data = "012345".dataValue
        scanner.appendData(data)
        assert(scanner.read(length: 100)!.stringValue == "012345", "read length")
        assert(scanner.read(length: 1) == nil)
    }
    
    func testReadOffsetLength() {
        let scanner = MutableDataScanner()
        let data = "0123456789abcdefghijklmnopqrstuvwxyz".dataValue
        scanner.appendData(data)
        assert(scanner.read(offset: 3, length: 7)!.stringValue == "3456789", "read length")
        assert(scanner.read(offset: 3, length: 7)!.stringValue == "defghij", "read length")
        assert(scanner.read(offset: 3, length: scanner.data.length)!.stringValue == "nopqrstuvwxyz", "read length")
        assert(scanner.read(offset: 3, length: 1) == nil)
    }
    
    func testNextLine() {
        let scanner = MutableDataScanner()
        let data = "1\n1\r\n1\r1".dataValue
        var count = 0
        scanner.appendData(data)
        while let line = scanner.nextLine() {
            assert(line.stringValue == "1")
            count++
        }
        assert(count == 2, "data count")
        assert(scanner.data.length == 3, "buffer length")
    }
    
    func testNext() {
        let scanner = MutableDataScanner(delimiter: "\r\n")
        let data = "012345\nabcdefg\r\n".dataValue
        var count = 0
        scanner.appendData(data)
        while let line = scanner.next() {
            NSLog("\(line.stringValue)")
            assert(line.stringValue == "012345\nabcdefg")
            count++
        }
        assert(count == 1, "data count")
        assert(scanner.data.length == 0, "buffer length")
    }
    
    func testPerformanceAutoDelimiter() {
        self.measureBlock {
            let scanner = MutableDataScanner()
            let data = "12345\n12345\r\n12345\r12345\n12345\r\n12345".dataValue
            for _ in 1...10000 {
                scanner.appendData(data)
                while let _ = scanner.nextLine() {
                }
            }
        }
    }
    
    func testPerformanceSpecificDelimiter() {
        self.measureBlock {
            let scanner = MutableDataScanner(delimiter: "\n")
            let data = "12345\n12345\r\n12345\r12345\n12345\r\n12345".dataValue
            for _ in 1...10000 {
                scanner.appendData(data)
                while let _ = scanner.next() {
                }
            }
        }
    }
    
    func testPerformanceSplitReader() {
        let data = "12345\n12345\r\n12345\r12345\n12345\r\n12345".dataValue
        let buffer = NSMutableData()
        self.measureBlock {
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

private extension NSData {
    var stringValue: NSString {
        return NSString(data: self, encoding: NSUTF8StringEncoding)!
    }
}


private extension String {
    var dataValue: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}
