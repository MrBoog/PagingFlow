//
//  PagingFlowViewController.swift
//  PagingFlowLib
//
//  Created by 刘欢 on 2018/12/29.
//  Copyright © 2018 LH'sMacbook. All rights reserved.
//

import UIKit

public protocol PagingFlowViewControllerDelegate: NSObjectProtocol {
    func pageViewController(_ pagingViewController: PagingFlowViewController,
                            changingAmongTransition progress: CGFloat)
    func pageViewControllerDidChange(_ pagingViewController: PagingFlowViewController)
}

public protocol PagingFlowViewControllerDataSource: NSObjectProtocol {
    func viewControllers(in pagingViewController: PagingFlowViewController) -> [UIViewController]?
}


public class PagingFlowViewController: UIViewController {
    
    public weak var delegate: PagingFlowViewControllerDelegate?
    public weak var dataSource: PagingFlowViewControllerDataSource?
    
    private var viewControllers: [UIViewController] = []
    private var pendingViewControllers: [UIViewController] = []
    
    private var startDraggingOffset: CGPoint?
    
    private let pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return pageViewController
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.backgroundColor = .white
        addChild(pageViewController)
        
        pageViewController.didMove(toParent: self)
        view.addSubview(pageViewController.view)
        
        for view in pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
                break
            }
        }
    }
    
    public override func updateViewConstraints() {
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        super.updateViewConstraints()
    }
}


// MARK: - Public
extension PagingFlowViewController {
    
    public func reload() {
        // Workaround for clear the UIPageViewController's cache
        pageViewController.dataSource = nil
        pageViewController.dataSource = self

        viewControllers = dataSource?.viewControllers(in: self) ?? []
        if let vc = viewControllers.first {
            goToViewController(viewController: vc, animation: false)
        }
    }
    
    public func currentActiveViewController() -> UIViewController? {
        if let viewController = pageViewController.viewControllers?.first {
            return viewController
        }
        return nil
    }

    public func goToViewController(viewController: UIViewController?, animation: Bool) {
        if let vc = viewController, let destinationIndex = index(OfViewControllers: vc) {
            let activeIndex = index(OfViewControllers: currentActiveViewController())
            let earlier = activeIndex != nil && destinationIndex < activeIndex!
            pageViewController.setViewControllers([vc],
                                                  direction: earlier ? .reverse : .forward,
                                                  animated: animation,
                                                  completion: nil)
            activeViewControllerChanged()
        }
    }
}


// MARK: - Private
extension PagingFlowViewController {
    private func setup() {
        pageViewController.delegate = self
        pageViewController.dataSource = self
    }
    
    // Return true if removed success.
    @discardableResult
    private func emptyPagingViewControllerIfNeeded() -> Bool {
        // Because PagingVC has cache inside itself,
        // so try to empty it when no more viewControllers here.
        if viewControllers.count == 0 {
            pageViewController.setViewControllers([UIViewController()], direction: .forward, animated: false, completion: nil)
            return true
        }
        return false
    }
    
    private func activeViewControllerChanged() {
        delegate?.pageViewControllerDidChange(self)
    }
    
    private func viewController(at index: Int) -> UIViewController? {
        guard index >= 0 && index < viewControllers.count else {
            return nil
        }
        return viewControllers[index]
    }
    
    private func index(OfViewControllers viewController: UIViewController?) -> Int? {
        if let vc = viewController {
            return viewControllers.index(of: vc)
        }
        return 0
    }
}


// MARK: - UIPageViewControllerDelegate
extension PagingFlowViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.pendingViewControllers = pendingViewControllers
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if previousViewControllers.count > 0 &&
            self.pendingViewControllers.first != self.pageViewController.viewControllers?.first {
            pageViewController.setViewControllers(previousViewControllers, direction: .forward, animated: false, completion: nil)
        }
        activeViewControllerChanged()
    }
}


// MARK: - UIPageViewControllerDataSource
extension PagingFlowViewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.index(of: viewController) else {
                return nil
        }
        return self.viewController(at: index - 1)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.index(of: viewController) else {
                return nil
        }
        return self.viewController(at: index + 1)
    }
}


// MARK: - UIScrollViewDelegate
extension PagingFlowViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startDraggingOffset = scrollView.contentOffset
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startDraggingOffset = nil
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let offset = startDraggingOffset {
            if abs(offset.x - scrollView.frame.width) < 10 {
                let currentDraggingOffset = scrollView.contentOffset
                let delta = -(offset.x - currentDraggingOffset.x)
                let progress = delta / scrollView.frame.width
                delegate?.pageViewController(self, changingAmongTransition: progress)
            }
        }
    }
}
