//
//  TimeframeSelectionViewController.swift
//  Notifire
//
//  Created by David Bielik on 13/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import UIKit

enum TimeframeSelectionSection: Int, SectionAndRowRepresentable {
    case interval
    case specificDates
}

enum TimeframeSelectionSectionRow: Int, SectionAndRowRepresentable {
    // Interval
    case anytime
    case last24h
    case lastWeek
    case lastMonth
    case lastYear

    // Specific
    case fromDate
    case fromDateSelection
    case toDate
    case toDateSelection
}

class DatePickerTableViewCell: ReusableBaseTableViewCell, CellConfigurable {

    typealias DataType = Date

    /// Current date from time + date picker.
    var currentCombinedDate: Date {
        let time = timePicker.date
        var date = datePicker.date
        date = Calendar.current.startOfDay(for: date)

        let calendar = Calendar.current

        var timeInterval: TimeInterval = 0
        timeInterval += Double(calendar.component(.second, from: time))
        timeInterval += Double(calendar.component(.minute, from: time)) * 60
        timeInterval += Double(calendar.component(.hour, from: time)) * 3600

        date.addTimeInterval(timeInterval)
        return date
    }

    /// Called when the `currentCombinedDate` changes.
    /// Parameter is `currentCombinedDate`.
    var onCurrentCombinedDateChange: ((Date) -> Void)?

    // MARK: - Properties
    lazy var timeStaticLabel: UILabel = {
        let label = UILabel(style: .cellBodySemibold)
        label.text = "Time"
        return label
    }()

    lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.addTarget(self, action: #selector(didChangeTimePicker), for: .valueChanged)
        return picker
    }()

    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(didChangeDatePicker), for: .valueChanged)
        return picker
    }()

    override func setup() {
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
            timePicker.preferredDatePickerStyle = .inline
        }

        contentView.add(subview: timePicker)
        timePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        timePicker.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true

        contentView.add(subview: datePicker)
        datePicker.embedSides(in: contentView)
        datePicker.topAnchor.constraint(equalTo: timePicker.bottomAnchor).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        contentView.add(subview: timeStaticLabel)
        timeStaticLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        timeStaticLabel.centerYAnchor.constraint(equalTo: timePicker.centerYAnchor).isActive = true
    }

    func configure(data: Date) {
        datePicker.date = data
        timePicker.date = data
    }

    @objc private func didChangeTimePicker() {
        onCurrentCombinedDateChange?(currentCombinedDate)
    }

    @objc private func didChangeDatePicker() {
        onCurrentCombinedDateChange?(currentCombinedDate)
    }
}

class DateDisplayTableViewCell: ReusableBaseTableViewCell, CellConfigurable {

    typealias DataType = (text: String, date: Date, selectedDate: TimeframeSelectionViewModel.SelectedSpecificDate)

    lazy var dateLabel = UILabel(style: .notifirePositive)

    var selectedSpecifiedDate: TimeframeSelectionViewModel.SelectedSpecificDate = .from

    override func setup() {
        contentView.add(subview: dateLabel)

        dateLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

    func configure(data: DataType) {
        textLabel?.text = data.text
        dateLabel.text = data.date.string(with: .completeSpaced)
        selectedSpecifiedDate = data.selectedDate
    }
}

typealias DateDisplayCellConfiguration = CellConfiguration<DateDisplayTableViewCell, DefaultTappableCellAppearance>
typealias DefaultTappableCellConfiguration = CellConfiguration<UITableViewReusableCell, DefaultTappableCellAppearance>
typealias DatePickerCellConfiguration = CellConfiguration<DatePickerTableViewCell, DefaultCellAppearance>

class TimeframeSelectionViewModel: ViewModelRepresenting, StaticTableViewViewModel {

    // MARK: - Properties
    weak var filterViewModel: NotificationsFilterViewModel?

    /// The currently selected timeframe
    var arrivalTimeframe: NotificationArrivalTimeframe {
        get {
            return filterViewModel?.notificationsFilterData.arrivalTimeframe ?? .interval(.allTime)
        }
        set {
            filterViewModel?.notificationsFilterData.arrivalTimeframe = newValue
        }
    }
    /// Previously selected timeframe. Used to switch between the timeframes/
    var lastArrivalTimeframe: NotificationArrivalTimeframe

    enum SelectedSpecificDate: Equatable {
        case from, to
    }

    /// The currently selected date picker. `nil` if none are selected.
    /// Only one date picker can be selected at a time.
    var selectedSpecificDate: SelectedSpecificDate? = .from {
        didSet {
            guard selectedSpecificDate != oldValue else { return }
            updateSections()
        }
    }

    /// The last interval that the user has selected. Also used as the initial value.
    let defaultIntervalTimeframe: NotificationArrivalTimeframe.Interval = .allTime

    var currentSectionIndex: Int {
        didSet {
            guard oldValue != currentSectionIndex else { return }
            updateSections()
            // Notify listener
            onCurrentSectionIndexChange?()
        }
    }

    // MARK: Callback
    var onCurrentSectionIndexChange: (() -> Void)?
    var onShouldReloadFromDateCell: (() -> Void)?
    var onShouldReloadToDateCell: (() -> Void)?

    // MARK: - Initialization
    init(filterVM: NotificationsFilterViewModel) {
        filterViewModel = filterVM
        switch filterVM.notificationsFilterData.arrivalTimeframe {
        case .interval:
            currentSectionIndex = 0
            lastArrivalTimeframe = .specific(from: Date().addingTimeInterval(-3600), to: Date())
        case .specific:
            currentSectionIndex = 1
            lastArrivalTimeframe = .interval(defaultIntervalTimeframe)
        }
        updateSections()
    }

    // MARK: StaticTableViewModel
    typealias Section = TimeframeSelectionSection
    typealias SectionRow = TimeframeSelectionSectionRow

    public var sections: [Section] = []
    public var rowsAtSection: [Section: [SectionRow]] = [:]
    public var cellConfigurations: [SectionRow: CellConfiguring] = [:]

    func createSectionsAndRows() -> [(TimeframeSelectionSection, [TimeframeSelectionSectionRow])] {
        var newSectionsAndRows: [(TimeframeSelectionSection, [TimeframeSelectionSectionRow])] = []
        switch arrivalTimeframe {
        case .interval:
            newSectionsAndRows = [(.interval, [.anytime, .last24h, .lastWeek, .lastMonth, .lastYear])]
        case .specific:
            var newRows: [TimeframeSelectionSectionRow] = [.fromDate]
            if selectedSpecificDate == .from {
                newRows.append(.fromDateSelection)
            }
            newRows.append(.toDate)
            if selectedSpecificDate == .to {
                newRows.append(.toDateSelection)
            }
            newSectionsAndRows = [(.specificDates, newRows)]
        }
        return newSectionsAndRows
    }

    func cellConfiguration(at indexPath: IndexPath) -> CellConfiguring {
        switch row(at: indexPath) {
        case .anytime:
            return DefaultCellConfiguration(item: "Anytime")
        case .last24h:
            return DefaultCellConfiguration(item: "Last 24 hours")
        case .lastWeek:
            return DefaultCellConfiguration(item: "Last week")
        case .lastMonth:
            return DefaultCellConfiguration(item: "Last month")
        case .lastYear:
            return DefaultCellConfiguration(item: "Last year")
        case .fromDate:
            guard case .specific(let fromDate, _) = arrivalTimeframe else {
                return DefaultTappableCellConfiguration(item: "From")
            }
            return DateDisplayCellConfiguration(item: ("From", fromDate, .from))
        case .fromDateSelection:
            guard case .specific(let fromDate, _) = arrivalTimeframe else {
                return DatePickerCellConfiguration(item: Date())
            }
            return DatePickerCellConfiguration(item: fromDate)
        case .toDate:
            guard case .specific(_, let toDate) = arrivalTimeframe else {
                return DefaultTappableCellConfiguration(item: "To")
            }
            return DateDisplayCellConfiguration(item: ("To", toDate, .to))
        case .toDateSelection:
            guard case .specific(_, let toDate) = arrivalTimeframe else {
                return DatePickerCellConfiguration(item: Date())
            }
            return DatePickerCellConfiguration(item: toDate)
        }
    }

    func updateSegment(selectedIndex: Int) {
        // Avoid reselecting
        guard currentSectionIndex != selectedIndex else { return }
        // Update model
        let newTimeframe = lastArrivalTimeframe
        lastArrivalTimeframe = arrivalTimeframe
        arrivalTimeframe = newTimeframe
        // Update section index which notifies the view
        currentSectionIndex = selectedIndex
    }

    func updateSpecificDate(to newDate: Date) {
        guard case .specific(let from, let to) = arrivalTimeframe else { return }
        if selectedSpecificDate == .from {
            arrivalTimeframe = .specific(from: newDate, to: to)
            onShouldReloadFromDateCell?()
        } else if selectedSpecificDate == .to {
            arrivalTimeframe = .specific(from: from, to: newDate)
            onShouldReloadToDateCell?()
        }
    }
}

class TimeframeSelectionDataSource: GenericTableViewDataSource<TimeframeSelectionViewModel> {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let section = tableViewViewModel.section(at: indexPath.section)
        let row = tableViewViewModel.row(at: indexPath)
        switch section {
        case .interval:
            // Add checkmark to interval cells
            guard case .interval(let interval) = tableViewViewModel.arrivalTimeframe else { return cell }
            let addCheckmark: Bool =
                (row == .anytime && interval == .allTime) ||
                (row == .last24h && interval == .last24h) ||
                (row == .lastWeek && interval == .lastWeek) ||
                (row == .lastMonth && interval == .lastMonth) ||
                (row == .lastYear && interval == .lastYear)
            cell.accessoryType = addCheckmark ? .checkmark : .none
        case .specificDates:
            // Add date picker closure
            if let datePickerCell = cell as? DatePickerTableViewCell {
                datePickerCell.onCurrentCombinedDateChange = { [weak self] updatedDate in
                    self?.tableViewViewModel.updateSpecificDate(to: updatedDate)
                }
            }
        }
        return cell
    }
}

class TimeframeSelectionViewController: VMViewController<TimeframeSelectionViewModel> {

    // MARK: - Properties
    private lazy var dataSource = TimeframeSelectionDataSource(tableViewViewModel: viewModel)

    // MARK: UI
    lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        // Insert the sections
        for (index, section) in NotificationArrivalTimeframe.allCases.enumerated() {
            segmentedControl.insertSegment(withTitle: section.sectionTitle, at: index, animated: false)
        }
        if #available(iOS 13.0, *) {} else {
            // Tint color defaults to blue on iOS 12, so set it to black
            segmentedControl.tintColor = .black
        }
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: Size.Font.action)], for: .normal)
        segmentedControl.addTarget(self, action: #selector(didChangeSegmentedControlValue), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = viewModel.currentSectionIndex
        return segmentedControl
    }()

    lazy var tableView = UITableView.initGrouped(
        registerCells: [
            UITableViewReusableCell.self,
            DatePickerTableViewCell.self,
            DateDisplayTableViewCell.self
        ],
        dataSource: dataSource,
        delegate: self
    )

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // View
        view.backgroundColor = .compatibleSystemGroupedBackground
        navigationItem.prompt = "Notifications timeframe selection"
        navigationItem.titleView = segmentedControl

        // ViewModel
        setupViewModel()

        // Layout
        layout()
        updateAppearance()
    }

    // MARK: - Private
    private func setupViewModel() {
        viewModel.onCurrentSectionIndexChange = { [weak self] in
            self?.updateAppearance()
        }

        viewModel.onShouldReloadFromDateCell = { [weak self] in
            self?.reloadDateDisplayRow(.from)
        }

        viewModel.onShouldReloadToDateCell = { [weak self] in
            self?.reloadDateDisplayRow(.to)
        }
    }

    private func layout() {
        view.add(subview: tableView)
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func updateAppearance(animated: Bool = true) {
        let animation = animated ? UITableView.RowAnimation.fade : .none
        tableView.reloadSections(IndexSet(viewModel.sections.indices), with: animation)
    }

    private func reloadDateDisplayRow(_ selectedDate: TimeframeSelectionViewModel.SelectedSpecificDate) {
        guard
            let cell = tableView.visibleCells.first(where: { ($0 as? DateDisplayTableViewCell)?.selectedSpecifiedDate == .some(selectedDate) }),
            let cellIndexPath = tableView.indexPath(for: cell)
        else { return }
        tableView.reloadRows(at: [cellIndexPath], with: .none)
    }

    // MARK: Event Handling
    @objc private func didChangeSegmentedControlValue(_ segmentedControl: UISegmentedControl) {
        viewModel.updateSegment(selectedIndex: segmentedControl.selectedSegmentIndex)
    }
}

extension TimeframeSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = viewModel.row(at: indexPath)
        if row == .fromDateSelection || row == .toDateSelection {
            return UITableView.automaticDimension
        } else {
            return tableView.rowHeight
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = viewModel.section(at: indexPath.section)
        let selectedRow = viewModel.row(at: indexPath)
        switch section {
        case .interval:
            let newInterval: NotificationArrivalTimeframe.Interval
            switch selectedRow {
            case .anytime: newInterval = .allTime
            case .last24h: newInterval = .last24h
            case .lastWeek: newInterval = .lastWeek
            case .lastMonth: newInterval = .lastMonth
            case .lastYear: newInterval = .lastYear
            default: return
            }
            viewModel.arrivalTimeframe = .interval(newInterval)
            updateAppearance(animated: false)
        case .specificDates:
            // New selected date picker
            let newSelectedSpecificDate: ViewModel.SelectedSpecificDate
            if selectedRow == .fromDate {
                newSelectedSpecificDate = .from
            } else if selectedRow == .toDate {
                newSelectedSpecificDate = .to
            } else {
                return
            }

            // Check currently selected one
            if let currentlySelectedSpecificDate = viewModel.selectedSpecificDate {
                if currentlySelectedSpecificDate == newSelectedSpecificDate {
                    // User tapped the same one he previously selected
                    // Close it
                    viewModel.selectedSpecificDate = nil
                } else {
                    // User tapped the other date picker
                    viewModel.selectedSpecificDate = newSelectedSpecificDate
                }
            } else {
                // No date picker is selected
                // Select the one the user tapped
                viewModel.selectedSpecificDate = newSelectedSpecificDate
            }
            tableView.deselectRow(at: indexPath, animated: true)
            updateAppearance()
        }
    }
}
