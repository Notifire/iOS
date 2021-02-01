//
//  TabBarViewController.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class CircleView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
}

class TabBarViewController: VMViewController<TabBarViewModel>, AppRevealing {

    // MARK: - Properties

    // MARK: Delegate
    weak var delegate: TabBarViewControllerDelegate?

    // MARK: Views
    /// UIView for the child view controllers (selected tabs)
    let containerView = UIView()
    let buttonsContainerView = UIView()

    lazy var tabBarStackView: TabBarStackView = {
        let stackView = TabBarStackView(tabs: viewModel.tabs)
        stackView.onButtonTapAction = handleTabBarButtonPress
        return stackView
    }()

    var notificationsAlertView: UIView?
    var notificationsButton: UIButton?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        updateTabBarStackViewSize()
        notificationsButton = tabBarStackView.button(for: .notifications)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareViewModel()
    }

    // MARK: - Initialization
    required init(viewModel: TabBarViewModel) {
        super.init(viewModel: viewModel)
        // Update appearance and notify delegate when the tab changes
        viewModel.onTabChange = { [unowned self] tab in
            self.updateAppearance(with: tab)
            self.delegate?.didSelect(tab: tab)
        }

        // Notify delegate if the tab gets reselected
        viewModel.onTabReselect = { [unowned self] tab in
            self.delegate?.didReselect(tab: tab)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Private
    private func prepareViewModel() {
        viewModel.onNotificationsAlertStateChange = { [weak self] state in
            switch state {
            case .hidden:
                self?.removeNotificationsAlertViewIfNeeded()
                UIApplication.shared.applicationIconBadgeNumber = 0
            case .shown(let numberOfUnreadNotifications):
                self?.addNotificationsAlertViewIfNeeded()
                UIApplication.shared.applicationIconBadgeNumber = numberOfUnreadNotifications
            }
        }
        viewModel.setupResultsTokenIfNeeded()
    }

    private func addNotificationsAlertViewIfNeeded() {
        guard notificationsAlertView == nil, let notificationsButton = notificationsButton, let imageView = notificationsButton.imageView else { return }
        let circleView = CircleView()
        circleView.backgroundColor = .primary
        buttonsContainerView.add(subview: circleView)
        circleView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8).isActive = true
        circleView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8).isActive = true
        circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor).isActive = true
        circleView.widthAnchor.constraint(equalToConstant: Size.Image.unreadNotificationAlert).isActive = true
        buttonsContainerView.layoutIfNeeded()
        circleView.transform = circleView.transform.scaledBy(x: 0.5, y: 0.5)
        let animator = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 0.25) {
            circleView.transform = .identity
            self.buttonsContainerView.layoutIfNeeded()
        }
        animator.startAnimation()
        notificationsAlertView = circleView
    }

    private func removeNotificationsAlertViewIfNeeded() {
        guard let activeAlertView = notificationsAlertView else { return }
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: [.calculationModeLinear, .beginFromCurrentState], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.55, animations: {
                activeAlertView.transform = activeAlertView.transform.scaledBy(x: 1.2, y: 1.2)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.55, relativeDuration: 0.45, animations: {
                activeAlertView.transform = activeAlertView.transform.scaledBy(x: 0.01, y: 0.01)
            })
        }, completion: ({ [weak self] _ in
            activeAlertView.removeFromSuperview()
            self?.notificationsAlertView = nil
        }))
    }

    // MARK: Layout
    private func layout() {
        // child vc (tab) container
        view.add(subview: containerView)
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

        // collection view container
        buttonsContainerView.backgroundColor = .compatibleSystemBackground
        view.add(subview: buttonsContainerView)
        buttonsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        buttonsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        buttonsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        buttonsContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Size.Tab.height).isActive = true

        // collection view
        view.add(subview: tabBarStackView)
        tabBarStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tabBarStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tabBarStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tabBarStackView.topAnchor.constraint(equalTo: buttonsContainerView.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: buttonsContainerView.topAnchor).isActive = true

        // separator
        let separatorView = SeparatorView()
        view.addSubview(separatorView)
        separatorView.leadingAnchor.constraint(equalTo: buttonsContainerView.leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: buttonsContainerView.trailingAnchor).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: buttonsContainerView.topAnchor).isActive = true
    }

    // MARK: Appearance
    private func updateAppearance(with tab: Tab) {
        guard let tabIndex = viewModel.tabs.firstIndex(of: tab) else { return }
        tabBarStackView.updateAppearance(selectedIndex: tabIndex)
    }

    private func updateTabBarStackViewSize() {
        let imageWidth = Size.Image.tabBarIcon
        let width = UIScreen.main.bounds.width
        let numberOfTabs = CGFloat(viewModel.tabs.count)
        let horizontalInset = ((width / numberOfTabs) - imageWidth) / 2
        let insets = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        tabBarStackView.arrangedSubviews.forEach { ($0 as? UIButton)?.imageEdgeInsets = insets }
    }

    // MARK: Touch Events
    private func handleTabBarButtonPress(tag: Int) {
        let selectedTab = viewModel.tabs[tag]
        viewModel.updateTab(to: selectedTab)
    }
}
