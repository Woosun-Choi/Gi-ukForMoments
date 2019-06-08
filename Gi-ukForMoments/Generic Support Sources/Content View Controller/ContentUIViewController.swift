//
//  ContentUIViewController.swift
//  LinearTimeLineViewDemo
//
//  Created by goya on 21/04/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class ContentUIViewController: UIViewController {
    
    private var safaAreaRelatedView : UIView!
    
    var safeAreaRelatedAreaFrame: CGRect {
        return safaAreaRelatedView.frame
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setContentView()
        loadContentViewMargins()
        safaAreaRelatedView.layoutIfNeeded()
        print("view did load - \n safeAreaRect : \(safeAreaRelatedAreaFrame)\n viewFrame: \(view.frame)")
    }
    
    private func setContentView() {
        if safaAreaRelatedView == nil {
            let contentArea = UIView()
            contentArea.translatesAutoresizingMaskIntoConstraints = false
            contentArea.contentMode = .redraw
            contentArea.backgroundColor = .clear
            safaAreaRelatedView = contentArea
            view.addSubview(contentArea)
        }
    }
    
    private func loadContentViewMargins() {
        //let margins = view.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            safaAreaRelatedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            safaAreaRelatedView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                safaAreaRelatedView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
                guide.bottomAnchor.constraint(equalToSystemSpacingBelow: safaAreaRelatedView.bottomAnchor, multiplier: 1.0)
                ])
        } else {
            let standardSpacing: CGFloat = 8.0
            NSLayoutConstraint.activate([
                safaAreaRelatedView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
                bottomLayoutGuide.topAnchor.constraint(equalTo: safaAreaRelatedView.bottomAnchor, constant: standardSpacing)
                ])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appear - \n safeAreaRect : \(safeAreaRelatedAreaFrame)\n viewFrame: \(view.frame)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view did appear - \n safeAreaRect : \(safeAreaRelatedAreaFrame)\n viewFrame: \(view.frame)")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("view will layout subviews - \n safeAreaRect : \(safeAreaRelatedAreaFrame)\n viewFrame: \(view.frame)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("view did subviews - \n safeAreaRect : \(safeAreaRelatedAreaFrame)\n viewFrame: \(view.frame)")
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
