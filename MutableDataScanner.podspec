Pod::Spec.new do |s|
  s.name             = "MutableDataScanner"
  s.version          = "1.0.5"
  s.summary          = "A simple text scanner which can parse NSMutableData using delimiter."
  s.description      = <<-DESC
                         A simple text scanner which can parse NSMutableData using delimiter.
                         Faster because it does not have to do a NSData <-> String conversion.
                         It can be easily and reliably parse of the Twitter Streaming API and other stream.
                       DESC
  s.homepage         = "https://github.com/s-aska/MutableDataScanner"
  s.license          = "MIT"
  s.author           = { "aska" => "s.aska.org@gmail.com" }
  s.social_media_url = "https://twitter.com/su_aska"
  s.source           = { :git => "https://github.com/s-aska/MutableDataScanner.git", :tag => "#{s.version}" }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.requires_arc = true

  s.source_files = 'MutableDataScanner/*.swift'
end
