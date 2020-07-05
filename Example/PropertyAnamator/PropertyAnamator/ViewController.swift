//  Created by Axel Ancona Esselmann on 7/3/20.
//  Copyright © 2020 Axel Ancona Esselmann. All rights reserved.
//

import UIKit
import constrain
import AnimatingViewContainer

class ViewController: UIViewController {

    var container: ViewContainer?
    var container2: ViewContainer?

    var nextButton = UIButton()
    var prevButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        let container = LinkableViewContainer(
            initialView: ColoredView(),
            getNextView: { ColoredView() },
            getPreviousView: { ColoredView() }
        )

        self.container = container
        container.delegate = self
        container.currentViewTransitionSpeed = 0.5

        constrainSubview(container)
            .top()
            .fillWidth()
            .height(300)

        let container2 = LinkableViewContainer(
            initialView: ColoredView(),
            getNextView: { ColoredView() },
            getPreviousView: { ColoredView() }
        )

        self.container2 = container2
        container2.delegate = self
        container2.dropShadow = nil
//        container2.currentViewTransitionSpeed = -0.5
        container2.canTransition = false

        constrainSubview(container2)
            .top(to: container.bottomAnchor, constant: 16)
            .fillWidth()
            .height(300)

        constrainSubview(nextButton).trailing().centerY().size(50)
        constrainSubview(prevButton).leading().centerY().size(50)

        nextButton.backgroundColor = .orange
        nextButton.addTarget(self, action: #selector(nextButtonClicked(_:)), for: .touchUpInside)

        prevButton.backgroundColor = .yellow
        prevButton.addTarget(self, action: #selector(previousButtonClicked(_:)), for: .touchUpInside)
    }

    @objc func nextButtonClicked(_ sender: UIButton) {
        container?.programmaticNext()
    }

    @objc func previousButtonClicked(_ sender: UIButton) {
        container?.programmaticBack()
    }

}

extension ViewController: ViewContainerStateChangeDelegate {
    func viewContainer(_ viewContainer: ViewContainer, hasChangedState state: ViewContainer.State) {
        let containers: [ViewContainer] = [container!, container2!]//.filter( { $0 != viewContainer } )
        for container in containers {
            if let drivable = container as? LinkableViewContainer {
                drivable.drive(state)
            }
        }
    }
}



extension UIColor {
    static var random: UIColor {
        let red = CGFloat(Int.random(in: 0 ..< 256)) / 255
        let green = CGFloat(Int.random(in: 0 ..< 256)) / 255
        let blue = CGFloat(Int.random(in: 0 ..< 256)) / 255
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}

class ColoredView: UIView {

    init(_ color: UIColor = .random) {
        print("View Created")
        super.init(frame: .zero)
        backgroundColor = color
        let label = UILabel()
        constrainSubview(label).fill(constant: 16)
        label.numberOfLines = 0
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam scelerisque quis dui ac semper. Donec blandit auctor nulla id pharetra. Cras scelerisque vehicula ex ac cursus. Proin consectetur venenatis purus, vel feugiat purus congue sed. Quisque ac mauris sollicitudin, tempor lacus at, pulvinar est. Maecenas a mauris sagittis ipsum efficitur congue eget eget nulla. Integer vel felis quis erat tincidunt lobortis a non massa. In eu magna tincidunt, vulputate magna vel, imperdiet metus. Pellentesque a dapibus mi. Ut tempus mauris eu libero auctor feugiat. Suspendisse et suscipit enim."
    }

    deinit {
        print("View destroyed")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}
