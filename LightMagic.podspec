Pod::Spec.new do |s|
  s.name                = "LightMagic"
  s.homepage            = "https://bitbucket.org/0xc010d/lightmagic"
  s.version             = "0.0.1"
  s.summary             = "Light-weight depencency injection framework"
  s.license             = {
    :type => 'MIT', 
    :text => <<-LICENSE
The MIT License (MIT)

Copyright (c) 2014 Ievgen Solodovnykov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
    LICENSE
  }
  s.author              = { "Ievgen Solodovnykov" => "0xc010d@gmail.com" }
  s.platform            = :ios, '6.0'
  s.source              = { :git => "https://0xc010d@bitbucket.org/0xc010d/lightmagic.git", :commit => "081c88e" }
  s.source_files        = 'LightMagic/**/*.{m,mm}'
  s.public_header_files = 'LightMagic/LightMagic.h', 'LightMagic/LMContext.h', 'LightMagic/LMDefinitions.h'
  s.framework           = 'Foundation'

  non_arc_files =  'LightMagic/**/*.{h}', 'LightMagic/LMClass.mm', 'LightMagic/LMTemplateClass.mm', 'LightMagic/Cache/LMCache.mm'
  s.requires_arc = true
  s.exclude_files = non_arc_files
  s.subspec 'no-arc' do |sna|
    sna.source_files = non_arc_files
    sna.requires_arc = false
  end

  s.xcconfig = {
    'OTHER_LDFLAGS' => '-lc++ -lstdc++ -ObjC',
    'GENERATE_MASTER_OBJECT_FILE' => 'YES'
  }
end
