import Foundation
import React

@objc(CounterViewManager)
class CounterViewManager: RCTViewManager {
    
    override func view() -> UIView! {
        return CounterView()
    }
    
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    @objc func increment(_ reactTag: NSNumber) {
        DispatchQueue.main.async {
            self.bridge.uiManager.addUIBlock { (uiManager, viewRegistry) in
                guard let view = viewRegistry?[reactTag] as? CounterView else {
                    return
                }
                view.increment()
            }
        }
    }
    
    @objc func decrement(_ reactTag: NSNumber) {
        DispatchQueue.main.async {
            self.bridge.uiManager.addUIBlock { (uiManager, viewRegistry) in
                guard let view = viewRegistry?[reactTag] as? CounterView else {
                    return
                }
                view.decrement()
            }
        }
    }
}

