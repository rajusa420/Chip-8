//
//  UIViewController+Child.swift
//  Chip-8
//
//  Created by Raj Sathianarayanan on 12/27/22.
//

import UIKit

extension UIViewController {
    func addChildViewController(viewController: UIViewController, intoViewContainer viewContainer: UIView) {
        guard let view = viewController.view else {
            fatalError("Trying to add child view controller with a view!")
        }

        addChild(viewController)

        viewContainer.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: viewContainer.topAnchor),
            view.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor)
        ])

        viewController.didMove(toParent: self)
    }

    func removeChildViewController(viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view?.removeFromSuperview()
        viewController.removeFromParent()
    }
}
