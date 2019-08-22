//
//  SettingViewController.swift
//  Gi-ukForMoments
//
//  Created by goya on 20/08/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit
import CoreData

@objc protocol FilterSelectorDataSource {
    func filterSelector_Buttons(_ filterSelector: FilterSelector) -> [UIButton_WithIdentifire]
}

@objc protocol FilterSelectorDelegate {
    @objc func filterSelector_didSelecteItem(_ filterSelector: FilterSelector, selected: UIButton_WithIdentifire)
}

class FilterSelector: UIView {
    
    weak var dataSource: FilterSelectorDataSource?
    
    private var isLoaded: Bool = false
    
    private var buttons: [UIButton_WithIdentifire] {
        return dataSource?.filterSelector_Buttons(self) ?? []
    }
    
    private var numberOfItems: Int {
        return buttons.count
    }
    
    private var grid: [CGRect] {
        return (try? ButtonGridCalculator.requestButtonFrames(inFrame: bounds, numberOfButtons: numberOfItems, buttonType: .square, alignmentStyle: .centered, minSpacing: 5, marginInset: (5,5,10,10))) ?? []
    }
    
    private func layoutButtons() {
        if numberOfItems != 0 {
            for index in buttons.indices {
                let button = buttons[index]
                if !isLoaded {
                    addSubview(button)
                }
                button.setNewFrame(grid[index])
            }
            isLoaded = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutButtons()
    }
    
    func reloadData() {
        subviews.forEach { $0.removeFromSuperview() }
        isLoaded = false
        layoutButtons()
    }
}

class UIView_WithIdentifire: UIView {
    var identifire: String = ""
    
    convenience init(identifire: String) {
        self.init()
        self.identifire = identifire
    }
}

class AlphaButton: UIButton_WithIdentifire {
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                UIView.animate(withDuration: 0.25, delay: 0, options: [UIView.AnimationOptions.beginFromCurrentState], animations: {
                    self.alpha = 1
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.25, delay: 0, options: [UIView.AnimationOptions.beginFromCurrentState], animations: {
                    self.alpha = 0.5
                }, completion: nil)
            }
        }
    }
}

class SettingViewController: Giuk_OpenFromFrame_ViewController, FilterSelectorDataSource
{
    weak var filterSelectorContainer: UIView_WithIdentifire!
    weak var passcodeContainer: UIView_WithIdentifire!
    
    weak var filterSelector: FilterSelector!
    weak var giukCounterLabel: UILabel!
    weak var albumCounterLabel: UILabel!
    weak var passCodeButton: ActiveControllButton!
    weak var filterSelectButton: ActiveControllButton!
    
    var allContainers : [UIView_WithIdentifire] {
        return [filterSelectorContainer, passcodeContainer]
    }
    
    var numberOfSections: Int = 9
    
    var container: NSPersistentContainer = AppDelegate.persistentContainer
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    private var setting: PrimarySettings? {
        didSet {
            currentFilterName = self.setting?.filterName
        }
    }
    
    private var currentSetting: PrimarySettings!
    
    private var currentFilterName: String?
    
    private var filters: [ImageFilterModule.CIFilterName] = [.None, .CIPhotoEffectTonal, .CISepiaTone, .CIPhotoEffectFade,  .CIPhotoEffectChrome]
    
    private var filterNames: [String] {
        let names = filters.map{$0.rawValue}
        return names
    }
    
    func filterSelector_Buttons(_ filterSelector: FilterSelector) -> [UIButton_WithIdentifire] {
        return filterButtons
    }
    
    var filterModule = ImageFilterModule()
    
    lazy var filterButtons:  [AlphaButton] = {
        var buttons = [AlphaButton]()
        for filterName in filterNames {
            let button = AlphaButton()
            button.identifire = filterName
            let image = UIImage(named: "Sample")
            let filteredImage = filterModule.performFilter(filterName, image: image!)
            button.setImage(filteredImage, for: .normal)
            button.imageView?.contentMode = .scaleAspectFill
            button.addTarget(self, action: #selector(filterButtonAction(_:)), for: .touchUpInside)
            buttons.append(button)
        }
        return buttons
    }()
    
    private var filterSelectionCollapsed: Bool = true {
        didSet {
            UIView.animate(withDuration: 0.25, delay: 0, options: [UIView.AnimationOptions.beginFromCurrentState], animations: {
//                self.setFilterSelectorContainer()
                self.setfilterSelectButton()
                self.setFilterSelector()
            }, completion: nil)
        }
    }
    
    //MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSettingData()
        
        setColorModeSelectionContainer()
        setFilterSelectorContainer()
        setPasscodeButton()
        
        setGeture()
//        countInfo = fetchAllData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if filterSelector.dataSource == nil {
            filterSelector.dataSource = self
            filterSelector.reloadData()
        }
        checkCurrentFilter()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setColorModeSelectionContainer()
        setFilterSelectorContainer()
        setPasscodeButton()
    }
    //end
    
    //MARK: set containers
    var collapsedContainer: String = ""
    
    enum ContainerName: String {
        case giukCounter
        case albumConter
        case colorSelection
        case passCode
    }
    
    private func setFilterSelectorContainer() {
        let frame = sectionContainerRectAtIndex(numberOfSections - 2)
        if filterSelectorContainer == nil {
            let newContainer = generateUIView(view: filterSelectorContainer, frame: frame)
            newContainer?.identifire = ContainerName.colorSelection.rawValue
            filterSelectorContainer = newContainer
            filterSelectorContainer.clipsToBounds = true
            view.addSubview(filterSelectorContainer)
        } else {
            filterSelectorContainer.setNewFrame(frame)
        }
        setfilterSelectButton()
        setFilterSelector()
    }
    
    private func setColorModeSelectionContainer() {
        var collapsed: Bool {
            return (collapsedContainer == ContainerName.colorSelection.rawValue)
        }
        let colorModeSelectionContainerOrigin = CGPoint(x: sectionContainerOriginX(collapsed: collapsed), y: sectionContainerOriginYs.last!)
        let frame = CGRect(origin: colorModeSelectionContainerOrigin, size: sectionContainerSize)
        if passcodeContainer == nil {
            let newContainer = generateUIView(view: passcodeContainer, frame: frame)
            newContainer?.identifire = ContainerName.passCode.rawValue
            passcodeContainer = newContainer
            view.addSubview(passcodeContainer)
        } else {
            passcodeContainer.setNewFrame(frame)
        }
    }
    //end
    
    //MARk: set filter selector
    private func setFilterSelector() {
        let width = sectionContainerSize.width
        let height = sectionContainerSize.height
        let originX = (sectionContainerSize.width - width)/2
        var originY: CGFloat {
            if filterSelectionCollapsed {
                return sectionContainerSize.height
            } else {
                return CGFloat.zero
            }
        }
        let frame = CGRect(x: originX, y: originY, width: width, height: height)
        if filterSelector == nil {
            let newSelector = generateUIView(view: filterSelector, frame: frame)
            filterSelector = newSelector
            filterSelector.backgroundColor = .black
            filterSelectorContainer.addSubview(filterSelector)
        } else {
            filterSelector.setNewFrame(frame)
        }
    }
    //end
    
    //MARK: set Buttons
    private func setPasscodeButton() {
        if passCodeButton == nil {
            let newButton = ActiveControllButton(activeTitle: DescribingSources.SettingView.passCode_Title_Activated, deactiveTitle: DescribingSources.SettingView.passCode_Title_Deactivated)
            newButton.identifire = "passcode"
            newButton.frame = sectionButtonFrame
            passCodeButton = newButton
            passCodeButton.addTarget(self, action: #selector(buttonActionsFor(_:)), for: .touchUpInside)
            passcodeContainer.addSubview(passCodeButton)
            if let currentCode = currentSetting?.passCode, currentCode != "" {
                passCodeButton.isSelected = true
            } else {
                passCodeButton.isSelected = false
            }
        } else {
            passCodeButton.setNewFrame(sectionButtonFrame)
            if let currentCode = currentSetting?.passCode, currentCode != "" {
                passCodeButton.isSelected = true
            } else {
                passCodeButton.isSelected = false
            }
        }
    }
    
    private func setfilterSelectButton() {
        if filterSelectionCollapsed {
            filterSelectButton?.alpha = 1
        } else {
            filterSelectButton?.alpha = 0
        }
        if filterSelectButton == nil {
            let newButton = ActiveControllButton(activeTitle: DescribingSources.SettingView.filterSelection_Title, deactiveTitle: "")
            newButton.identifire = "filterSelect"
            newButton.isSelected = true
            newButton.frame = sectionButtonFrame
            filterSelectButton = newButton
            filterSelectButton.addTarget(self, action: #selector(buttonActionsFor(_:)), for: .touchUpInside)
            filterSelectorContainer.addSubview(filterSelectButton)
        } else {
            filterSelectButton.setNewFrame(sectionButtonFrame)
        }
    }
    //end
    
    //MARK: ButtonFunction
    
    @objc func buttonActionsFor(_ sender: UIButton_WithIdentifire) {
        if sender.identifire != "filterSelect" {
            filterSelectionCollapsed = true
        }
        switch sender.identifire {
        case "passcode":
            if sender.isSelected {
                guard let curretCode = currentSetting?.passCode else { break }
                let passCodeVC = PassCodeController(mode: .checkingMode, passcode: curretCode)
                passCodeVC.isSelfDestructive = true
                passCodeVC.addCompleteAction {
                    (code) in
                    self.currentSetting.passCode = ""
                    try? self.context.save()
                    self.passCodeButton.isSelected = false
                }
                present(passCodeVC, animated: true)
            } else {
                if let currentCode = currentSetting?.passCode, currentCode != "" {
                    print("error")
                    break
                } else {
                    let passCodeVC = PassCodeController(mode: .inputMode, passcode: "")
                    passCodeVC.isSelfDestructive = true
                    passCodeVC.addCompleteAction {
                        (code) in
                        self.currentSetting.passCode = code
                        try? self.context.save()
                        self.passCodeButton.isSelected = true
                    }
                    present(passCodeVC, animated: true)
                }
            }
        case "filterSelect" :
            filterSelectionCollapsed = false
        default:
            break
        }
    }
    
    @objc func filterButtonAction(_ sender: UIButton_WithIdentifire) {
        for filterButton in filterButtons {
            if filterButton.identifire == sender.identifire {
                filterButton.isSelected = true
            } else {
                filterButton.isSelected = false
            }
        }
        if currentSetting.filterName != sender.identifire {
            currentSetting.filterName = sender.identifire
            try? context.save()
        }
        filterSelectionCollapsed = true
    }
    
    private func checkCurrentFilter() {
        if let filterName = currentSetting.filterName {
            for filterButton in filterButtons {
                if filterButton.identifire == filterName {
                    filterButton.isSelected = true
                } else {
                    filterButton.isSelected = false
                }
            }
        }
    }
    //end
    
    //MARK: WrotedDataCount
    private func fetchSettingData() {
        let request : NSFetchRequest<PrimarySettings> = PrimarySettings.fetchRequest()
        if let setting = try? context.fetch(request).first {
            currentSetting = setting
        }
    }
    //end
    
    //MARK: Gesture recognizer
    private func setGeture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(gestureAction(_:)))
        gesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(gesture)
    }
    
    @objc func gestureAction(_ sender: UIGestureRecognizer) {
        if filterSelectionCollapsed == false {
            filterSelectionCollapsed = true
        }
    }
    //end

}

extension SettingViewController {
    //MARK: Frame variables
    fileprivate var marginInset: (top: CGFloat, bottom: CGFloat) {
        return (8,16)
    }
    
    fileprivate var availableHeight: CGFloat {
        return safeAreaRelatedAreaFrame.height - marginInset.top - marginInset.bottom
    }
    
    fileprivate var sectionContainerSize: CGSize {
        let width = view.bounds.width
        let height = availableHeight / numberOfSections.cgFloat
        return CGSize(width: width, height: height)
    }
    
    fileprivate var sectionContainerStartOriginX: CGFloat {
        return (view.bounds.width - sectionContainerSize.width)/2
    }
    
    fileprivate var sectionContainerEndOriginX: CGFloat {
        return -(sectionContainerSize.width + sectionContainerStartOriginX)
    }
    
    fileprivate var sectionContainerOriginYs: [CGFloat] {
        var points = [safeAreaRelatedAreaFrame.minY + marginInset.top]
        for _ in 0..<(numberOfSections - 1) {
            let newPoint = points.last! + sectionContainerSize.height
            points.append(newPoint)
        }
        return points
    }
    
    fileprivate func sectionContainerOriginX(collapsed: Bool) -> CGFloat {
        if collapsed {
            return sectionContainerEndOriginX
        } else {
            return sectionContainerStartOriginX
        }
    }
    
    fileprivate func sectionContainerRectAtIndex(_ index: Int) -> CGRect {
        if index < numberOfSections {
            let originX = sectionContainerStartOriginX
            let originY = sectionContainerOriginYs[index]
            let origin = CGPoint(x: originX, y: originY)
            return CGRect(origin: origin, size: sectionContainerSize)
        }else {
            return CGRect.zero
        }
    }
    
    fileprivate var sectionButtonFrame: CGRect {
        let minSpaceforWidth = min(sectionContainerSize.width * 0.05, 4)
        let minSpaceforHeight = sectionContainerSize.height * 0.05
        let width = sectionContainerSize.width - (minSpaceforWidth * 2)
        let height = sectionContainerSize.height - (minSpaceforHeight * 2)
        let size = CGSize(width: width, height: height)
        let origin = CGPoint(x: minSpaceforWidth, y: minSpaceforHeight)
        return CGRect(origin: origin, size: size)
    }
}
