//  Created by Axel Ancona Esselmann on 7/5/20.
//  Copyright © 2020 Axel Ancona Esselmann. All rights reserved.
//

import Foundation

public enum HorizontalDirection {
    case unknown
    case left
    case right

    public var isLeft: Bool {
        switch self {
        case .unknown: return false
        case .left: return true
        case .right: return false
        }
    }
    public var isRight: Bool {
        switch self {
        case .unknown: return false
        case .left: return false
        case .right: return true
        }
    }
}


public extension HorizontalDirection {
    var intWhereLeftIsPositive: Int? {
        switch self {
        case .unknown: return nil
        case .left: return 1
        case .right: return -1
        }
    }

    var intWhereRightIsPositive: Int? {
        switch self {
        case .unknown: return nil
        case .left: return -1
        case .right: return 1
        }
    }
}
