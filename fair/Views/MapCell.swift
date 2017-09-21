//
//  MapCell.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/20/17.
//  Copyright © 2017 fair. All rights reserved.
//

import UIKit
import MapKit

class MapCell: UITableViewCell {
   
    @IBOutlet weak var mapView: MKMapView!
    
    public var make: Make? {
        didSet {
            guard let make = make, let location = location else { return }
            searchWith(query: make.niceName, location: location)
        }
    }
    
    public var location: CLLocation? {
        didSet {
            guard let location = location else { return }
            let viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
            mapView.setRegion(viewRegion, animated: false)
            
            guard let make = make else { return }
            searchWith(query: make.niceName, location: location)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isScrollEnabled = false
    }
    
    private func searchWith(query: String, location: CLLocation) {
        search(query: query, spanmeters: 500, location: location) { (response, error) in
            guard let response = response else { return }
            self.mapView.setRegion(response.boundingRegion, animated: true)
            let _ = response.mapItems.map { $0 }.map { self.mapView.addAnnotation( $0.placemark ) }
        }
    }
    
    public func search(query: String, spanmeters span: Double, location: CLLocation, completionHandler: @escaping MKLocalSearchCompletionHandler){
        let searchRequest = MKLocalSearchRequest()
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, span, span)
        searchRequest.region = MKCoordinateRegion(center: location.coordinate, span: region.span)
        searchRequest.naturalLanguageQuery = query
        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start(completionHandler: completionHandler)
    }
}

extension MapCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        CLLocation.driveTo(coordinate: annotation.coordinate)
    }
}

extension CLLocation {
    static func driveTo(coordinate: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ]
        MKMapItem.openMaps(with: [MKMapItem.forCurrentLocation(), MKMapItem(placemark: placemark)], launchOptions: launchOptions)
    }
}
