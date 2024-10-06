//
//  HomeView.swift
//  AwesomeSpace
//
//  Created by Yohannes Haile on 9/29/24.
//

import UIKit
import ARKit
import RealityKit
import CoreMotion
import CoreLocation

class HomeView: ARView {
    let motionManager = CMMotionManager()
    let locationManager = CLLocationManager()
    
    var latitude = 0.0
    
    var longitude = 0.0
    
    var altitude = 0.0
    
    var azimuthDegrees = 0.0
    
    private let exoplanetNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(named: "SecondaryAccentColor")
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.isHidden = true
        return label
    }()
    
    private let habitablityFactorsLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(named: "AccentColor")
        label.textColor = .white
        label.textAlignment = .justified
        label.numberOfLines = .zero
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private let scanBtn: UIButton = {
        let button = UIButton()
        button.setTitle("Scan My Space", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "AccentColor")
        button.layer.cornerRadius = 5
        return button
    }()
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        addSubview(exoplanetNameLabel)
        addSubview(habitablityFactorsLabel)
        scanBtn.addTarget(self, action: #selector(didTapScan), for: .touchUpInside)
        addSubview(scanBtn)
        applyConstraints()
        setupARSession()
        
        startTrackingAzimuth()
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(){
        self.init(frame: UIScreen.main.bounds)
    }
    
    private func applyConstraints(){
        exoplanetNameLabel.translatesAutoresizingMaskIntoConstraints = false
        habitablityFactorsLabel.translatesAutoresizingMaskIntoConstraints = false
        scanBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let exoplanetNameLabelConstraints = [
            exoplanetNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 100),
            exoplanetNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            exoplanetNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            exoplanetNameLabel.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        let habitablityFactorsLabelConstraints = [
            habitablityFactorsLabel.topAnchor.constraint(equalTo: exoplanetNameLabel.bottomAnchor, constant: 5),
            habitablityFactorsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            habitablityFactorsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            habitablityFactorsLabel.heightAnchor.constraint(equalToConstant: 80)
        ]
        
        let scanBtnConstraints = [
            scanBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100),
            scanBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            scanBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            scanBtn.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        NSLayoutConstraint.activate(exoplanetNameLabelConstraints)
        NSLayoutConstraint.activate(habitablityFactorsLabelConstraints)
        NSLayoutConstraint.activate(scanBtnConstraints)
    }
    
    private func setupARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        session.run(configuration)
    }
    
    
    func loadExoplanet(color: UIColor){
        
        let sphere = MeshResource.generateSphere(radius: 0.35)
        
        let material = SimpleMaterial(color: color, isMetallic: false)
        
        
        let exoplanet = ModelEntity(mesh: sphere, materials: [material])
        
        
        let anchor = AnchorEntity(world: [0, 0.5, -3])

        anchor.addChild(exoplanet)
        
        
        scene.addAnchor(anchor)
    }
    
    
    func startTrackingAzimuth() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                guard let motion = motion, error == nil else { return }
                self?.handleDeviceMotionUpdate(motion)
            }
        } else {
            print("Device motion is not available")
        }
    }
    
    func handleDeviceMotionUpdate(_ motion: CMDeviceMotion) {
        
        let yaw = motion.attitude.yaw
        let azimuth = yaw * (180 / .pi)
        azimuthDegrees = (azimuth >= 0) ? azimuth : (360 + azimuth)
    }
    
    private func fetchExoplanet(scannedSpace: ScannedSpace){
        Task.init {
            do{
                let response = try await AwesomeSpaceNetworkManager.shared.findExoplanet(request: scannedSpace)
                print("Exoplanet: \(response.data.exoplanet.name)")
                
                let exoplanet = response.data.exoplanet.name
                let factor = response.data.exoplanet.habitabilityFactors
                let exoplanetColor = response.data.exoplanet.rgbColor
                
                let color = UIColor(red: exoplanetColor.r, green: exoplanetColor.g, blue: exoplanetColor.b, alpha: 1)
                
                loadExoplanet(color: color)
                exoplanetNameLabel.text = exoplanet
                habitablityFactorsLabel.text = factor
                
                exoplanetNameLabel.isHidden = false
                habitablityFactorsLabel.isHidden = false
                scanBtn.isHidden = true
                                
            }catch(let error as AwesomeSpaceNetworkError){
                
                let alert = UIAlertController(title: "Whoops", message: error.recoverySuggestion, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(alertAction)
                
                DispatchQueue.main.async {
                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }catch{
                
                let alert = UIAlertController(title: "Whoops", message: error.localizedDescription, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(alertAction)
                
                DispatchQueue.main.async {
                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc private func didTapScan(){

        scanBtn.setTitle("🔭🪐", for: .normal)
        
        let scannedSpace = ScannedSpace(latitude: latitude, longitude: longitude, azimuth: azimuthDegrees, altitude: altitude)
        fetchExoplanet(scannedSpace: scannedSpace)
    }
}



extension HomeView: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {

            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            altitude = location.altitude
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}


