//  Created by Axel Ancona Esselmann on 7/5/20.
//  Copyright © 2020 Axel Ancona Esselmann. All rights reserved.
//

import UIKit
import constrain

public class ViewContainer: UIView {

    public enum State {
        case begin(HorizontalDirection)
        case changed(CGFloat)
        case end
        case failed
    }

    public var dropShadow: DropShadow? = DropShadow()

    public var canTransition: Bool = true

    private var currentViewCenter: NSLayoutConstraint?
    private var nextViewCenter: NSLayoutConstraint?

    private var animating = false

    public weak var delegate: ViewContainerStateChangeDelegate?

    public var timing: UITimingCurveProvider = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.1, y: 0.8), controlPoint2: CGPoint(x: 1, y: 1))

    private var navGesture = SwipeNavigationGestureRecognizer()

    private lazy var animator: UIViewPropertyAnimator = { UIViewPropertyAnimator(duration: 0.3, timingParameters: self.timing) }()

    private(set) var currentView: UIView

    private var nextView: UIView?

    private var getNextView: () -> UIView?
    private var getPreviousView: () -> UIView?

    public var currentViewTransitionSpeed: CGFloat = 1.0

    public init(initialView: UIView = UIView(), getNextView: @escaping () -> UIView?, getPreviousView: @escaping () -> UIView?) {
        currentView = initialView
        self.getNextView = getNextView
        self.getPreviousView = getPreviousView
        super.init(frame: .zero)
        currentViewCenter = setupView(initialView, offset: 0)
        addGestureRecognizer(navGesture)
        navGesture.addTarget(self, action: #selector(gestured(_:)))

        clipsToBounds = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    public func programmaticNext() {
        guard canTransition else {
            return
        }
        hasBegunProgrammatic(.left)
        goNext()
    }

    public func programmaticBack() {
        guard canTransition else {
            return
        }
        hasBegunProgrammatic(.right)
        goBack()
    }

    fileprivate func goNext() {
        guard !animating, let nextView = getNextView() else {
            return
        }
        animating = true
        self.nextView?.removeFromSuperview()
        self.nextView = nextView
        prepareForAnimation(nextView, offset: width)

        animateNext(currentView: currentView, nextView: nextView, direction: .left)
    }

    fileprivate func goBack() {
        guard !animating, let previousView = getPreviousView() else {
            return
        }
        animating = true
        self.nextView = previousView

        prepareForAnimation(previousView, offset: -(width * (currentViewTransitionSpeed)))
        sendSubviewToBack(previousView)

        animateNext(currentView: currentView, nextView: previousView, direction: .right)
    }

    private func setupView(_ view: UIView, offset: CGFloat) -> NSLayoutConstraint? {
        let constraints = constrainSubview(view)
            .centerX(equalTo: centerXAnchor, constant: offset)
            .width(to: widthAnchor)
            .height(to: heightAnchor)
        return constraints.layoutConstraintWithIdentifier(.centerX)
    }

    public func hasBegunGesture(_ direction: HorizontalDirection) {
        delegate?.viewContainer(self, hasChangedState: .begin(direction))
    }

    public func hasBegunProgrammatic(_ direction: HorizontalDirection) {
        delegate?.viewContainer(self, hasChangedState: .begin(direction))
        delegate?.viewContainer(self, hasChangedState: .end)
    }

    @objc func gestured(_ recognizer: SwipeNavigationGestureRecognizer) {
        guard canTransition else {
            return
        }
        let direction = recognizer.direction
        let progress = recognizer.fractionalComplete
        switch recognizer.state {
        case .began:
            hasBegunGesture(direction)
            start(using: direction)
        case .changed:
            self.progress(using: progress)
            delegate?.viewContainer(self, hasChangedState: .changed(progress))
        case .ended:
            end()
            delegate?.viewContainer(self, hasChangedState: .end)
        case .cancelled, .failed:
            failedGesture()
            delegate?.viewContainer(self, hasChangedState: .failed)
        default: ()
        }
    }

    fileprivate func start(using direction: HorizontalDirection) {
        switch direction {
        case .unknown:
            failedGesture()
            return
        case .left: goNext()
        case .right: goBack()
        }
        animator.pauseAnimation()
        self.isUserInteractionEnabled = false
        nextView?.isUserInteractionEnabled = false
    }

    fileprivate func progress(using fractionalComplete: CGFloat) {
        animator.fractionComplete = fractionalComplete
    }

    fileprivate func end() {
        animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    }

    fileprivate func failedGesture() {
        animating = false
        animator.stopAnimation(true)
        cleanUpAfterCancel()
        self.isUserInteractionEnabled = true
    }

    private func prepareForAnimation(_ nextView: UIView, offset: CGFloat) {
        nextViewCenter = setupView(nextView, offset: offset)
        layoutIfNeeded()
    }

    private func animateNext(currentView: UIView, nextView: UIView, direction: HorizontalDirection) {
        let transitionSpeed = currentViewTransitionSpeed
        let offset = width * CGFloat(direction.intWhereLeftIsPositive ?? 0)
        let currentViewSpeed = direction.isLeft ? transitionSpeed : 1
        let nextViewSpeed    = direction.isLeft ? 1 : transitionSpeed
        animator.addAnimations { [weak self, weak nextView] in
            if let dropShadow = self?.dropShadow {
                nextView?.dropShadow(dropShadow)
            }
            self?.currentViewCenter?.constant -= offset * currentViewSpeed
            self?.nextViewCenter?.constant -= offset * nextViewSpeed
            self?.layoutIfNeeded()
        }

        animator.addCompletion { [weak self] position in
            if case .end = position {
                self?.cleanUpNavigation()
            }
        }

        animator.startAnimation()
    }

    fileprivate func cleanUpNavigation() {
        animating = false
        guard let nextView = nextView else {
            return
        }
        currentView.removeFromSuperview()
        currentView = nextView
        currentViewCenter = nextViewCenter
        finalCleanup()
    }

    fileprivate func cleanUpAfterCancel() {
        animating = false
        nextView?.removeFromSuperview()
        currentViewCenter?.constant = 0
        layoutIfNeeded()
        finalCleanup()
    }

    fileprivate func finalCleanup() {
        isUserInteractionEnabled = true
        nextView = nil
        nextViewCenter = nil
    }
}

public class LinkableViewContainer: ViewContainer {

    private var driver = false

    public func drive(_ state: State) {
        guard !driver else {
            return
        }
        switch state {
        case .begin(let direction):
            start(using: direction)
        case .changed(let progress): self.progress(using: progress)
        case .end: end()
        case .failed: failedGesture()
        }
    }

    public override func hasBegunGesture(_ direction: HorizontalDirection) {
        driver = true
        super.hasBegunGesture(direction)
    }

    public override func hasBegunProgrammatic(_ direction: HorizontalDirection) {
        driver = true
        super.hasBegunProgrammatic(direction)
    }

    fileprivate override func cleanUpNavigation() {
        super.cleanUpNavigation()
        driver = false
    }

    fileprivate override func cleanUpAfterCancel() {
        super.cleanUpAfterCancel()
        driver = false
    }

}
