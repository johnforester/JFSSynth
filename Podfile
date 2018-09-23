platform :ios, '8.1'

def shared_pods
    pod 'TheAmazingAudioEngine', '1.5.8'
end

target 'JFSynth' do
    shared_pods
end

target 'JFSynthTests' do
    shared_pods
end

# https://github.com/CocoaPods/CocoaPods/issues/8069
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 8.1
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.1'
            end
        end
    end
end
