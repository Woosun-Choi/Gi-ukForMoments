//
//  Giuk_PresentGiuks_ViewController.swift
//  Gi-ukForMoments
//
//  Created by goya on 15/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit
import CoreData

class GiukViewerViewController: Giuk_OpenFromFrame_ViewController
{
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    //MARk: subviews
    weak var editButton: UIButton_WithIdentifire!
    
    weak var addButton: UIButton_WithIdentifire!
    
    weak var deleteButton: UIButton_WithIdentifire!
    
    weak var presentCollectionView: CenteredCollectionView!
    
    weak var pageCounter: PageCounterLabel!
    
    weak var thumbnailViewContainer: UIView!
    
    weak var thumbnailCollectionView: Giuk_ThumbnailCollectionView!
    //end
    
    //MARK: Variables
    var isFirstLoaded: Bool = true
    
    var filterModule = ImageFilterModule()
    
    var filterEffect : ImageFilterModule.CIFilterName = .CIPhotoEffectTonal
    
    var tagString: String?
    
    var tag: Tag?
    
    var updatePermistion: Bool = true
    
    var giuks: [Giuk]? {
        didSet {
            if updatePermistion {
                nowScrollingView = nil
                presentCollectionView?.reloadData()
                thumbnailCollectionView?.reloadData()
            }
        }
    }
    
    var container: NSPersistentContainer? = AppDelegate.persistentContainer
    
    var context: NSManagedObjectContext {
        if let context = container?.viewContext {
            return context
        } else {
            return AppDelegate.viewContext
        }
    }
    
    enum ScrollingView {
        case presentor
        case thumbnail
    }
    
    var nowScrollingView : ScrollingView?
    
    var selectedCell: IndexPath?
    
    var frontButtons: [UIButton_WithIdentifire?] {
        return [closeButton,editButton,addButton]
    }
    
    var controlButtons: [UIButton_WithIdentifire?] {
        return [closeButton, editButton, addButton, deleteButton]
    }
    
    var nowEditing: Bool = false {
        didSet {
            setPresentCollectionView()
            UIView.animate(withDuration: 0.25, animations: {
                [unowned self] in
                self.viewDidLayoutSubviews()
            })
            UIView.animate(withDuration: 0.35, animations: {
                [unowned self] in
                if self.nowEditing {
                    self.presentCollectionView.alpha = 0.65
                    self.view.backgroundColor = .goyaSemiBlackColor
                    self.closeButton.alpha = 0
                    self.addButton.alpha = 0
                } else {
                    self.presentCollectionView.alpha = 1
                    self.view.backgroundColor = .GiukBackgroundColor_depth_1
                    self.closeButton.alpha = 1
                    self.addButton.alpha = 1
                }
            })
            if nowEditing {
                closeButton.isUserInteractionEnabled = false
                addButton.isUserInteractionEnabled = false
            } else {
                closeButton.isUserInteractionEnabled = true
                addButton.isUserInteractionEnabled = true
            }
        }
    }
    //end

    override func viewDidLoad() {
        super.viewDidLoad()
        setAllSubViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setAllSubViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateGiuks()
        if !isFirstLoaded {
            checkTagData()
        }
        isFirstLoaded = false
    }
    
    //MARK: extra functions
    private func updateGiuks() {
        if let _tag = tag {
            giuks = _tag.requestGiuks()
        }
    }
    
    override func closeButtonAction(_ sender: UIButton) {
        giuks = nil
        super.closeButtonAction(sender)
    }
    
    private func checkTagData() {
        print("checking Tag")
        if let _tag = tag {
            if let tagName = _tag.tagName {
                let request: NSFetchRequest<Tag> = Tag.fetchRequest()
                let predicate = NSPredicate(format: "tagName == %@", tagName)
                request.predicate = predicate
                let result = try? context.count(for: request)
                if result == 0 {
                    dismiss(animated: true, completion: nil)
                }
            } else {
                dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: Button actions
    @objc func controlButtonActions(_ sender: UIButton_WithIdentifire) {
        switch sender.identifire {
        case "edit": nowEditing = !nowEditing
        case "add":
            if let nowTag = self.tag
            {
                presentWritingViewControllerWithTag(nowTag)
            }
        default:
            if let selected = presentCollectionView.focusingIndex {
                presentAlertControllerForEdit(selected)
            }
        }
    }
    
    private func presentWritingViewControllerWithTag(_ tag: Tag) {
        let newVC = WriteSectionViewController()
        newVC.isEditOnly = false
        newVC.primarySelectedTag = tag.tagName
        newVC.requieredActionWhenSavingComplete = {
            [weak self] in
            if newVC.savingCompleted {
                let firstIndex = IndexPath(item: 0, section: 0)
                self?.presentCollectionView.setStartIndexTo(firstIndex)
                self?.thumbnailCollectionView.setStartIndexTo(firstIndex)
            }
        }
        present(newVC, animated:  true)
    }
    
    private func presentAlertControllerForEdit(_ index: IndexPath) {
        let alert = UIAlertController(title: DescribingSources.deleteSection.delete_Title, message: DescribingSources.deleteSection.delete_SubTitle, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: DescribingSources.deleteSection.delete_Title_CancelAction, style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: DescribingSources.deleteSection.delete_Title_DeleteAction, style: .destructive) {
            [unowned self] (action) in
            if let targetGiuk = self.giuks?[index.row] {
                targetGiuk.deleteGiuk(context: self.context) {
                    [weak self] in
                    self?.giuks?.remove(at: index.item)
                    if self?.giuks?.count == 0 {
                        self?.closeButtonAction(self!.closeButton)
                    }
                }
            }
        }
        let removeAction = UIAlertAction(title: DescribingSources.deleteSection.delete_Title_RemoveAction, style: .default) {
            [unowned self] (action) in
            if let targetGiuk = self.giuks?[index.row] {
                targetGiuk.deleteGiukFromTag(context: self.context, tag: self.tag!) {
                    [weak self] in
                    self?.giuks?.remove(at: index.item)
                    if self?.giuks?.count == 0 {
                        self?.closeButtonAction(self!.closeButton)
                    }
                }
            }
        }
        alert.addAction(removeAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    //end
}

extension GiukViewerViewController {
    //MARK: set subviews
    private func setEditButton() {
        if editButton == nil {
            let newButton = generateUIView(view: editButton, frame: editButtonFrame)
            newButton?.imageView?.contentMode = .scaleAspectFit
            newButton?.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_Edit), for: .normal)
            newButton?.identifire = "edit"
            newButton?.setTitleColor(.goyaWhite, for: .normal)
            newButton?.addTarget(self, action: #selector(controlButtonActions(_:)), for: .touchUpInside)
            newButton?.backgroundColor = .clear
            editButton = newButton
            view.addSubview(editButton)
        } else {
            if nowEditing {
                editButton?.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_Edit_Done), for: .normal)
            } else {
                editButton?.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_Edit), for: .normal)
            }
            editButton.setNewFrame(editButtonFrame)
            view.bringSubviewToFront(editButton)
        }
    }
    
    private func setAddButton() {
        if addButton == nil {
            let newButton = generateUIView(view: addButton, frame: addButtonFrame)
            newButton?.layer.backgroundColor = UIColor.clear.cgColor
            newButton?.imageView?.contentMode = .scaleAspectFit
            newButton?.setImage(UIImage(named: ButtonImageNames.ButtonName_Main_Giuk), for: .normal)
            newButton?.clipsToBounds = true
            newButton?.identifire = "add"
            newButton?.setTitleColor(.goyaRoseGoldColor, for: .normal)
            newButton?.addTarget(self, action: #selector(controlButtonActions(_:)), for: .touchUpInside)
            addButton = newButton
            view.addSubview(addButton)
        } else {
            addButton.setNewFrame(addButtonFrame)
        }
    }
    
    private func setDeleteButton() {
        if deleteButton == nil {
            let newButton = generateUIView(view: deleteButton, frame: deleteButtonFrame)
            newButton?.layer.backgroundColor = UIColor.clear.cgColor
            newButton?.imageView?.contentMode = .scaleAspectFit
            newButton?.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_Delete), for: .normal)
            newButton?.clipsToBounds = true
            newButton?.identifire = "delete"
            newButton?.setTitleColor(.goyaRoseGoldColor, for: .normal)
            newButton?.addTarget(self, action: #selector(controlButtonActions(_:)), for: .touchUpInside)
            deleteButton = newButton
            if nowEditing {
                deleteButton.isUserInteractionEnabled = true
                deleteButton.alpha = 1
            } else {
                deleteButton.isUserInteractionEnabled = false
                deleteButton.alpha = 0
            }
            view.addSubview(deleteButton)
        } else {
            if nowEditing {
                deleteButton.isUserInteractionEnabled = true
                deleteButton.alpha = 1
            } else {
                deleteButton.isUserInteractionEnabled = false
                deleteButton.alpha = 0
            }
            deleteButton.setNewFrame(deleteButtonFrame)
        }
    }
    
    func setPresentCollectionView() {
        if presentCollectionView == nil {
            let layout = CenteredCollectionViewFlowLayout()
            let newCollectionView = CenteredCollectionView(frame: presentorFrame, collectionViewLayout: layout)
            if let targetLayout = newCollectionView.flowLayouts as? CenteredCollectionViewFlowLayout {
                targetLayout.isFullscreen = false
                targetLayout.estimateCellSize = cellEstimatedSize
            }
            presentCollectionView = newCollectionView
            presentCollectionView.focusingCollectionViewDelegate = self
            presentCollectionView.dataSource = self
            presentCollectionView.register(GiukViewerCollectionViewCell.self, forCellWithReuseIdentifier: GiukViewerCollectionViewCell.identifier)
            presentCollectionView.backgroundColor = .clear
            presentCollectionView.showsVerticalScrollIndicator = false
            presentCollectionView.showsHorizontalScrollIndicator = false
            presentCollectionView.clipsToBounds = true
            presentCollectionView.allowsSelection = false
            view.addSubview(presentCollectionView)
        } else {
            presentCollectionView?.setNewFrame(presentorFrame)
            if let targetLayout = presentCollectionView.flowLayouts as? CenteredCollectionViewFlowLayout {
                targetLayout.estimateCellSize = cellEstimatedSize
            }
            presentCollectionView?.reloadData()
        }
    }
    
    func setPageCounter() {
        if pageCounter == nil {
            let newLabel = generateUIView(view: pageCounter, frame: pageCounterFrame)
            pageCounter = newLabel
            pageCounter.dataSource = self
            view.addSubview(pageCounter)
        } else {
            pageCounter?.setNewFrame(pageCounterFrame)
        }
    }
    
    func setThumbnailCollectionViewContainer() {
        if thumbnailViewContainer == nil {
            let newView = generateUIView(view: thumbnailViewContainer, frame: thumbnailFrame)
            thumbnailViewContainer = newView
            thumbnailViewContainer.clipsToBounds = true
            view.addSubview(thumbnailViewContainer)
        } else {
            thumbnailViewContainer?.setNewFrame(thumbnailFrame)
        }
    }
    
    func setThumbnailCollectionView() {
        if thumbnailCollectionView == nil {
            let newCollectionView = Giuk_ThumbnailCollectionView(frame: thumbnailCollectionViewFrame, collectionViewLayout: UICollectionViewLayout())
            thumbnailCollectionView = newCollectionView
            thumbnailCollectionView.dataSource = self
            thumbnailCollectionView.focusingCollectionViewDelegate = self
            thumbnailCollectionView.dragDelegate = self
            thumbnailCollectionView.dropDelegate = self
            thumbnailCollectionView.showsVerticalScrollIndicator = false
            thumbnailCollectionView.showsHorizontalScrollIndicator = false
            thumbnailCollectionView.register(ThumbnailCollectionViewCell.self, forCellWithReuseIdentifier: ThumbnailCollectionViewCell.identifier)
            thumbnailCollectionView.layer.backgroundColor = UIColor.goyaBlack.cgColor
            thumbnailViewContainer.addSubview(thumbnailCollectionView)
        } else {
            thumbnailCollectionView?.setNewFrame(thumbnailCollectionViewFrame)
        }
    }
    
    private func setAllSubViews() {
        setEditButton()
        setAddButton()
        setPresentCollectionView()
        setPageCounter()
        setThumbnailCollectionViewContainer()
        setThumbnailCollectionView()
        setDeleteButton()
    }
    //end
}

extension GiukViewerViewController: UICollectionViewDataSource {
    //MARK: collectionView dataSources
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return giuks?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == presentCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GiukViewerCollectionViewCell.identifier, for: indexPath) as! GiukViewerCollectionViewCell
            cell.viewer.imageView.delegate = self
            ((giuks?.count ?? 0) > 0) ? (cell.giuk = giuks![indexPath.row]) : ()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailCollectionViewCell.identifier, for: indexPath) as! ThumbnailCollectionViewCell
            cell.imageView.delegate = self
            if let colView = collectionView as? Giuk_ThumbnailCollectionView {
                if colView.focusingIndex != indexPath {
                    cell.nowFocused = false
                }
            }
            ((giuks?.count ?? 0) > 0) ? (cell.giuk = giuks![indexPath.row]) : ()
            return cell
        }
    }
    //end
}

extension GiukViewerViewController: FocusingIndexBasedCollectionViewDelegate {
    //MARK: Focusingbased collectionView delegate
    func collectionViewDidUpdateFocusingIndex(_ collectionView: UICollectionView, with indexPath: IndexPath) {
        checkNowPageAndUpdatePageCounter()
        checkNowFocusedCellAndLayoutForFocusing(collectionView, indexPath: indexPath)
    }
    
    func checkNowFocusedCellAndLayoutForFocusing(_ collectionView: UICollectionView, indexPath: IndexPath) {
        if collectionView == thumbnailCollectionView {
            print("highlighted cell checked")
            for cell in collectionView.visibleCells {
                if let targetCell = cell as? ThumbnailCollectionViewCell {
                    if collectionView.indexPath(for: targetCell) == indexPath {
                        targetCell.nowFocused = true
                    } else {
                        targetCell.nowFocused = false
                    }
                }
            }
        }
    }
    
    func collectionViewDidEndScrollToIndex(_ collectionView: UICollectionView, finished: Bool) {
        if finished {
            if collectionView == presentCollectionView && nowScrollingView == .presentor {
                print("presenter called")
                if thumbnailCollectionView.focusingIndex != presentCollectionView.focusingIndex {
                    thumbnailCollectionView.focusingIndex = presentCollectionView.focusingIndex
                    thumbnailCollectionView.scrollToTargetIndex(index: presentCollectionView.focusingIndex!, animated: true)
                }
            }
            else if collectionView == thumbnailCollectionView && nowScrollingView == .thumbnail {
                print("thumbnailScroll called")
                if presentCollectionView.focusingIndex != thumbnailCollectionView.focusingIndex {
                    presentCollectionView.focusingIndex = thumbnailCollectionView.focusingIndex
                    presentCollectionView.scrollToTargetIndex(index: thumbnailCollectionView.focusingIndex!, animated: false)
                }
            }
            checkNowPageAndUpdatePageCounter()
        }
    }
    
    func collectionViewScrollingState(_ collectionView: UICollectionView, scrolling: Bool) {
        if scrolling == true {
            if collectionView == presentCollectionView {
                nowScrollingView = .presentor
            } else if collectionView == thumbnailCollectionView {
                nowScrollingView = .thumbnail
            }
        } else {
            nowScrollingView = nil
        }
    }
    
    func collectionViewDidSelectFocusedIndex(_ collectionView: UICollectionView, focusedIndex: IndexPath, cell: UICollectionViewCell) {
        if collectionView == presentCollectionView {
            
        } else {
            if let cell = collectionView.cellForItem(at: focusedIndex) as? ThumbnailCollectionViewCell {
                nowScrollingView = .thumbnail
                selectedCell = focusedIndex
                let newVC = WriteSectionViewController()
                newVC.isEditOnly = true
                newVC.giuk = cell.giuk
                newVC.closingFunction = {
                    [weak self] in
                    if let selected = self?.selectedCell {
                        self?.presentCollectionView.reloadItems(at: [selected])
                    }
                }
                present(newVC,animated: true)
            }
        }
    }
}

extension GiukViewerViewController: ImageCroppingViewDelegate, ThumbnailImageViewDelegate {
    //MARK: PresentingImages To collectionview cells delegates
    func imageCroppingView(_ croppingView: ImageCroppingView, needRepresentedImageData imageData: Data) -> UIImage? {
        if isNonColorPresneting {
            let result = filterModule.performImageFilter(filterEffect, image: UIImage(data: imageData)!)
            return result
        } else {
            return nil
        }
    }
    
    func thumbnailImageViewShouldReturnImageAs(_ thumbnailImageView: ThumbnailImageView, imageData: Data) -> UIImage? {
        if isNonColorPresneting {
            let result = filterModule.performImageFilter(filterEffect, image: UIImage(data: imageData)!)
            return result
        } else {
            return nil
        }
    }
    //end
}

extension GiukViewerViewController: UICollectionViewDragDelegate {
    //MARK: drag delegate
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let cell = (thumbnailCollectionView.cellForItem(at: indexPath) as? ThumbnailCollectionViewCell) {
            let giuk = cell.giuk!
            let string = giuk.identifire!
            let attributedString = NSAttributedString(string: string)
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))
            dragItem.localObject = giuk
            return [dragItem]
        } else {
            return []
        }
    }
}

extension GiukViewerViewController: UICollectionViewDropDelegate {
    //MARK: drop delegate
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if let giuk = item.dragItem.localObject as? Giuk {
                    updatePermistion = false
                    self.giuks?.remove(at: sourceIndexPath.item)
                    self.giuks?.insert(giuk, at: destinationIndexPath.item)
                    thumbnailCollectionView.focusingIndex = destinationIndexPath
                    thumbnailCollectionView.scrollToTargetIndex(index: destinationIndexPath, animated: false)
                    checkIndexPathConsistency()
                    reloadCellsInVisible(presentCollectionView)
                    reloadCellsInVisible(thumbnailCollectionView)
                    checkNowFocusedCellAndLayoutForFocusing(thumbnailCollectionView, indexPath: destinationIndexPath)
                    tag?.replaceGiukIndexInTo(replacingGiuk: giuk, fromIndex: sourceIndexPath.item, toIndex: destinationIndexPath.item)
                    try? context.save()
                    updatePermistion = true
//                    updateGiuks()
                }
            }
        }
    }
    
    private func checkIndexPathConsistency() {
        if let nowFocused = thumbnailCollectionView.focusingIndex {
            presentCollectionView.focusingIndex = nowFocused
            presentCollectionView.scrollToTargetIndex(index: nowFocused, animated: false)
        }
    }
    
    private func reloadCellsInVisible(_ collectionView: UICollectionView) {
        var cellIndexes = [IndexPath]()
        for cell in collectionView.visibleCells {
            if let index = collectionView.indexPath(for: cell) {
                cellIndexes.append(index)
            }
        }
        collectionView.reloadItems(at: cellIndexes)
    }
    
    
}

extension GiukViewerViewController: PageCounterLabelDatasource {
    func numberOfPages(_ counterLabel: PageCounterLabel) -> Int? {
        return giuks?.count
    }
    
    func checkNowPageAndUpdatePageCounter() {
        if let nowIndex = presentCollectionView.focusingIndex?.item {
            pageCounter.updateCounterWithPage(nowIndex + 1)
        }
    }
}

extension GiukViewerViewController {
    //MARK: Frame resources
    var editButtonSize: CGSize {
        let width = min(topContainerAreaSize.height * 0.718, 35)
        let height = width
        return CGSize(width: width, height: height)
    }
    
    var addButtonFrame: CGRect {
        let originX = topContainerAreaSize.width - GiukContentFrameFactors.contentMinimumMargin.dX - editButtonSize.width
        let originY = topContainerAreaFrame.minY + ((topContainerAreaSize.height - editButtonSize.height)/2)
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: editButtonSize)
    }
    
    var editButtonFrame: CGRect {
        let originX = topContainerAreaSize.width - GiukContentFrameFactors.contentMinimumMargin.dX - editButtonSize.width
        var originY = thumbnailFrame.minY - editButtonSize.height - 8
        if !nowEditing {
            originY = pageCounterFrame.midY - (editButtonSize.height/2)
        }
        //topContainerAreaFrame.minY + ((topContainerAreaSize.height - editButtonSize.height)/2)
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: editButtonSize)
    }
    
    var presentorFrame: CGRect {
        if nowEditing {
            return contentAreaFrame
        } else {
            return fullContentFrameForPresentor
        }
    }
    
    var fullContentFrameForPresentor: CGRect {
        let width = fullContentFrame.width
        let height = fullContentFrame.height * 0.9
        let size = CGSize(width: width, height: height)
        let origin = fullContentFrame.origin
        return CGRect(origin: origin, size: size)
    }
    
    var pageCounterFrame: CGRect {
        let width = fullContentFrame.width
        let height = fullContentFrame.height - fullContentFrameForPresentor.height
        let size = CGSize(width: width, height: height)
        let originY = fullContentFrameForPresentor.maxY
        let originX: CGFloat = 0
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: size)
    }
    
    var thumbnailFrame: CGRect {
        if nowEditing {
            return bottomContainerAreaFrame
        } else {
            let width = bottomContainerAreaFrame.width
            let height: CGFloat = 0
            let size = CGSize(width: width, height: height)
            let origin = bottomContainerAreaFrame.origin.offSetBy(dX: 0, dY: bottomContainerAreaFrame.height)
            return CGRect(origin: origin, size: size)
        }
    }
    
    var thumbnailCollectionViewFrame: CGRect {
        let size = bottomContainerAreaFrame.size
        let origin = CGPoint(x: 0, y: 0)
        return CGRect(origin: origin, size: size)
    }
    
    var cellEstimatedSize: CGSize {
        var width = (presentorFrame.width * 0.9).preventNaN.clearUnderDot
        if nowEditing {
            width = (presentorFrame.width * 0.75).preventNaN.clearUnderDot
        }
        let height = (width/3)*4
        return CGSize(width: width, height: height)
    }
    
    var deleteButtonSize: CGSize {
        let width = min(bottomContainerAreaSize.height * 0.4, 35)
        let height = width
        return CGSize(width: width, height: height)
    }
    
    var deleteButtonFrame: CGRect {
        let originX = CGFloat(16)//view.frame.width - deleteButtonSize.width - 16
        let originY = thumbnailFrame.minY - deleteButtonSize.height - 8//thumbnailFrame.minY - deleteButtonSize.height - 8
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: deleteButtonSize)
    }

}
