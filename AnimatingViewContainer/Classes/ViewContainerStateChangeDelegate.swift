//  Created by Axel Ancona Esselmann on 7/5/20.
//  Copyright © 2020 Axel Ancona Esselmann. All rights reserved.
//

import Foundation

public protocol ViewContainerStateChangeDelegate: class {
    func viewContainer(_ viewContainer: ViewContainer, hasChangedState state: ViewContainer.State)
}
