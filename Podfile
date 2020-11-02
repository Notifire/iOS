project 'Notifire'
platform :ios, '11.0'
use_frameworks!

# Turn on to disable all warnings from Pods
# inhibit_all_warnings!

abstract_target 'Abst' do

  # Pods for Notifire
  pod 'KeychainAccess', '4.2.0'
  pod 'GoogleSignIn', :inhibit_warnings => true

  target 'Notifire' do
    pod 'Starscream', '~> 4.0.0'
    # pod 'SkeletonView', '~> 1.9'
  end

  target 'Notifire Mock' do
    pod 'Starscream', '~> 4.0.0'
    # pod 'SkeletonView', '~> 1.9'
  end


  target 'NotifireUITests' do
    platform :ios, '11.0'
    inherit! :complete
  end

  #target 'NotifireScreenshots' do
  #end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        # Removes the "Update to recommended settings" warning from Xcode
        # https://github.com/CocoaPods/CocoaPods/issues/8242
        config.build_settings.delete('ARCHS')

        # Removes the "Linking against dylib which is not safe to use" warning
        config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = "NO"

        # https://stackoverflow.com/questions/54704207/the-ios-simulator-deployment-targets-is-set-to-7-0-but-the-range-of-supported-d
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      end
    end
  end
end

target 'NotificationServiceExtension' do
  use_frameworks!
  platform :ios, '11.0'
  inherit! :none
end

target 'NotifireTests' do
  inherit! :complete
end