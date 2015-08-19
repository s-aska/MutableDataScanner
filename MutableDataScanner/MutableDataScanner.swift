//
//  MutableDataScanner.swift
//  MutableDataScanner
//
//  Created by Shinichiro Aska on 8/20/15.
//  Copyright © 2015 Shinichiro Aska. All rights reserved.
//

import Foundation

public class MutableDataScanner {
    
    struct Static {
        static let CR = "\r".dataUsingEncoding(NSUTF8StringEncoding)!
        static let LF = "\n".dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    public var data: NSMutableData
    public var delimiter: NSData?
    
    public init(data: NSMutableData) {
        self.data = data
        self.delimiter = nil
    }
    
    public init(data: NSMutableData, delimiter: NSData) {
        self.data = data
        self.delimiter = delimiter
    }
    
    public func appendData(data: NSData) {
        self.data.appendData(data)
    }
    
    public func read(offset: Int, var _ length: Int) -> NSData? {
        if offset > data.length {
            return nil
        }
        if length + offset > data.length {
            length = data.length - offset
        }
        let chunk = data.subdataWithRange(NSMakeRange(offset, length))
        data.replaceBytesInRange(NSMakeRange(0, offset + length), withBytes: nil, length: 0)
        return chunk
    }
    
    public func read(var length: Int) -> NSData? {
        if data.length == 0 {
            return nil
        }
        if length > data.length {
            length = data.length
        }
        let line = data.subdataWithRange(NSMakeRange(0, length))
        data.replaceBytesInRange(NSMakeRange(0, length), withBytes: nil, length: 0)
        return line
    }
    
    public func hasNextLine() -> Bool {
        let range = data.rangeOfData(delimiter ?? Static.LF, options: NSDataSearchOptions(rawValue: 0), range: NSMakeRange(0, data.length))
        return range.location != NSNotFound
    }
    
    public func nextLine() -> NSData? {
        let range = data.rangeOfData(delimiter ?? Static.LF, options: NSDataSearchOptions(rawValue: 0), range: NSMakeRange(0, data.length))
        if range.location != NSNotFound {
            let line: NSData
            if delimiter != nil || data.subdataWithRange(NSMakeRange(range.location - 1, 1)) != Static.CR {
                line = data.subdataWithRange(NSMakeRange(0, range.location))
            } else {
                line = data.subdataWithRange(NSMakeRange(0, range.location - 1))
            }
            data.replaceBytesInRange(NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
            return line
        } else {
            return nil
        }
    }
}
