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
        XCTAssertEqual(scanner.delimiter, nil)
    }

    func testInitWithDelimiterData() {
        let scanner = MutableDataScanner(delimiter: "\t".dataValue)
        XCTAssertEqual(scanner.delimiter?.stringValue, "\t")
    }

    func testInitWithDelimiterString() {
        let scanner = MutableDataScanner(delimiter: "\t")
        XCTAssertEqual(scanner.delimiter?.stringValue, "\t")
    }

    func testReadLength() {
        let scanner = MutableDataScanner()
        let data = "0123456789abcdefghijklmnopqrstuvwxyz".dataValue
        scanner.append(data)
        XCTAssertEqual(scanner.read(length: 10)!.stringValue, "0123456789", "read length")
        XCTAssertEqual(scanner.read(length: 10)!.stringValue, "abcdefghij", "read length")
        XCTAssertEqual(scanner.read(length: scanner.data.count)!.stringValue,
                       "klmnopqrstuvwxyz", "read length")
        XCTAssertEqual(scanner.read(length: 1), nil)
    }

    func testReadLengthOver() {
        let scanner = MutableDataScanner()
        let data = "012345".dataValue
        scanner.append(data)
        XCTAssertEqual(scanner.read(length: 100)!.stringValue, "012345", "read length")
        XCTAssertEqual(scanner.read(length: 1), nil)
    }

    func testReadOffsetLength() {
        let scanner = MutableDataScanner()
        let data = "0123456789abcdefghijklmnopqrstuvwxyz".dataValue
        scanner.append(data)
        XCTAssertEqual(scanner.read(offset: 3, length: 7)!.stringValue, "3456789", "read length")
        XCTAssertEqual(scanner.read(offset: 3, length: 7)!.stringValue, "defghij", "read length")
        XCTAssertEqual(scanner.read(offset: 3, length: scanner.data.count)!.stringValue,
                       "nopqrstuvwxyz", "read length")
        XCTAssertEqual(scanner.read(offset: 3, length: 1), nil)
    }

    func testNextLine() {
        let scanner = MutableDataScanner()
        let data = "1\n1\r\n1\r1".dataValue
        var count = 0
        scanner.append(data)
        while let line = scanner.nextLine() {
            XCTAssertEqual(line.stringValue, "1")
            count += 1
        }
        XCTAssertEqual(count, 2, "data count")
        XCTAssertEqual(scanner.data.count, 3, "buffer length")
    }

    func testNext() {
        let scanner = MutableDataScanner(delimiter: "\r\n")
        let data = "012345\nabcdefg\r\n".dataValue
        var count = 0
        scanner.append(data)
        while let line = scanner.next() {
            XCTAssertEqual(line.stringValue, "012345\nabcdefg")
            count += 1
        }
        XCTAssertEqual(count, 1, "data count")
        XCTAssertEqual(scanner.data.count, 0, "buffer length")
    }

    func testPerformanceAutoDelimiter() {
        self.measure {
            let scanner = MutableDataScanner()
            let data = "12345\n12345\r\n12345\r12345\n12345\r\n12345".dataValue
            for _ in 1...10000 {
                scanner.append(data)
                while let _ = scanner.nextLine() {
                }
            }
        }
    }

    func testPerformanceSpecificDelimiter() {
        self.measure {
            let scanner = MutableDataScanner(delimiter: "\n")
            let data = "12345\n12345\r\n12345\r12345\n12345\r\n12345".dataValue
            for _ in 1...10000 {
                scanner.append(data)
                while let _ = scanner.next() {
                }
            }
        }
    }

    func testPerformanceSplitReader() {
        let data = "12345\n12345\r\n12345\r12345\n12345\r\n12345".dataValue
        var buffer = Data()
        self.measure {
            for _ in 1...10000 {
                buffer.append(data)
                if let string = NSString(data: buffer, encoding: String.Encoding.utf8.rawValue) {
                    var array = string.components(separatedBy: "\n")
                    if let last = array.popLast()?.data(using: String.Encoding.utf8)! {
                        buffer = last
                    } else {
                        buffer = Data()
                    }
                    for _ in array {
                    }
                }
            }
        }
    }
}

private extension Data {
    var stringValue: NSString {
        return NSString(data: self, encoding: String.Encoding.utf8.rawValue)!
    }
}

private extension String {
    var dataValue: Data {
        return self.data(using: String.Encoding.utf8)!
    }
}
