//
//  TabBarViewController.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol TabBarViewControllerDelegate: class {
    func didSelect(tab: Tab)
    func didReselect(tab: Tab)
}

class TabBarViewController: UIViewController, AppRevealing {
    
    // MARK: - Properties
    // MARK: ViewModel
    let viewModel: TabBarViewModel
    
    // MARK: Delegate
    weak var delegate: TabBarViewControllerDelegate?
    
    // MARK: Views
    let containerView = UIView()
    
    lazy var tabBarStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .center
        for (i, tab) in viewModel.tabs.enumerated() {
            let button = UIButton()
            button.tag = i
            button.tintColor = .tabBarButtonDeselectedColor
            button.setImage(tab.image.withRenderingMode(.alwaysTemplate), for: .normal)
            let selectedImg = tab.highlightedImage.withRenderingMode(.alwaysTemplate)
            button.setImage(selectedImg, for: .selected)
            button.setImage(selectedImg, for: .highlighted)
            button.setImage(selectedImg, for: [.selected, .highlighted])
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(didPressTabBarButton(button:)), for: .touchUpInside)
            view.addArrangedSubview(button)
            if tab == .notifications {
                notificationsButton = button
            }
        }
        return view
    }()
    
    var notificationsAlertView: UIView?
    var notificationsButton: UIButton?
    
    // MARK: - Initialization
    init(viewModel: TabBarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.onTabChange = { [unowned self] tab in
            self.updateAppearance(with: tab)
            self.delegate?.didSelect(tab: tab)
        }
        viewModel.onTabReselect = { [unowned self] tab in
            self.delegate?.didReselect(tab: tab)
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        prepareViewModel()
        updateTabBarStackViewSize()
    }
    
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
        let circleView = UIView()
        circleView.backgroundColor = .notifireMainColor
        notificationsButton.add(subview: circleView)
        circleView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8).isActive = true
        circleView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8).isActive = true
        circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor).isActive = true
        circleView.widthAnchor.constraint(equalToConstant: Size.Image.unreadNotificationAlert).isActive = true
        notificationsButton.layoutIfNeeded()
        circleView.toCircle()
        circleView.transform = circleView.transform.scaledBy(x: 0.5, y: 0.5)
        let animator = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 0.25) {
            circleView.transform = .identity
            notificationsButton.layoutIfNeeded()
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
        }) { [weak self] _ in
            activeAlertView.removeFromSuperview()
            self?.notificationsAlertView = nil
        }
    }
    
    // MARK: Layout
    private func layout() {
        // child vc (tab) container
        view.add(subview: containerView)
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

        // collection view container
        let buttonsContainerView = UIView()
        buttonsContainerView.backgroundColor = .backgroundAccentColor
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
        let hairlineView = HairlineView()
        view.addSubview(hairlineView)
        hairlineView.leadingAnchor.constraint(equalTo: buttonsContainerView.leadingAnchor).isActive = true
        hairlineView.trailingAnchor.constraint(equalTo: buttonsContainerView.trailingAnchor).isActive = true
        hairlineView.bottomAnchor.constraint(equalTo: buttonsContainerView.topAnchor).isActive = true
    }
    
    // MARK: Appearance
    private func updateAppearance(with tab: Tab) {
        guard let tabIndex = viewModel.tabs.firstIndex(of: tab) else { return }
        if let previouslySelected = tabBarStackView.arrangedSubviews.first(where: { ($0 as? UIButton)?.isSelected ?? false }) as? UIButton {
            previouslySelected.tintColor = UIColor.tabBarButtonDeselectedColor
            previouslySelected.isSelected = false
        }
        if let selected = tabBarStackView.arrangedSubviews.first(where: { $0.tag == tabIndex }) as? UIButton {
            selected.tintColor = .tabBarButtonSelectedColor
            selected.isSelected = true
        }
    }
    
    private func updateTabBarStackViewSize() {
        let imageWidth = Size.Image.tabBarIcon
        let width = UIScreen.main.bounds.width
        let numberOfTabs = CGFloat(viewModel.tabs.count)
        let horizontalInset = ((width / numberOfTabs) - imageWidth) / 2
        let insets = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        tabBarStackView.arrangedSubviews.forEach { ($0 as? UIButton)?.imageEdgeInsets = insets }
    }
    
    // MARK: Events
    @objc private func didPressTabBarButton(button: UIButton) {
        let selectedTab = viewModel.tabs[button.tag]
        viewModel.updateTab(to: selectedTab)
    }
}
