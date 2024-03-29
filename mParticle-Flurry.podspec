Pod::Spec.new do |s|
    s.name             = "mParticle-Flurry"
    s.version          = "8.1.2"
    s.summary          = "Flurry integration for mParticle"

    s.description      = <<-DESC
                       This is the Flurry integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-flurry.git", :tag => "v" +s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticle"

    s.ios.deployment_target = "10.0"
    s.ios.source_files      = 'mParticle-Flurry/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 8.0'
    s.ios.dependency 'Flurry-iOS-SDK/FlurrySDK', '~> 12.2'
    s.static_framework = true

end
