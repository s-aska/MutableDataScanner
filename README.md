# MutableDataScanner

[![Build Status](https://www.bitrise.io/app/b6bf3a2353584846.svg?token=AfNOSpFuWfABDb-o68wScg&branch=master)](https://www.bitrise.io/app/b6bf3a2353584846)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![](https://img.shields.io/badge/Xcode-8%2B-brightgreen.svg?style=flat)]()
[![](https://img.shields.io/badge/iOS-8.0%2B-brightgreen.svg?style=flat)]()
[![](https://img.shields.io/badge/OS%20X-10.10%2B-brightgreen.svg?style=flat)]()

A simple text scanner which can parse NSMutableData using delimiter.

Faster because it does not have to do a NSData <-> String conversion.

It can be easily and reliably parse of the Twitter Streaming API and other stream.


### Performance

Test: https://github.com/s-aska/MutableDataScanner/blob/master/MutableDataScannerTests/MutableDataScannerTests.swift

- MutableDataScanner specific delimiter ... average: __0.071__
- MutableDataScanner line delimiter ( CRLF or LF ) ... average: 0.092
- String#componentsSeparatedByString ... average: 0.304


## Usage

### for Twitter Streaming API

See [Processing streaming data](https://dev.twitter.com/streaming/overview/processing) for information about the Parsing responses you will receive from the streaming API.

```swift
import Foundation
import MutableDataScanner
import SwiftyJSON

class TwitterAPIStreamingRequest: NSObject, NSURLSessionDataDelegate {

    let scanner = MutableDataScanner(delimiter: "\r\n")

    // ...

    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.scanner.appendData(data)
        while let data = self.scanner.next() {
            if data.length > 0 {
                let json = JSON(data: data)
            }
        }
    }
}
```

### Bytes

- `read(length: Int) -> NSData?`

```swift
let data = "0123456789abcdefghijklmnopqrstuvwxyz".dataUsingEncoding(NSUTF8StringEncoding)!
let scanner = MutableDataScanner(data: data)

scanner.read(length: 10) // => 0123456789
scanner.read(length: 10) // => abcdefghij
scanner.read(length: 10) // => klmnopqrst
scanner.read(length: 10) // => uvwxyz
scanner.read(length: 10) // => (nil)
```

- `read(offset: Int, length: Int) -> NSData?`

```swift
let data = "0123456789abcdefghijklmnopqrstuvwxyz".dataUsingEncoding(NSUTF8StringEncoding)!
let scanner = MutableDataScanner(data: data)

scanner.read(offset: 5, length: 5) // => 56789
scanner.read(offset: 5, length: 5) // => fghij
scanner.read(offset: 5, length: 5) // => pqrst
scanner.read(offset: 5, length: 5) // => z
scanner.read(offset: 5, length: 5) // => (nil)
```

### Delimiter

#### Specify the delimiter in the properties.

- `init(data: NSMutableData = default, delimiter: NSData)`
- `init(data: NSMutableData = default, delimiter: String)`
- `next() -> NSData?`
- `hasNext() -> Bool`

```swift
let data = "0123456789\nabcdefghijklmnopqrstuvwxyz\n0123".dataUsingEncoding(NSUTF8StringEncoding)!
let scanner = MutableDataScanner(data: data, delimiter: "\n")

scanner.data // => 0123456789\nabcdefghijklmnopqrstuvwxyz\n0123

scanner.hasNext() // => true
scanner.next() // => 0123456789
scanner.data // => abcdefghijklmnopqrstuvwxyz\n0123

scanner.hasNext() // => true
scanner.next() // => abcdefghijklmnopqrstuvwxyz
scanner.data // => 0123

scanner.hasNext() // => false
scanner.next() // => (nil)
```

#### Specify the delimiter in the arguments.

- `next(delimiter: NSData) -> NSData?`
- `hasNext(delimiter: NSData) -> Bool`
- `next(delimiter: String) -> NSData?`
- `hasNext(delimiter: String) -> Bool`

```swift
let data = "0123456789\nabcdefghijklmnopqrstuvwxyz\n0123".dataUsingEncoding(NSUTF8StringEncoding)!
let scanner = MutableDataScanner(data: data)

scanner.data // => 0123456789\nabcdefghijklmnopqrstuvwxyz\n0123

scanner.hasNext("\r\n") // => false
scanner.hasNext("\n") // => true
scanner.next("\r\n") // => (nil)
scanner.next("\n") // => 0123456789
scanner.data // => abcdefghijklmnopqrstuvwxyz\n0123
```

#### CRLF or LF

- `nextLine() -> NSData?`
- `hasNextLine -> Bool`

```swift
let data = "0123456789\r\nabcdefghijklmnopqrstuvwxyz\n0123".dataUsingEncoding(NSUTF8StringEncoding)!
let scanner = MutableDataScanner(data: data)

scanner.data // => 0123456789\r\nabcdefghijklmnopqrstuvwxyz\n0123

scanner.hasNextLine() // => true
scanner.nextLine() // => 0123456789
scanner.data // => abcdefghijklmnopqrstuvwxyz\n0123

scanner.hasNextLine() // => true
scanner.nextLine() // => abcdefghijklmnopqrstuvwxyz
scanner.data // => 0123

scanner.hasNextLine() // => false
scanner.nextLine() // => (nil)
```


## Requirements

- iOS 8.0+ / Mac OS X 10.10+
- Xcode 8+ / Swift 3+


## Installation

#### Carthage

Add the following line to your [Cartfile](https://github.com/carthage/carthage)

```
github "s-aska/MutableDataScanner"
```

#### CocoaPods

Add the following line to your [Podfile](https://guides.cocoapods.org/)

```
use_frameworks!
pod 'MutableDataScanner'
```


## License

MutableDataScanner is released under the MIT license. See LICENSE for details.
