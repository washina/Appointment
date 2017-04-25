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
    
    @IBOutlet weak var mapView: MKMapView!
    //var mapView: MKMapView!
    var coordinate: CLLocationCoordinate2D!
    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        // インスタンスの生成
        locationManager = CLLocationManager()
        // CLLocationManagerDelegateプロトコルを実装する
        locationManager.delegate = self
        // 歩行者向けに設定
        locationManager.activityType = .fitness
        // 最高精度に設定
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 更新頻度（100メートルずつに更新する）
        locationManager.distanceFilter = 100.0
        
        
//        let uuid = NSUUID().uuidString
//        print("uuid:\(uuid)")
        
    }
    
    // AppointmentViewControllerへ画面遷移
    @IBAction func appointmentButton(_ sender: Any) {
        let appointmentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Appointment")
        self.present(appointmentViewController!, animated: true, completion: nil)
    }
    
    @IBAction func menuButton(_ sender: Any) {
    }

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
            print("<DEBUG_PRINT>:ロケーションサービスの設定が「無効」になっています")
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
    
    /* 現在位置取得、マップ表示処理 ---------------------------------------------------------------------------------*/
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            print("<DEBUG_PRINT>緯度:\(location.coordinate.latitude)経度:\(location.coordinate.longitude)取得時刻:\(location.timestamp.description)")
        
        // 中心点の緯度経度
        let lat: CLLocationDegrees = location.coordinate.latitude
        let lon: CLLocationDegrees = location.coordinate.longitude
        coordinate = CLLocationCoordinate2DMake(lat, lon)
        
        // 縮尺
        let latDist : CLLocationDistance = 1000
        let lonDist : CLLocationDistance = 1000
        
        // 表示領域を作成
        let region: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, latDist, lonDist)
        
        // MapViewに反映
        mapView.setRegion(region, animated: true)
        
        
        /* 現在地にピンを表示 ----------------------------------------------------------------*/
        // ピンを生成
        let myPin: MKPointAnnotation = MKPointAnnotation()
        // 中心点を設定
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lon)
        // 座標を設定
        myPin.coordinate = center
        // タイトルを設定
        myPin.title = "Im Here."
        // サブタイトルを設定
        myPin.subtitle = "ココ"
        // MapViewにピンを追加
        mapView.addAnnotation(myPin)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("<DEBUG_PRINT>位置情報の取得に失敗しました")
    }
    /* 現在位置取得、マップ表示処理 end------------------------------------------------------------------------------*/

}

