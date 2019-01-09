//
//  ViewController.swift
//  Channels
//
//  Created by 刘欢 on 2019/1/8.
//  Copyright © 2019 LH'sMacbook. All rights reserved.
//

import UIKit
import PagingFlow

class ViewController: UIViewController {
    
    private let pagingVC: PagingFlowViewController = {
        let pagingVC = PagingFlowViewController()
        return pagingVC
    }()

    private let viewControllers = [UIViewController(),UIViewController(),UIViewController()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        pagingVC.view.translatesAutoresizingMaskIntoConstraints = false
        pagingVC.dataSource = self
        pagingVC.delegate = self
        
        addChild(pagingVC)
        pagingVC.didMove(toParent: self)
        view.addSubview(pagingVC.view)
        
        pagingVC.reload()
    }

    override func updateViewConstraints() {
        if #available(iOS 11, *) {
            NSLayoutConstraint.activate([
                pagingVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                pagingVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                pagingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                pagingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                ])
        } else {
            NSLayoutConstraint.activate([
                pagingVC.view.topAnchor.constraint(equalTo: view.topAnchor),
                pagingVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                pagingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                pagingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                ])
        }
        super.updateViewConstraints()
    }
    
    private func randomViewControllersFactory() -> [UIViewController]? {
        let count = Int.random(in: 3 ... 6)
        var vcs: [UIViewController] = []
        func randomFloat() -> CGFloat {
            return CGFloat.random(in: 0 ... 255.0)/255.0
        }
        for _ in 0 ..< count {
            let vc = UIViewController()
            let red: CGFloat = randomFloat()
            let green: CGFloat = randomFloat()
            let blue: CGFloat = randomFloat()
            vc.view.backgroundColor = UIColor.init(red: red, green: green, blue: blue, alpha: 1)
            vcs.append(vc)
        }
        return vcs
    }
}

extension ViewController: PagingFlowViewControllerDelegate {
    func pageViewControllerDidChange(_ pagingViewController: PagingFlowViewController) {
        
    }
    
    func pageViewController(_ pagingViewController: PagingFlowViewController, changingAmongTransition progress: CGFloat) {
        
    }
}

extension ViewController: PagingFlowViewControllerDataSource {
    func viewControllers(in pagingViewController: PagingFlowViewController) -> [UIViewController]? {
        return randomViewControllersFactory()
    }
}
