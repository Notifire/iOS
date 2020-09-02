project 'Notifire'
use_frameworks!
platform :ios, '11.0'

abstract_target 'Abst' do

  # Pods for Notifire
  pod 'SwiftLint', '0.39.2'
  pod 'KeychainAccess', '4.2.0'
  
  target 'Notifire' do
    pod 'GoogleSignIn'
  end

  target 'Notifire Mock' do
    pod 'GoogleSignIn'
  end


target 'NotificationServiceExtension' do
end

  #target 'NotifireTests' do
  #  inherit! :search_paths
  #  # Pods for testing
  #end

  #target 'NotifireUITests' do
  #  inherit! :complete
  #  # Pods for testing
  #end

  #target 'NotifireScreenshots' do
  #end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        # Removes the "Update to recommended settings" warning from Xcode
        # https://github.com/CocoaPods/CocoaPods/issues/8242
        config.build_settings.delete('ARCHS')
        
        # Removes the warnings from all pods
        # https://github.com/CocoaPods/CocoaPods/issues/4423
        config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"

        # Removes the "Linking against dylib which is not safe to use" warning
        config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = "No"
      end
    end
  end
end