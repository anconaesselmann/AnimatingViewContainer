//  Created by Axel Ancona Esselmann on 7/5/20.
//

import UIKit

public protocol ViewContainerDataProvider: class {
    var numberOfElements: Int { get }
}

public protocol ViewContainerDelegate: class {
    func viewContainer(_ viewContainer: ViewContainer, viewForIndex index: Int) -> UIView?
}

extension ViewContainerDelegate {
     func viewContainer(_ viewContainer: ViewContainer, didPresentElementAtIndex index: Int) -> Void {
        /* intentionally left blank */
    }
}

open class ManagedViewContainer: ViewContainer {
    public weak var dataProvider: ViewContainerDataProvider?
    public weak var displayDelegate: ViewContainerDelegate?

    private var currentIndex: Int?

    private var temporaryNextIndex: Int?

    private var _pageControl: UIPageControl?

    public var pageControl: UIPageControl {
        // Lazily create when accessing property publiclly. Don't create when accessing it internally
        get {
            if let pageControl = _pageControl {
                return pageControl
            } else {
                let pageControl = UIPageControl()
                pageControl.numberOfPages = dataProvider?.numberOfElements ?? 0
                pageControl.currentPage = currentIndex ?? 0
                _pageControl = pageControl
                return pageControl
            }
        }
    }

    private func getView(forIndex index: Int) -> UIView? {
        guard let dataProvider = dataProvider else {
            return nil
        }
        guard dataProvider.numberOfElements > 0 else {
            return nil
        }
        guard index < dataProvider.numberOfElements && index >= 0 else {
            return nil
        }
        return displayDelegate?.viewContainer(self, viewForIndex: index)
    }

    public init() {
        super.init(initialView: UIView())
        getNextView = { [weak self] in
            guard let currentIndex = self?.currentIndex else {
                return nil
            }
            let nextIndex = currentIndex + 1
            guard let nextView = self?.getView(forIndex: nextIndex) else {
                return nil
            }
            self?.temporaryNextIndex = nextIndex
            return nextView
        }
        getPreviousView = { [weak self] in
            guard let currentIndex = self?.currentIndex else {
                return nil
            }
            let nextIndex = currentIndex - 1
            guard let nextView = self?.getView(forIndex: nextIndex) else {
                return nil
            }
            self?.currentIndex = nextIndex
            self?.temporaryNextIndex = nextIndex
            return nextView
        }
        delegate = self
    }

    @discardableResult
    public func reloadData() -> Self {
        let numberOfElements = dataProvider?.numberOfElements ?? 0
        if currentIndex == nil, numberOfElements > 0 {
            currentIndex = 0
        }
        _pageControl?.numberOfPages = numberOfElements
        guard let currentIndex = currentIndex, let currentView = getView(forIndex: currentIndex) else {
            return self
        }
        self.set(currentView: currentView)
        return self
    }
}

extension ManagedViewContainer: ViewContainerStateChangeDelegate {
    public func viewContainer(_ viewContainer: ViewContainer, hasChangedState state: ViewContainer.State) {
        switch state {
        case .begin(_):
            ()
        case .changed(_):
            ()
        case .end:
            if let nextIndex = temporaryNextIndex {
                currentIndex = nextIndex
                _pageControl?.currentPage = nextIndex
                displayDelegate?.viewContainer(self, didPresentElementAtIndex: nextIndex)
                temporaryNextIndex = nil
            }
        case .failed:
            temporaryNextIndex = nil
            ()
        }
    }

}

public extension ManagedViewContainer {
    @discardableResult
    func displayDelegate(_ delegate: ViewContainerDelegate) -> Self {
        displayDelegate = delegate
        return self
    }

    @discardableResult
    func dataProvider(_ dataProvider: ViewContainerDataProvider) -> Self {
        self.dataProvider = dataProvider
        return self
    }

    @discardableResult
    func viewTransitionSpeed(_ currentViewTransitionSpeed: CGFloat) -> Self {
        self.currentViewTransitionSpeed = currentViewTransitionSpeed
        return self
    }
}
