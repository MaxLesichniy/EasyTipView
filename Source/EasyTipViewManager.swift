//
//  TooltipView.swift
//  InFitting
//
//  Created by Maksym on 09.08.17.
//  Copyright © 2017 OnCreate. All rights reserved.
//

import UIKit

public class EasyTipViewManager: EasyTipViewDelegate {

    public typealias DismissClosure = (EasyTipView) -> Void
    private typealias TipInfo = (tip: EasyTipView, dismissClosure: DismissClosure?, timer: Timer?)
    
    public static let `default` = EasyTipViewManager()
    
    private var tipViews: [TipInfo] = []
    public var preferences: EasyTipView.Preferences = EasyTipView.globalPreferences

    public init() {
        
    }
    
    @discardableResult
    public func show(customView: UIView, forView view: UIView, withinSuperview superview: UIView? = nil, hideAfter: TimeInterval? = 3,  animated: Bool = true, hideOthers: Bool = true, preferences p: EasyTipView.Preferences? = nil, dismissClosure: DismissClosure? = nil) -> EasyTipView {
        let tipView = EasyTipView(customView: customView, preferences: p ?? self.preferences, delegate: self)
        show(tipView: tipView, forView: view, withinSuperview: superview, hideAfter: hideAfter, animated: animated, hideOthers: hideOthers, dismissClosure: dismissClosure)
        return tipView
    }
    
    @discardableResult
    public func show(text: String, forView view: UIView, withinSuperview superview: UIView? = nil, hideAfter: TimeInterval? = 3,  animated: Bool = true, hideOthers: Bool = true, preferences p: EasyTipView.Preferences? = nil, dismissClosure: DismissClosure? = nil) -> EasyTipView {
        let tipView = EasyTipView(text: text, preferences: p ?? self.preferences, delegate: self)
        show(tipView: tipView, forView: view, withinSuperview: superview, hideAfter: hideAfter, animated: animated, hideOthers: hideOthers, dismissClosure: dismissClosure)
        return tipView
    }
    
    private func show(tipView: EasyTipView, forView view: UIView, withinSuperview superview: UIView? = nil, hideAfter: TimeInterval? = 3,  animated: Bool = true, hideOthers: Bool = true, dismissClosure: DismissClosure? = nil) {
        
        var timer: Timer? = nil
        if let hideAfter = hideAfter {
            timer = Timer.scheduledTimer(timeInterval: hideAfter, target: self, selector: #selector(timerHandler(_:)), userInfo: ["tip": tipView], repeats: false)
        }
        
        if hideOthers {
            tipViews.forEach { $0.tip.dismiss() }
        }
        
        tipViews.append((tipView, dismissClosure, timer))
        
        tipView.show(animated: animated, forView: view, withinSuperview: superview)
    }
    
    public func hideAll() {
        tipViews.forEach { $0.tip.dismiss() }
    }
    
    @objc private func timerHandler(_ sender: Timer) {
        guard let tipInfo = self.tipViews.filter({ (item) -> Bool in
            return item.timer == sender
        }).first else { return }
        
        tipInfo.tip.dismiss()
    }
    
    //MARK: - 
    
    public func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        guard let tipInfo = self.tipViews.filter({ (item) -> Bool in
            return item.tip == tipView
        }).first else { return }

        tipInfo.dismissClosure?(tipView)
        tipInfo.timer?.invalidate()
        
        guard let index = self.tipViews.firstIndex(where: { $0.tip == tipView }) else {
            return
        }
        
        tipViews.remove(at: index)
    }
    
}


extension EasyTipViewManager {
    
    public class  func show( text:  String, forView view: UIView, withinSuperview superview: UIView? = nil, hideAfter: TimeInterval? = 3,  animated: Bool = true, hideOthers: Bool = true, preferences p: EasyTipView.Preferences? = nil, dismissClosure: DismissClosure? = nil) -> EasyTipView {
        return EasyTipViewManager.default.show(text: text, forView: view, withinSuperview: superview, hideAfter: hideAfter, animated: animated, hideOthers: hideOthers, preferences: p, dismissClosure: dismissClosure)
    }
    
}
