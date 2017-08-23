Pod::Spec.new do |s|

  s.name         = "SCNNodeVisualDebugger"
  s.version      = "0.0.1"
  s.summary      = "SCNNodeVisualDebugger in Swift"

  s.description  = "Visual Debugger"

  s.homepage     = "https://github.com/handsomecode/SCNNodeVisualDebugger"

  s.license      = "Apache 2.0 license"

  s.author             = { "Andrey Arzhannikov" => "andreya@handsome.is" }

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/handsomecode/SCNNodeVisualDebugger.git", :branch => "feature/add-cocoapods-support" }

  s.source_files  = "Source/*.swift"

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }

end