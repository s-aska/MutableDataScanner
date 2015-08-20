# MutableDataScanner

[![Build Status](https://www.bitrise.io/app/b6bf3a2353584846.svg?token=AfNOSpFuWfABDb-o68wScg&branch=master)](https://www.bitrise.io/app/b6bf3a2353584846)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![](http://img.shields.io/badge/iOS-8.0%2B-brightgreen.svg?style=flat)]()
[![](http://img.shields.io/badge/OS%20X-10.10%2B-brightgreen.svg?style=flat)]()

A simple text scanner which can parse NSMutableData using delimiter.

Faster because it does not have to do a NSData <-> String conversion.

It can be easily and reliably parse of the Twitter Streaming API and other stream.


### Performance

Test: https://github.com/s-aska/MutableDataScanner/blob/master/MutableDataScannerTests/MutableDataScannerTests.swift

- MutableDataScanner auto delimiter ( CRLF or LF ) ... average: 0.092
- MutableDataScanner specific delimiter ... average: __0.071__
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
        while let data = self.scanner.nextLine() {
            if data.length > 0 {
                let json = JSON(data: data)
            }
        }
    }
}
```


## Requirements

- iOS 8.0+ / Mac OS X 10.10+
- Swift 2.0 and Xcode 7 beta 5


## Installation

#### Carthage

Add the following line to your [Cartfile](https://github.com/carthage/carthage)

```swift
github "s-aska/MutableDataScanner"
```

#### CocoaPods

Add the following line to your [Podfile](https://guides.cocoapods.org/)

```swift
pod 'MutableDataScanner', :git => 'git@github.com:s-aska/MutableDataScanner.git'
```


## License

MutableDataScanner is released under the MIT license. See LICENSE for details.
