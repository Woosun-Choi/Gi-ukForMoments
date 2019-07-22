//
//  GiukPresentViewController.swift
//  Gi-ukForMoments
//
//  Created by goya on 19/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class GiukPresentViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    lazy var targetViewControllers: [UIViewController] = {
        let redView = UIViewController()
        redView.view.backgroundColor = .red
        let blueView = UIViewController()
        blueView.view.backgroundColor = .blue
        return [redView,blueView]
    }()
    
    override var transitionStyle: UIPageViewController.TransitionStyle {
        return .pageCurl
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers([targetViewControllers[0]], direction: .forward, animated: true, completion: nil)
        dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentView = targetViewControllers.firstIndex(of: viewController) {
            if currentView == 0 {
                return targetViewControllers[1]
            } else {
                return targetViewControllers[0]
            }
        } else {
            print("failed")
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentView = targetViewControllers.firstIndex(of: viewController) {
            if currentView == 1 {
                return targetViewControllers[0]
            } else {
                return targetViewControllers[1]
            }
        } else {
            print("failed")
        return nil
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
