//  Created by Axel Ancona Esselmann on 7/5/20.
//

import Foundation

public protocol ViewContainerDataProvider: class {
    var numberOfElements: Int { get }
}

public protocol ViewContainerDelegate: class {
    func viewContainer(_ viewContainer: ViewContainer, viewForIndex index: Int) -> UIView?
}

open class ManagedViewContainer: ViewContainer {
    public weak var dataProvider: ViewContainerDataProvider?
    public weak var displayDelegate: ViewContainerDelegate?

    private var currentIndex: Int?

    private var temporaryNextIndex: Int?

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
        if currentIndex == nil, (dataProvider?.numberOfElements ?? 0) > 0 {
            currentIndex = 0
        }
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
