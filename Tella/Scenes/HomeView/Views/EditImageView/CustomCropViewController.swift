//
//  CustomCropViewController.swift
//  Tella
//
//  Created by RIMA on 15/5/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Mantis
import Combine
class CustomCropViewController: Mantis.CropViewController {
    
    @Published var isUpdatingImage = PassthroughSubject<Bool, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItem()
    }

    override func viewWillLayoutSubviews() {
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setupApperance()
    }

    private func setUpNavigationItem() {
        let close = UIBarButtonItem(
            image: UIImage.init(named: "close")?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(onCloseClicked)
        )
        
        let done = UIBarButtonItem(
            image: UIImage.init(named: "file.edit.done")?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(onDoneClicked)
        )
        navigationItem.leftBarButtonItem = close
        navigationItem.rightBarButtonItem = done
    }
    
    @objc private func onDoneClicked() {
        crop()
    }
    
    @objc private func onCloseClicked() {
        isUpdatingImage.send(true)
        didSelectCancel()
    }
}

