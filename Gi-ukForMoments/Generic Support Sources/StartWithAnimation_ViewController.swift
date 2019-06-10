//
//  Animate_Test_ViewController.swift
//  Gi-ukForMoments
//
//  Created by goya on 10/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class StartWithAnimation_ViewController: ContentUIViewController {
    
    private(set) var initailStage: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateInitialStage()
    }
    
    var initialAnimationTimeDuration: Double = 0.75
    
    var initialAnimationDelay: Double = 0.5
    
    var requieredAnimationWithInInitialStage: (() -> Void)?
    
    var requieredFunctionWithInInitialStageAnimationCompleted: (() -> Void)?
    
    private func animateInitialStage() {
        if initailStage {
            initailStage = false
            UIView.animate(withDuration: initialAnimationTimeDuration, delay: initialAnimationDelay, options: [.curveEaseInOut], animations: {
                self.requieredAnimationWithInInitialStage?()
            }, completion: { [unowned self] (finished) in
                self.view.isUserInteractionEnabled = finished
                self.requieredFunctionWithInInitialStageAnimationCompleted?()
            })
        }
    }
}
