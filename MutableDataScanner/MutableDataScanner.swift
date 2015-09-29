//
//  MutableDataScanner.swift
//  MutableDataScanner
//
//  Created by Shinichiro Aska on 8/20/15.
//  Copyright © 2015 Shinichiro Aska. All rights reserved.
//

import Foundation

/// A simple text scanner which can parse NSMutableData using delimiter module, but as a class.
public class MutableDataScanner {

    /// Constants to use nextLine() and hasNextLine().
    struct Static {
        static let CR = "\r".dataUsingEncoding(NSUTF8StringEncoding)!
        static let LF = "\n".dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    /// buffer.
    public var data: NSMutableData
    
    /// delimiter to use with no arguments next() and hasNext().
    public var delimiter: NSData?
    
    /**
    Create A MutableDataScanner Instance
    
    - parameter data: buffer
    
    - returns: MutableDataScanner Instance
    */
    public init(data: NSMutableData = NSMutableData()) {
        self.data = data
        self.delimiter = nil
    }
    
    /**
    Create A MutableDataScanner Instance
    
    - parameter data: buffer.
    - parameter delimiter: to use with no arguments next() and hasNext().
    */
    public init(data: NSMutableData = NSMutableData(), delimiter: NSData) {
        self.data = data
        self.delimiter = delimiter
    }

    /**
    Create A MutableDataScanner Instance
    
    - parameter data: buffer.
    - parameter delimiter: to use with no arguments next() and hasNext().
    */
    public init(data: NSMutableData = NSMutableData(), delimiter: String) {
        self.data = data
        self.delimiter = delimiter.dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    /**
    Appends the content of another NSData object to the buffer.
    The data object whose content is to be appended to the contents of the buffer.
    
    - parameter data: The data object whose content is to be appended to the contents of the buffer.
    */
    public func appendData(data: NSData) {
        self.data.appendData(data)
    }
    
    /**
    It returns data for the specified length from the specified read start position, and then removed from the buffer.
    
    - parameter offset: reading start position
    - parameter length: reading data length
    
    - returns: Data of specified length
    */
    public func read(offset offset: Int, var length: Int) -> NSData? {
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
    
    /**
    It returns data for the specified length, and then removed from the buffer.
    
    - parameter length: reading data length
    
    - returns: Data of specified length
    */
    public func read(var length length: Int) -> NSData? {
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
    
    /**
    Returns true if it contains a delimiter in buffer.
    
    - parameter delimiter: delimiter data
    
    - returns: true if it contains a delimiter in buffer.
    */
    public func hasNext() -> Bool {
        guard let delimiter = delimiter else {
            fatalError("hasNext() need delimiter. eg: MutableDataScanner(delimiter: NSData or String)")
        }
        return self.hasNext(delimiter)
    }
    
    /**
    It returns the data to the next delimiter, and removes it from the buffer.
    If there is no delimiter in the buffer, it returns nil.
    It does not include delimiter in the data.
    
    - returns: data to the next delimiter.
    */
    public func next() -> NSData? {
        guard let delimiter = delimiter else {
            fatalError("next() need delimiter. eg: MutableDataScanner(delimiter: NSData or String)")
        }
        return self.next(delimiter)
    }
    
    /**
    Returns true if it contains a delimiter in buffer.
    
    - parameter delimiter: delimiter data
    
    - returns: true if it contains a delimiter in buffer.
    */
    public func hasNext(delimiter: String) -> Bool {
        guard let delimiter = delimiter.dataUsingEncoding(NSUTF8StringEncoding) else {
            fatalError("dataUsingEncoding(NSUTF8StringEncoding) failure.")
        }
        return self.hasNext(delimiter)
    }
    
    /**
    It returns the data to the next delimiter, and removes it from the buffer.
    If there is no delimiter in the buffer, it returns nil.
    It does not include delimiter in the data.
    
    - parameter delimiter: delimiter data
    
    - returns: data to the next delimiter.
    */
    public func next(delimiter: String) -> NSData? {
        guard let delimiter = delimiter.dataUsingEncoding(NSUTF8StringEncoding) else {
            fatalError("dataUsingEncoding(NSUTF8StringEncoding) failure.")
        }
        return self.next(delimiter)
    }
    
    /**
    Returns true if it contains a delimiter in buffer.
    
    - parameter delimiter: delimiter data
    
    - returns: true if it contains a delimiter in buffer.
    */
    public func hasNext(delimiter: NSData) -> Bool {
        let range = data.rangeOfData(delimiter, options: NSDataSearchOptions(rawValue: 0), range: NSMakeRange(0, data.length))
        return range.location != NSNotFound
    }
    
    /**
    It returns the data to the next delimiter, and removes it from the buffer.
    If there is no delimiter in the buffer, it returns nil.
    It does not include delimiter in the data.
    
    - parameter delimiter: delimiter data
    
    - returns: data to the next delimiter.
    */
    public func next(delimiter: NSData) -> NSData? {
        let range = data.rangeOfData(delimiter, options: NSDataSearchOptions(rawValue: 0), range: NSMakeRange(0, data.length))
        if range.location != NSNotFound {
            let line = data.subdataWithRange(NSMakeRange(0, range.location))
            data.replaceBytesInRange(NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
            return line
        } else {
            return nil
        }
    }
    
    /**
    Returns true if the buffer there is a line break
    It considers the CRLF or LF and line feed.
    
    - returns: true if the buffer there is a line break
    */
    public func hasNextLine() -> Bool {
        let range = data.rangeOfData(Static.LF, options: NSDataSearchOptions(rawValue: 0), range: NSMakeRange(0, data.length))
        return range.location != NSNotFound
    }
    
    /**
    It returns the following line, and then removed from the buffer.
    If there is no new line in the buffer, it returns nil.
    It considers the CRLF or LF and line feed.
    
    - returns: the next line
    */
    public func nextLine() -> NSData? {
        let range = data.rangeOfData(Static.LF, options: NSDataSearchOptions(rawValue: 0), range: NSMakeRange(0, data.length))
        if range.location != NSNotFound {
            let line: NSData
            if data.subdataWithRange(NSMakeRange(range.location - 1, 1)) == Static.CR {
                line = data.subdataWithRange(NSMakeRange(0, range.location - 1))
            } else {
                line = data.subdataWithRange(NSMakeRange(0, range.location))
            }
            data.replaceBytesInRange(NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
            return line
        } else {
            return nil
        }
    }
}
