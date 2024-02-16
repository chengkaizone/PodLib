
Pod::Spec.new do |spec|

  spec.name         = 'Flashback'
  spec.version      = '1.0.0'
  spec.summary      = 'App Flashback Customization service.'
  spec.homepage     = 'https://lineying.cn'
  spec.description  = <<-DESC   
  App Flashback Customization service.
                       DESC

  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = 'lineying'
  
  spec.platform     = :ios, '12.0'

  spec.source = { :git => 'https://lineying.cn' }

  spec.requires_arc = true
  # spec.user_target_xcconfig =   {'OTHER_LDFLAGS' => ['-lObjC']}
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  
  spec.ios.deployment_target = '12.0'

  valid_archs = ['arm64', 'armv7', 'x86_64', 'i386']

	spec.ios.vendored_frameworks = 'Flashback.framework'
  # spec.dependency 'Ads'

end
