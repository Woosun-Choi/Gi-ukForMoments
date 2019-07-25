//
//  Giuk_PresentGiuks_ViewController.swift
//  Gi-ukForMoments
//
//  Created by goya on 15/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit
import CoreData

class GiukViewerViewController: Giuk_OpenFromFrame_ViewController, FocusingIndexBasedCollectionViewDelegate, UICollectionViewDataSource, ImageCroppingViewDelegate, ThumbnailImageViewDelegate
{
    
    var filterModule = ImageFilterModule()
    
    var tagString: String?
    
    var tag: Tag?
    
    var giuks: [Giuk]? {
        didSet {
            nowScrollingView = nil
            presentCollectionView?.reloadData()
            thumbnailCollectionView?.reloadData()
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
    
    weak var editButton: UIButton_WithIdentifire!
    
    weak var deleteButton: UIButton_WithIdentifire!
    
    weak var presentCollectionView: CenteredCollectionView!
    
    weak var pageCounter: PageCounterLabel!
    
    weak var thumbnailViewContainer: UIView!
    
    weak var thumbnailCollectionView: TimeCollectionView!
    
    var nowEditing: Bool = false {
        didSet {
            setPresentCollectionView()
            UIView.animate(withDuration: 0.25, animations: {
                [unowned self] in
                self.viewDidLayoutSubviews()
            })
            UIView.animate(withDuration: 0.35, animations: {
                if self.nowEditing {
                    self.presentCollectionView.alpha = 0.65
                    self.view.backgroundColor = .goyaFontColor
                    self.closeButton.alpha = 0
                } else {
                    self.presentCollectionView.alpha = 1
                    self.view.backgroundColor = .GiukBackgroundColor_depth_1
                    self.closeButton.alpha = 1
                }
            })
            if nowEditing {
                closeButton.isUserInteractionEnabled = false
            } else {
                closeButton.isUserInteractionEnabled = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setEditButton()
        setPresentCollectionView()
        setPageCounter()
        setThumbnailCollectionViewContainer()
        setThumbnailCollectionView()
        setDeleteButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setEditButton()
        setPresentCollectionView()
        setPageCounter()
        setThumbnailCollectionViewContainer()
        setThumbnailCollectionView()
        setDeleteButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _tag = tag {
            giuks = _tag.requestGiuks()
        }
    }
    
    func setEditButton() {
        if editButton == nil {
            let newButton = generateUIView(view: editButton, frame: editButtonFrame)
            newButton?.imageView?.contentMode = .scaleAspectFit
            newButton?.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_Edit), for: .normal)
            newButton?.identifire = "edit"
            newButton?.setTitleColor(.goyaWhite, for: .normal)
            newButton?.addTarget(self, action: #selector(editButtonAction(_:)), for: .touchUpInside)
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
    
    func setDeleteButton() {
        let originX = view.frame.width - deleteButtonSize.width - 16
        let originY:CGFloat = thumbnailFrame.minY - deleteButtonSize.height - 8
        let buttonFrame = CGRect(origin: CGPoint(x: originX, y: originY), size: deleteButtonSize)
        if deleteButton == nil {
            let newButton = generateUIView(view: deleteButton, frame: buttonFrame)
            newButton?.layer.backgroundColor = UIColor.clear.cgColor
            newButton?.layer.cornerRadius = buttonFrame.size.height * 0.2
            newButton?.imageView?.contentMode = .scaleAspectFit
            newButton?.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_Delete), for: .normal)
            newButton?.clipsToBounds = true
            newButton?.identifire = "delete"
            newButton?.setTitleColor(.goyaRoseGoldColor, for: .normal)
            newButton?.addTarget(self, action: #selector(editButtonAction(_:)), for: .touchUpInside)
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
            deleteButton.setNewFrame(buttonFrame)
        }
    }
    
    @objc func editButtonAction(_ sender: UIButton_WithIdentifire) {
        if sender.identifire == "edit" {
            nowEditing = !nowEditing
        } else {
            if let selected = presentCollectionView.focusingIndex {
                presentAlertControllerForEdit(selected)
            }
        }
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
            let newCollectionView = TimeCollectionView(frame: thumbnailCollectionViewFrame, collectionViewLayout: UICollectionViewLayout())
            thumbnailCollectionView = newCollectionView
            thumbnailCollectionView.dataSource = self
            thumbnailCollectionView.focusingCollectionViewDelegate = self
            thumbnailCollectionView.showsVerticalScrollIndicator = false
            thumbnailCollectionView.showsHorizontalScrollIndicator = false
            thumbnailCollectionView.register(ThumbnailCollectionViewCell.self, forCellWithReuseIdentifier: ThumbnailCollectionViewCell.identifier)
            thumbnailCollectionView.layer.backgroundColor = UIColor.goyaBlack.cgColor
            thumbnailViewContainer.addSubview(thumbnailCollectionView)
        } else {
            thumbnailCollectionView?.setNewFrame(thumbnailCollectionViewFrame)
        }
    }
    
    override func closeButtonAction(_ sender: UIButton) {
        giuks = nil
        super.closeButtonAction(sender)
    }
    
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
            ((giuks?.count ?? 0) > 0) ? (cell.giuk = giuks![indexPath.row]) : ()
            return cell
        }
    }
    
    func thumbnailImageViewShouldReturnImageAs(_ thumbnailImageView: ThumbnailImageView, imageData: Data) -> UIImage? {
        let result = filterModule.performImageFilter(.CIPhotoEffectTonal, image: UIImage(data: imageData)!)
        return result
    }
    
    func imageCroppingView(_ croppingView: ImageCroppingView, needRepresentedImageData imageData: Data) -> UIImage? {
        let result = filterModule.performImageFilter(.CIPhotoEffectTonal, image: UIImage(data: imageData)!)
        return result
    }
    
    func collectionViewDidUpdateFocusingIndex(_ collectionView: UICollectionView, with indexPath: IndexPath) {
        checkNowPageAndUpdatePageCounter()
        if collectionView == thumbnailCollectionView {
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
    
    enum ScrollingView {
        case presentor
        case thumbnail
    }
    
    var nowScrollingView : ScrollingView?
    
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
    
    var selectedCell: IndexPath?
    
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
                        //                    self?.collectionView.centeredCollectionView.reloadItems(at: [selected])
                        self?.presentCollectionView.reloadItems(at: [selected])
                    }
                }
                present(newVC,animated: true)
                print(focusedIndex)
            }
        }
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
    
    var editButtonSize: CGSize {
        let width = closeButtonSize.width * 2
        let height = closeButtonSize.height
        return CGSize(width: width, height: height)
    }
    
    var _editButtonSize: CGSize {
        let width = topContainerAreaSize.height * 0.818
        let height = width
        return CGSize(width: width, height: height)
    }
    
    var editButtonFrame: CGRect {
        let originX = topContainerAreaSize.width - GiukContentFrameFactors.contentMinimumMargin.dX - _editButtonSize.width
        let originY = topContainerAreaFrame.minY + ((topContainerAreaSize.height - _editButtonSize.height)/2)
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: _editButtonSize)
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
        return CGSize(width: 35, height: 35)
    }

}
