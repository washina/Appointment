//
//  MapViewController.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/04/25.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SVProgressHUD

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MapViewのアウトレット接続
    @IBOutlet weak var mapView: MKMapView!
    
    // 現在地、目的地の取得準備
    var userLocation: CLLocationCoordinate2D!
    var destinationLocation: CLLocationCoordinate2D!
    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MapViewのDelegateを設定
        mapView.delegate = self

        /* LocationManager関連の設定 --------------------------------------------------------------------------*/
        locationManager = CLLocationManager()                           // インスタンスの生成
        locationManager.delegate = self                                 // CLLocationManagerDelegateプロトコルを実装する
        locationManager.activityType = .fitness                         // 歩行者向けに設定
        locationManager.desiredAccuracy = kCLLocationAccuracyBest       // 最高精度に設定
        locationManager.distanceFilter = 100.0                          // 更新頻度（100メートルずつに更新する）
        /* LocationManager関連の設定 end------------------------------------------------------------------------*/

        
        
//        let uuid = NSUUID().uuidString
//        print("uuid:\(uuid)")
        
    }
    
    // AppointmentViewControllerへ画面遷移処理
    @IBAction func appointmentButton(_ sender: Any) {
        let appointmentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Appointment")
        self.present(appointmentViewController!, animated: true, completion: nil)
    }
    
    // TEST
    @IBAction func menuButton(_ sender: Any) {
        
        // 今までのピンを削除
        mapView.removeAnnotations(mapView.annotations)
        // 今までの経路を削除
        mapView.removeOverlays(mapView.overlays)
        
        // TEST: 目的地の座標を指定（テストとして東京駅の座標を目的地に設定）
        destinationLocation = CLLocationCoordinate2DMake(35.681298, 139.766247)
        
        // 現在地と目的地のMKPlacemarkを生成
        let fromPlacemark = MKPlacemark(coordinate:userLocation, addressDictionary:nil)
        let toPlacemark   = MKPlacemark(coordinate:destinationLocation, addressDictionary:nil)
        
        // MKPlacemarkからMKMapItemを生成
        let fromItem = MKMapItem(placemark:fromPlacemark)
        let toItem   = MKMapItem(placemark:toPlacemark)
        
        // MKMapItemをセットしてMKDirectionsRequestを生成
        let request: MKDirectionsRequest = MKDirectionsRequest()
        
        request.source = fromItem
        request.destination = toItem
        request.requestsAlternateRoutes = false // 単独の経路を検索
        request.transportType = MKDirectionsTransportType.any
        
        let directions = MKDirections(request:request)
        directions.calculate{ (response, error) in
            
            if (error != nil || response!.routes.isEmpty) {
                return
            }
            let route: MKRoute = response!.routes[0] as MKRoute
            
            // 経路を描画
            self.mapView.add(route.polyline)
            
        }
        
        // ピンを生成
        let fromPin: MKPointAnnotation = MKPointAnnotation()
        let toPin: MKPointAnnotation = MKPointAnnotation()
        
        // 座標をセット
        fromPin.coordinate = userLocation
        toPin.coordinate = destinationLocation
        
        // titleをセット
        fromPin.title = "出発地点"
        toPin.title = "目的地"
        
        // mapViewに追加
        mapView.addAnnotation(fromPin)
        mapView.addAnnotation(toPin)
        
    }
    
    // 経路表示設定
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("DEBUG_PRINT:mapView")
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.red
        polylineRenderer.lineWidth = 3.0
        return polylineRenderer
    }
    
    // appointmentViewControllerからbackButtonで戻ってくる処理
    @IBAction func backButton(_ segue:UIStoryboardSegue) {}


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension MapViewController: CLLocationManagerDelegate {
    
    /* 位置情報サービス使用確認処理 ---------------------------------------------------------------------------------*/
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("<DEBUG_PRINT>:ユーザーはこのアプリケーションに関してまだ選択を行っていません")
            // 起動中のみの取得許可を求める
            locationManager.requestWhenInUseAuthorization()
            break
        case .denied:
            print("<DEBUG_PRINT>:位置情報サービスの設定が「無効」になっています")
            // 「設定>プライバシー>位置情報サービス　で、位置情報サービスの利用を許可して下さい」を表示する。
            SVProgressHUD.showError(withStatus: "設定>プライバシー>位置情報サービス　で、位置情報サービスの利用を許可して下さい")
            break
        case .restricted:
            print("<DEBUG_PRINT>:このアプリケーションは位置情報サービスを使用出来ません")
            // 「このアプリは、位置情報を取得できないために正常に動作できません」を表示する。
            SVProgressHUD.showError(withStatus: "このアプリは、位置情報を取得できないために正常に動作できません")
            break
        case .authorizedAlways:
            print("<DEBUG_PRINT>:常時、位置情報の取得が許可されています")
            // 位置情報取得の開始処理
            locationManager.startUpdatingLocation()
            break
        case .authorizedWhenInUse:
            print("<DEBUG_PRINT>:起動時のみ、位置情報の取得が許可されています")
            // 位置情報取得の開始処理
            locationManager.startUpdatingLocation()
            break
        }
    }
    /* 位置情報サービス使用確認処理 end------------------------------------------------------------------------------*/
    
    /* 起動時、現在位置取得、マップ表示処理 ---------------------------------------------------------------------------------*/
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            print("<DEBUG_PRINT>緯度:\(location.coordinate.latitude)経度:\(location.coordinate.longitude)取得時刻:\(location.timestamp.description)")
            
            // 現在地の緯度経度をそれぞれ代入
            let lat: CLLocationDegrees = location.coordinate.latitude
            let lon: CLLocationDegrees = location.coordinate.longitude
            userLocation = CLLocationCoordinate2DMake(lat, lon)
            // 縮尺
            let latDist : CLLocationDistance = 1000
            let lonDist : CLLocationDistance = 1000
            // 表示領域を作成
            let region: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation, latDist, lonDist)
            // MapViewに反映
            mapView.setRegion(region, animated: true)
            
            
            /* 現在地にピンを表示 ----------------------------------------------------------------*/
            // ピンを生成
            let myPin: MKPointAnnotation = MKPointAnnotation()
            // 座標を設定
            myPin.coordinate = CLLocationCoordinate2DMake(lat, lon)
            // MapViewにピンを追加
            mapView.addAnnotation(myPin)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("<DEBUG_PRINT>位置情報の取得に失敗しました")
    }
    /* 起動時、現在位置取得、マップ表示処理 end------------------------------------------------------------------------------*/

}

