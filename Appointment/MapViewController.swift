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
import Firebase
import SVProgressHUD
import SlideMenuControllerSwift

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var appointmentButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var postData: PostData!
        
    // 現在地、目的地の取得準備
    var userLocation: CLLocationCoordinate2D!
    var destinationLocation: CLLocationCoordinate2D!
    var locationManager: CLLocationManager!
    
    // locationの値を取得
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // rgb変換メソッド
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // 戻る際の処理
    @IBAction func unwind(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 各ボタンの背景色設定
        self.appointmentButton.backgroundColor = UIColorFromRGB(rgbValue: 0x40e0de)
        self.favoriteButton.backgroundColor = UIColorFromRGB(rgbValue: 0x40e0de)
        
        // MapViewのDelegateを設定
        mapView.delegate = self
        
        // 現在地をマップ中心部に、現在地にカーソルを表示
        mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        
        /* SlideMenuControllerSwift設定 ----------------------------------------------------------------------*/
        navigationController?.navigationBar.isTranslucent = false                                   // バーを半透明にするか
        navigationController?.navigationBar.barTintColor = UIColorFromRGB(rgbValue: 0x40e0d0)       // バーの背景色
        navigationController?.navigationBar.tintColor = UIColorFromRGB(rgbValue: 0xffffff)          // アイコンの色
        addRightBarButtonWithImage(UIImage(named: "menuIcon")!)                                     // アイコンの画像
        /* SlideViewControllerSwift設定 end-------------------------------------------------------------------*/

        /* LocationManager関連の設定 --------------------------------------------------------------------------*/
        locationManager = CLLocationManager()                           // インスタンスの生成
        locationManager.delegate = self                                 // CLLocationManagerDelegateプロトコルを実装する
        locationManager.activityType = .fitness                         // 歩行者向けに設定
        locationManager.desiredAccuracy = kCLLocationAccuracyBest       // 最高精度に設定
        locationManager.distanceFilter = 100.0                          // 更新頻度（100メートルずつに更新する）
        /* LocationManager関連の設定 end-----------------------------------------------------------------------*/

        if (appDelegate.delegateLocation.delegateAddress != "") {
            appointmentSearch()
        }
    }

    /* 経路検索、表示処理 ----------------------------------------------------------------------------------------*/
    func appointmentSearch() {
        
        // 今までのピンを削除
        mapView.removeAnnotations(mapView.annotations)
        // 今までの経路を削除
        mapView.removeOverlays(mapView.overlays)
        
        // 位置情報読み取り処理
        let friendRef = Database.database().reference().child("users").child(appDelegate.delegateLocation.delegateAddress)
        friendRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshotDictionary = snapshot.value as? [String:AnyObject]{
                // データベース上の値を格納
                let latitude = snapshotDictionary["latitude"] as! Double
                let longitude = snapshotDictionary["longitude"] as! Double
                
                // 現在地の緯度経度をそれぞれ代入
                let lat: CLLocationDegrees = self.appDelegate.delegateLocation.delegateLatitude
                let lon: CLLocationDegrees = self.appDelegate.delegateLocation.delegateLongitude
                self.userLocation = CLLocationCoordinate2DMake(lat, lon)
                
                // 目的地の座標を指定
                self.destinationLocation = CLLocationCoordinate2DMake(latitude, longitude)
                        
                // 現在地と目的地のMKPlacemarkを生成
                let fromPlacemark = MKPlacemark(coordinate:self.userLocation, addressDictionary:nil)
                let toPlacemark   = MKPlacemark(coordinate:self.destinationLocation, addressDictionary:nil)
                        
                // MKPlacemarkからMKMapItemを生成
                let fromItem = MKMapItem(placemark:fromPlacemark)
                let toItem   = MKMapItem(placemark:toPlacemark)
                        
                // MKMapItemをセットしてMKDirectionsRequestを生成
                let request: MKDirectionsRequest = MKDirectionsRequest()
                        
                request.source = fromItem
                request.destination = toItem
                request.requestsAlternateRoutes = false     // 単独の経路を検索
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
                let toPin: MKPointAnnotation = MKPointAnnotation()
                // 座標をセット
                toPin.coordinate = self.destinationLocation
                // titleをセット
                toPin.title = "目的地"
                // mapViewに追加
                self.mapView.addAnnotation(toPin)
            }
        })
    }
    
    // 経路表示設定
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.red
        polylineRenderer.lineWidth = 3.0
        return polylineRenderer
    }
    /* 経路検索、表示処理 end-------------------------------------------------------------------------------------*/
    
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
            // 今までのピンを削除
            mapView.removeAnnotations(mapView.annotations)
            
            // time
            let time = NSDate.timeIntervalSinceReferenceDate
            
            // 辞書を作成してFirebaseに保存する
            var postId = Auth.auth().currentUser?.email
            
            // .（ドット）を検索して,（カンマ）に置換
            postId = postId?.replacingOccurrences(of: ".", with: ",")
            let postRef = Database.database().reference().child("users").child(postId!)
            let postData = [
                "time": String(time),
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ] as [String : Any]
            postRef.updateChildValues(postData)
            
            // appDelegateに値をセット
            appDelegate.delegateLocation = (
                delegateAddress: "\(appDelegate.delegateLocation.delegateAddress)",
                delegateLatitude: location.coordinate.latitude,
                delegateLongitude: location.coordinate.longitude
            )
            
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
            
            // 現在地が変わったら自動的に経路を再検索する
            if(appDelegate.delegateLocation.delegateAddress != "") {
                appointmentSearch()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("<DEBUG_PRINT>位置情報の取得に失敗しました")
    }
    /* 起動時、現在位置取得、マップ表示処理 end------------------------------------------------------------------------------*/
}

