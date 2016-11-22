//
//  MutableDataScanner.swift
//  MutableDataScanner
//
//  Created by Shinichiro Aska on 8/20/15.
//  Copyright © 2015 Shinichiro Aska. All rights reserved.
//

import Foundation

/// A simple text scanner which can parse NSMutableData using delimiter module, but as a class.
open class MutableDataScanner {

    /// Constants to use nextLine() and hasNextLine().
    struct Static {
        static let dataCR = "\r".data(using: String.Encoding.utf8)!
        static let dataLF = "\n".data(using: String.Encoding.utf8)!
        static let options = Data.SearchOptions(rawValue: 0)
    }

    /// buffer.
    open var data: Data

    /// delimiter to use with no arguments next() and hasNext().
    open var delimiter: Data?

    /**
     Create A MutableDataScanner Instance

     */
    public init() {
        self.data = Data()
        self.delimiter = nil
    }

    /**
     Create A MutableDataScanner Instance

     - parameter delimiter: to use with no arguments next() and hasNext().
     */
    public init(delimiter: Data) {
        self.data = Data()
        self.delimiter = delimiter
    }

    /**
     Create A MutableDataScanner Instance

     - parameter delimiter: to use with no arguments next() and hasNext().
     */
    public init(delimiter: String) {
        self.data = Data()
        self.delimiter = delimiter.data(using: String.Encoding.utf8)!
    }

    /**
     Appends the content of another Data object to the buffer.
     The data object whose content is to be appended to the contents of the buffer.

     - parameter data: Data to be added to the buffer.
     */
    open func append(_ data: Data) {
        self.data.append(data)
    }

    /**
     It returns data for the specified length from the specified read start position,
     and then removed from the buffer.

     - parameter offset: reading start position
     - parameter length: reading data length

     - returns: Data of specified length
     */
    open func read(_ offset: Int, length: Int) -> Data? {
        if offset > data.count {
            return nil
        }
        let length = min(length, data.count - offset)
        let chunk = data.subdata(in: offset..<offset + length)
        data.replaceSubrange(0..<offset + length, with: Data())
        return chunk
    }

    /**
     It returns data for the specified length, and then removed from the buffer.

     - parameter length: reading data length

     - returns: Data of specified length
     */
    open func read(_ length: Int) -> Data? {
        if data.count == 0 {
            return nil
        }
        let length = min(length, data.count)
        let line = data.subdata(in: 0..<length)
        data.replaceSubrange(0..<length, with: Data())
        return line
    }

    /**
     Returns true if it contains a delimiter in buffer.

     - returns: true if it contains a delimiter in buffer.
     */
    open func hasNext() -> Bool {
        guard let delimiter = delimiter else {
            fatalError("hasNext() need delimiter."
                + " eg: MutableDataScanner(delimiter: Data or String)")
        }
        return self.hasNext(delimiter)
    }

    /**
     It returns the data to the next delimiter, and removes it from the buffer.
     If there is no delimiter in the buffer, it returns nil.
     It does not include delimiter in the data.

     - returns: data to the next delimiter.
     */
    open func next() -> Data? {
        guard let delimiter = delimiter else {
            fatalError("next() need delimiter. eg: MutableDataScanner(delimiter: Data or String)")
        }
        return self.next(delimiter)
    }

    /**
     Returns true if it contains a delimiter in buffer.

     - parameter delimiter: delimiter data

     - returns: true if it contains a delimiter in buffer.
     */
    open func hasNext(_ delimiter: String) -> Bool {
        guard let delimiter = delimiter.data(using: String.Encoding.utf8) else {
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
    open func next(_ delimiter: String) -> Data? {
        guard let delimiter = delimiter.data(using: String.Encoding.utf8) else {
            fatalError("dataUsingEncoding(NSUTF8StringEncoding) failure.")
        }
        return self.next(delimiter)
    }

    /**
     Returns true if it contains a delimiter in buffer.

     - parameter delimiter: delimiter data

     - returns: true if it contains a delimiter in buffer.
     */
    open func hasNext(_ delimiter: Data) -> Bool {
        guard let _ = data.range(of: delimiter) else {
            return false
        }
        return true
    }

    /**
     It returns the data to the next delimiter, and removes it from the buffer.
     If there is no delimiter in the buffer, it returns nil.
     It does not include delimiter in the data.

     - parameter delimiter: delimiter data

     - returns: data to the next delimiter.
     */
    open func next(_ delimiter: Data) -> Data? {
        guard let range = data.range(of: delimiter) else {
            return nil
        }
        let line = data.subdata(in: 0..<range.lowerBound)
        data.replaceSubrange(0..<range.upperBound, with: Data())
        return line
    }

    /**
     Returns true if the buffer there is a line break
     It considers the CRLF or LF and line feed.

     - returns: true if the buffer there is a line break
     */
    open func hasNextLine() -> Bool {
        return data.range(of: Static.dataLF) != nil
    }

    /**
     It returns the following line, and then removed from the buffer.
     If there is no new line in the buffer, it returns nil.
     It considers the CRLF or LF and line feed.

     - returns: the next line
     */
    open func nextLine() -> Data? {
        guard let range = data.range(of: Static.dataLF) else {
            return nil
        }
        let line: Data
        let rcRange = data.range(of: Static.dataCR,
                                 options: Static.options,
                                 in: range.lowerBound - 1..<range.lowerBound)
        if rcRange != nil {
            line = data.subdata(in: 0..<range.lowerBound - 1)
        } else {
            line = data.subdata(in: 0..<range.lowerBound)
        }
        data.replaceSubrange(0..<range.upperBound, with: Data())
        return line
    }
}
