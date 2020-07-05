//  Created by Axel Ancona Esselmann on 7/5/20.
//  Copyright © 2020 Axel Ancona Esselmann. All rights reserved.
//

import UIKit

public class SwipeNavigationGestureRecognizer: UIGestureRecognizer {

    public var startingThreshold: CGFloat = 5
    public var registerNavigationThreshold: CGFloat = 80

    private(set) var direction: HorizontalDirection = .unknown
    private(set) var horizontalDistance: CGFloat = .zero

    private var startLocation: CGPoint = .zero

    public var fractionalComplete: CGFloat {
        guard let view = view else {
            return 0
        }
        let directionalMultiplier = CGFloat(direction.intWhereRightIsPositive ?? 0)
        return horizontalDistance / view.width * directionalMultiplier
    }

    public override func reset() {
        direction = .unknown
        horizontalDistance = .zero
        startLocation = .zero
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = touches.first else {
            return
        }
        startLocation = touch.location(in: view)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = touches.first else {
            return
        }

        let currentLocation = touch.location(in: view)

        self.horizontalDistance = currentLocation.x - startLocation.x

        if direction == .unknown {
            direction = horizontalDistance < 0 ? .left : .right
        }
        guard abs(horizontalDistance) >= startingThreshold else {
            return
        }
        state = .changed
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        switch state {
        case .began, .possible:
            state = .cancelled
        case .changed:
            if abs(horizontalDistance) >= registerNavigationThreshold {
                state = .recognized
            } else {
                state = .cancelled
            }
        case .cancelled, .ended, .failed: ()
        @unknown default: ()
        }
        reset()
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
        reset()
    }
}
