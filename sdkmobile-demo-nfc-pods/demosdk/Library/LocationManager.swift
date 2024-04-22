//
//  LocationManager.swift
//  demosdk
//
//  Created by Faustino Flores García on 20/5/22.
//

import CoreLocation
import UIKit

class LocationManager: NSObject {
    // MARK: - STATIC
    static let shared = LocationManager()
    
    // MARK: - VARS
    private var locationManager = CLLocationManager()
   
    // MARK: - PUBLIC FUNC
    func checkLocationPermissions(viewController: UIViewController) {
        if showAlertPermissions() {
            let alertController = UIAlertController(title: "Location Permission Required",
                                                    message: "Please enable location permissions in settings.",
                                                    preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
                // Redirect to Settings app
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url)
                    } else {
                        _ = UIApplication.shared.openURL(url)
                    }
                }
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(cancelAction)
            
            alertController.addAction(okAction)
            
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - PRIVATE FUNC
//    private func showAlertPermissions() -> Bool {
//        var showAlert = false
//
//
//        if CLLocationManager.locationServicesEnabled() {
//            let authorizationStatus: CLAuthorizationStatus
//
//            if #available(iOS 14, *) {
//                authorizationStatus = locationManager.authorizationStatus
//            } else {
//                authorizationStatus = CLLocationManager.authorizationStatus()
//            }
//
//            // switch locationManager.authorizationStatus {
//            switch authorizationStatus {
//            case .notDetermined:
//                locationManager.requestWhenInUseAuthorization()
//            case .denied, .restricted:
//                showAlert = true
//            case .authorizedAlways, .authorizedWhenInUse:
//                break
//            @unknown default:
//                break
//            }
//        } else {
//            showAlert = true
//        }
//
//        return showAlert
//    }
    
   private func showAlertPermissions() -> Bool {
        if #available(iOS 14, *) {
            if CLLocationManager.locationServicesEnabled() {
                let locationManager = CLLocationManager()
                switch locationManager.authorizationStatus {
                case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
                    return false
                default:
                    return true
                }
            }
        } else {
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
                    return false
                default:
                    return true
                }
            }
        }
        return true
    }
}
