//  Created by Axel Ancona Esselmann on 7/5/20.
//  Copyright © 2020 Axel Ancona Esselmann. All rights reserved.
//

import UIKit

public extension UIView {
    var width: CGFloat {
        self.frame.size.width
    }

    func dropShadow(color: UIColor = .black, opacity: Float = 1, offset: CGSize = .zero, radius: CGFloat = 10) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
    }

    func dropShadow(_ dropShadow: DropShadow) {
        self.dropShadow(color: dropShadow.color, opacity: dropShadow.opacity, offset: dropShadow.offset, radius: dropShadow.radius)
    }
}
