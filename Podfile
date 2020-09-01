project 'Notifire'

target 'Notifire' do
  platform :ios, '11.0'
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  inhibit_all_warnings!

  # Pods for Notifire
  pod 'SwiftLint', '0.39.2'
  pod 'KeychainAccess', '4.2.0'

  target 'Notifire Mock' do
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

  target 'NotificationServiceExtension' do
  end

  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        # Removes the "Update to recommended settings" warning from Xcode
        # https://github.com/CocoaPods/CocoaPods/issues/8242
        config.build_settings.delete('ARCHS')
        
        # Removes the warnings from all pods
        # https://github.com/CocoaPods/CocoaPods/issues/4423
        config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
      end
    end
  end

end

