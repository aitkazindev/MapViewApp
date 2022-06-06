//
//  ViewController.swift
//  MapViewApp
//
//  Created by Ibrahim Aitkazin on 03.06.2022.
//
import MapKit
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var userLocation = CLLocation()
    
    var showMe: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        
        let lat:CLLocationDegrees = 37.957666
        let long:CLLocationDegrees = -122.0323133
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)
        
        
        //annotation
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = location
        
        annotation.title = "Title"
        annotation.subtitle = "Subtitle"
        mapView.addAnnotation(annotation)
        
        
        
        //setRegion
        let latDelta: CLLocationDegrees = 0.01
        let longDelta: CLLocationDegrees = 0.01
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        
        //UIPanGestureRecognition
        let mapDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap))
        mapDragRecognizer.delegate = self
        mapView.addGestureRecognizer(mapDragRecognizer)
        
        //UILongPressGestureRecognizer
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressAction))
        uilpgr.minimumPressDuration = 2
        mapView.addGestureRecognizer(uilpgr)
        
    }

    @IBAction func showMyLocation(_ sender: Any) {
        showMe = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        
        if showMe{
            let latDelta: CLLocationDegrees = 0.01
            let longDelta: CLLocationDegrees = 0.01
            
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    @objc func didDragMap(gestureRecognizer: UIPanGestureRecognizer){
        if (gestureRecognizer.state == UIGestureRecognizer.State.began){
            showMe = false
            print("Map drag begun")
        }
        
        if (gestureRecognizer.state == UIGestureRecognizer.State.ended){
            print("Map  drag ended")
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print(view.annotation?.title)
        
        let location:CLLocation = CLLocation(latitude: (view.annotation?.coordinate.latitude)!, longitude:  (view.annotation?.coordinate.longitude)!)
        
        let meters:CLLocationDistance = location.distance(from: userLocation)
        distanceLabel.text = String(format: "Distance: %.2f m", meters)
        
        // Roating
        //1
        let sourceLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        let destinationLocation = CLLocationCoordinate2D(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)

        //2
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        //3
        
        let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationMapItem = MKMapItem(placemark: destinationPlaceMark)
        
        //4
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        //Calc the direction
        
        let directions = MKDirections(request: directionRequest)
        
        //5
        directions.calculate{
            (response,error) -> Void in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                    return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay((route.polyline),level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
               
        }
        
        
        
           
        
    }
    func mapView(_ mapView: MKMapView, rendererFor overplay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overplay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer  
    }

    @objc func longPressAction(gestureRecognizer: UIGestureRecognizer){
        print("getsureRecognizer")
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        
        let newCoor: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        // annotation
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoor
        
        annotation.title = "Title"
        annotation.subtitle = "subtitle"
        
        mapView.addAnnotation(annotation)
    }
}

