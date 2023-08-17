//
//  ReviewViewController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/25/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

/// The `ReviewViewController` offers an interface to review the image after it has been cropped and deskwed according to the passed in quadrilateral.
final class ReviewViewController: UIViewController {
    
    var enhancedImageIsAvailable = false
    var isCurrentlyDisplayingEnhancedImage = false
    
    lazy private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isOpaque = true
        imageView.image = results.scannedImage
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy private var enhanceButton: UIBarButtonItem = {
        let image = UIImage(named: "enhance", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(toggleEnhancedImage))
        button.tintColor = .white
        return button
    }()
    
    lazy private var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finishScan))
        button.tintColor = .white
        return button
    }()
    
    private let results: ImageScannerResults
    
    // MARK: - Life Cycle
    
    init(results: ImageScannerResults) {
        self.results = results
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        enhancedImageIsAvailable = results.enhancedImage != nil
        
        setupViews()
        setupToolbar()
        setupConstraints()
        
        title = NSLocalizedString("wescan.review.title", tableName: nil, bundle: Bundle(for: ReviewViewController.self), value: "Review", comment: "The review title of the ReviewController")
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // We only show the toolbar (with the enhance button) if the enhanced image is available.
        if enhancedImageIsAvailable {
            navigationController?.setToolbarHidden(false, animated: true)
        }
        
        
        let widht = self.view.frame.width
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: widht-120, height: 35))
        lblTitle.text = "Review"
        lblTitle.font = .systemFont(ofSize: 17)
        lblTitle.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        lblTitle.textAlignment = .center
        lblTitle.shadowColor = .black
        lblTitle.shadowOffset = CGSize(width: 0.0, height: 1.0)
        lblTitle.layer.shadowOpacity = 0.0
        lblTitle.layer.shadowRadius = 16.0
        
        
        self.navigationItem.titleView = lblTitle
        let btnBack = UIButton(type: .custom)
        btnBack.frame = CGRect(x: 0, y: 0, width: 44.0, height: 44.0)
        btnBack.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        btnBack.setImage(UIImage(named: "icBackV2"), for: .normal)
        btnBack.tintColor = .white
        btnBack.addTarget(self, action: #selector(onClickBackBtn), for:.touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btnBack)
        
        navigationItem.rightBarButtonItem = doneButton
        
    }
    
    @objc func onClickBackBtn(){
        guard let imageScannerController = navigationController as? ImageScannerController else { return }
        imageScannerController.imageScannerDelegate?.imageScannerControllerDidCancel(imageScannerController)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    // MARK: Setups
    
    private func setupViews() {
        view.addSubview(imageView)
    }
    
    private func setupToolbar() {
        guard enhancedImageIsAvailable else { return }
        
        navigationController?.toolbar.barStyle = .blackTranslucent
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        toolbarItems = [fixedSpace, enhanceButton]
    }
    
    private func setupConstraints() {
        let imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ]
        
        NSLayoutConstraint.activate(imageViewConstraints)
    }
    
    // MARK: - Actions
    
    @objc private func toggleEnhancedImage() {
        guard enhancedImageIsAvailable else { return }
        if isCurrentlyDisplayingEnhancedImage {
            imageView.image = results.scannedImage
            enhanceButton.tintColor = .white
        } else {
            imageView.image = results.enhancedImage
            enhanceButton.tintColor = UIColor(red: 64 / 255, green: 159 / 255, blue: 255 / 255, alpha: 1.0)
        }
        
        isCurrentlyDisplayingEnhancedImage.toggle()
    }
    
    @objc private func finishScan() {
        guard let imageScannerController = navigationController as? ImageScannerController else { return }
        var newResults = results
        newResults.scannedImage = results.scannedImage
        newResults.doesUserPreferEnhancedImage = isCurrentlyDisplayingEnhancedImage
        imageScannerController.imageScannerDelegate?.imageScannerController(imageScannerController, didFinishScanningWithResults: newResults)
    }

}
