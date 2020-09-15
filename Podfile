project 'Notifire'
use_frameworks!
platform :ios, '11.0'

abstract_target 'Abst' do

  # Pods for Notifire
  pod 'KeychainAccess', '4.2.0'

  target 'Notifire' do
    pod 'GoogleSignIn'

  end

  target 'Notifire Mock' do
    pod 'GoogleSignIn'
  end


  target 'NotifireUITests' do
    platform :ios, '11.0'
    inherit! :complete
    pod 'GoogleSignIn'
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
      end
    end
  end
end

target 'NotificationServiceExtension' do
end

target 'NotifireTests' do
  inherit! :complete
end