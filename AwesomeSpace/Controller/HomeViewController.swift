//
//  HomeViewController.swift
//  AwesomeSpace
//
//  Created by Yohannes Haile on 9/29/24.
//

import UIKit
import ARKit
import RealityKit

class HomeViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let homeView = HomeView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        view.addSubview(homeView)
    }

}


