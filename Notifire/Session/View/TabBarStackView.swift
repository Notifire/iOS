//
//  TabBarStackView.swift
//  Notifire
//
//  Created by David Bielik on 07/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class TabBarStackView: UIStackView {

    // MARK: - Properties
    var buttons: [UIButton] = []
    lazy var tabBarGestureHandler = TabBarGestureHandler(numberOfTabs: tabs.count, view: self)
    // MARK: Private
    private let tabs: Tabs
    private let buttonSelectedColor = UIColor.primary
    private let buttonDeselectedColor = UIColor.tabBarButtonDeselected
    // MARK: Actions
    public var onButtonTapAction: ((Int) -> Void)? {
        didSet {
            tabBarGestureHandler.onTabGestureCompleted = onButtonTapAction
        }
    }

    // MARK: - Initialization
    init(tabs: Tabs) {
        self.tabs = tabs
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        distribution = .fillEqually
        alignment = .center

        // Setup
        tabBarGestureHandler.onTabGestureStarting = startForwardAnimationFor
        tabBarGestureHandler.onTabGestureEnding = startBackwardAnimationFor(tabIndex:useSpring:)
        setupSubviews()
        // Add gesture recognizers
        addGestureRecognizers()
    }

    required init(coder: NSCoder) {
        tabs = []
        super.init(coder: coder)
    }

    // MARK: - Private
    private func setupSubviews() {
        // swiftlint:disable identifier_name
        for (i, tab) in tabs.enumerated() {
        // swiftlint:enable identifier_name
            // Create a button for each Tab
            let button = UIButton()
            button.tag = i
            button.tintColor = buttonDeselectedColor
            // Set button icon depending on the state
            let deselectedImg = tab.image.withRenderingMode(.alwaysTemplate)
            let selectedImg = tab.highlightedImage.withRenderingMode(.alwaysTemplate)
            button.setImage(deselectedImg, for: .normal)
            button.setImage(deselectedImg, for: .highlighted)
            button.setImage(selectedImg, for: .selected)
            // If the button is both, selected && highlighted, show selected image.
            button.setImage(selectedImg, for: [.selected, .highlighted])
            button.imageView?.contentMode = .scaleAspectFit
            button.imageView?.isUserInteractionEnabled = false
            // Add it to our stack of views
            addArrangedSubview(button)
            // Set the imageView height
//            button.imageView?.translatesAutoresizingMaskIntoConstraints = false
//            button.imageView?.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
//            button.imageView?.heightAnchor.constraint(equalToConstant: Size.Image.tabBarIcon).isActive = true
            // Add the button to our button array
            buttons.append(button)
        }
    }

    /// Adds gesture recognizers for handling the tap animations properly
    private func addGestureRecognizers() {
        for button in buttons {
            let shortPressGestureRecognizer = TabBarPressGestureRecognizer(target: tabBarGestureHandler, action: #selector(tabBarGestureHandler.pressGestureHandler), pressType: .short, button: button)
            let longPressGestureRecognizer = TabBarPressGestureRecognizer(target: tabBarGestureHandler, action: #selector(tabBarGestureHandler.pressGestureHandler), pressType: .long, button: button)
            button.addGestureRecognizer(shortPressGestureRecognizer)
            button.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    private func startForwardAnimationFor(tabIndex: Int) {
        let button = buttons[tabIndex]
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState], animations: {
            button.transform = button.transform.scaledBy(x: 0.75, y: 0.75)
        }, completion: nil)
    }

    private func startBackwardAnimationFor(tabIndex: Int, useSpring: Bool = true) {
        let button = buttons[tabIndex]
        let animation: (() -> Void) = {
            button.transform = .identity
        }
        guard useSpring else {
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseIn, .beginFromCurrentState, .allowUserInteraction], animations: animation, completion: nil)
            return
        }
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [.allowUserInteraction, .beginFromCurrentState], animations: animation, completion: nil)
    }

    // MARK: - Public
    /// Update appearance of buttons based on the `button.isSelected` property.
    public func updateAppearance(selectedIndex: Int) {
        // Deselect previously selected tab
        for button in buttons where button.isSelected {
            button.tintColor = buttonDeselectedColor
            button.isSelected = false
        }
        // Select new tab
        if let selected = buttons.first(where: { $0.tag == selectedIndex }) {
            selected.tintColor = buttonSelectedColor
            selected.isSelected = true
        }
    }

}
