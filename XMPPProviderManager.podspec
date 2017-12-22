Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '9.0'
s.name = "XMPPProviderManager"
s.summary = "Provider manager to parse and send class through XMPPFramework"
s.requires_arc = true

# 2
s.version = "0.1.0"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Luca Becchetti" => "luca.becchetti@brokenice.it" }


# 5 - Replace this URL with your own Github page's URL (from the address bar)
s.homepage = "http://gitrepo.frind.it/Becchetti/XMPPProviderManger"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/lucabecchetti/XMPPProviderManger.git", :tag => "#{s.version}"}

# 7
s.dependency 'XMPPFramework'

s.source_files = "XMPPProviderManager/*.swift"

end
