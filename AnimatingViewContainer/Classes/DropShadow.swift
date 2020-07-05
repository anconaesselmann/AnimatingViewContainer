//  Created by Axel Ancona Esselmann on 7/5/20.
//  Copyright © 2020 Axel Ancona Esselmann. All rights reserved.
//

import UIKit

public struct DropShadow {
    public let color: UIColor
    public let opacity: Float
    public let offset: CGSize
    public let radius: CGFloat

    public init(_ color: UIColor = .black, opacity: Float = 1, offset: CGSize = .zero, radius: CGFloat = 10) {
        self.color = color
        self.opacity = opacity
        self.offset = offset
        self.radius = radius
    }
}
