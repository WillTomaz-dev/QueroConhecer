//
//  PlaceFinderViewController.swift
//  QueroConhecer
//
//  Created by William Tomaz on 01/06/20.
//  Copyright © 2020 William Tomaz. All rights reserved.
//

import MapKit
import UIKit

protocol PlaceFinderDelegate: class{
    func addPlace(_ place: Place)
}

class PlaceFinderViewController: UIViewController {

    enum placeFinderMessageType {
        case error(String)
        case confirmation(String)
    }
    
    
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    @IBOutlet weak var viLoading: UIView!
    
    var place: Place!
    weak var delegate : PlaceFinderDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(getLocation(_ :)))
        gesture.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(gesture)
    }

    @IBAction func findCity(_ sender: UIButton) {
        if (tfCity.text?.isEmpty)! {
           self.showMessage(type: .error("O Campo de pesquisa não pode ser vazio!!"))
        }else{
            tfCity.resignFirstResponder()
            let address = tfCity.text!
            load(show: true)
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                self.load(show: false)
                if error == nil {
                    if !self.savePlace(with: placemarks?.first) {
                        self.showMessage(type: .error("Local não encontrado"))
                    }
                }else {
                        self.showMessage(type: .error("Erro desconhecido"))
                    }
                }
            }
        }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)

    }
    
    func savePlace(with placemark: CLPlacemark?) -> Bool {
        guard let placemark = placemark, let coordinate = placemark.location?.coordinate else {
            return false
        }
        let name = placemark.name ?? placemark.country ?? "Desconhecido"
        let address = Place.getFormattedAddress(with: placemark)
        place = Place (name: name, latitude: coordinate.latitude, longitude: coordinate.longitude, address: address)
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
        mapView.setRegion(region, animated: true)
        
        self.showMessage(type: .confirmation(place.name))

        return true
    }
    
    func showMessage(type: placeFinderMessageType) {
        let title: String, message: String
        var hasConfirmation: Bool = false
        switch type {
            case .confirmation(let name):
                title = "Local Encontrado"
                message = "Deseja adicionar \(name)?"
                hasConfirmation = true
            case .error(let errorMessage):
                title = "Erro"
                message = errorMessage
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        if hasConfirmation {
            let confirmAction = UIAlertAction(title: "OK", style: .default) { (action) in
                self.delegate?.addPlace(self.place)
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(confirmAction)
        }
        present(alert, animated: true, completion: nil)
    }
    
    func load(show: Bool) {
        viLoading.isHidden = !show
        if show {
            aiLoading.startAnimating()
        } else {
            aiLoading.stopAnimating()
        }
    }
    
    @objc func getLocation(_ gesture: UILongPressGestureRecognizer){ //pega localização no toque
        if gesture.state == .began {
            load(show: true)
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                self.load(show: false)
                if error == nil {
                    if !self.savePlace(with: placemarks?.first) {
                        self.showMessage(type: .error("Local não encontrado"))
                    }
                }else {
                    self.showMessage(type: .error("Erro desconhecido"))
                }
            }
        }
    }
}

