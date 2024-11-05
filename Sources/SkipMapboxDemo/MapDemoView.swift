//
//  MapDemoView.swift
//  
//
//  Created by John Bent on 8/31/24.
//
import SwiftUI
#if SKIP
import SkipMapbox
#else
import MapboxMaps
#endif

struct MapDemoView: View {
    @State var viewport: Viewport = .styleDefault
    @State var mapStyle: MapStyle = .standard
    #if !SKIP
    @State var locationManager = LocationManager()
    #endif
    
    enum Locations {
        static let atlanta = CLLocationCoordinate2D(latitude: 33.748997, longitude: -84.387985)
        static let charleston = CLLocationCoordinate2D(latitude: 32.789528108068495, longitude: -79.93884745607413)
        static let southHero = CLLocationCoordinate2D(latitude: 44.64299581179382, longitude: -73.30193120704725)
        static let coloradoSprings = CLLocationCoordinate2D(latitude: 38.84344214940719, longitude: -104.81534354960375)
        static let stThomas = CLLocationCoordinate2D(latitude: 18.345171123798032, longitude: -64.93117095355794)
    }
    
    let markerColor = Color(red: 0, green: 0, blue: 1)
    
    var body: some View {
        Map(viewport: $viewport) {
            Puck2D(bearing: .course)
            
//            CircleAnnotation(centerCoordinate: Locations.atlanta)
//                .circleColor(StyleColor(red: 0, green: 0, blue: 255)!)
//                .circleStrokeColor(StyleColor(red: 255, green: 255, blue: 255)!)
//                .circleStrokeWidth(2)
//                .circleRadius(8)
            PointAnnotation(coordinate: Locations.atlanta)
            #if !SKIP
                .image(
                    .init(
                        image: .init(
                            named: "MapPin",
                            in: .module,
                            with: nil
                        ) ?? .init(),
                        name: "MapPin"
                    )
                )
            #else
                .image(
                    .init(
                        name: "MapPin",
                        in: .module
                    )
                )
            #endif
            CircleAnnotation(centerCoordinate: Locations.charleston)
                .circleColor(StyleColor(red: 0, green: 255, blue: 0)!)
                .circleStrokeColor(StyleColor(red: 255, green: 255, blue: 255)!)
                .circleStrokeWidth(2)
                .circleRadius(8)
            
            CircleAnnotation(centerCoordinate: Locations.southHero)
                .circleColor(StyleColor(red: 255, green: 0, blue: 0)!)
                .circleStrokeColor(StyleColor(red: 255, green: 255, blue: 255)!)
                .circleStrokeWidth(2)
                .circleRadius(8)
        }
        .mapStyle(mapStyle)
        .task {
            #if !SKIP
            try? await locationManager.requestUserAuthorization()
            #else
            let activity = UIApplication.shared.androidActivity!
            // These must match permissions in your AndroidManifest
            let permissions = listOf(android.Manifest.permission.ACCESS_COARSE_LOCATION,
                android.Manifest.permission.ACCESS_FINE_LOCATION)
            androidx.core.app.ActivityCompat.requestPermissions(activity, permissions.toTypedArray(), 1)
            #endif
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            await withViewportAnimation(
                .default,
                updatedViewport: .camera(center: Locations.atlanta, zoom: 10)
            )
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await withViewportAnimation(
                .easeInOut(duration: 4),
                updatedViewport: .camera(center: Locations.charleston, zoom: 12)
            )
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await withViewportAnimation(
                .fly(duration: 2),
                updatedViewport: .camera(center: Locations.southHero, zoom: 14, bearing: -90, pitch: 30.0)
            )
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            setViewportImmediately(.camera(center: Locations.stThomas, zoom: 14, bearing: 0, pitch: 0))
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await withViewportAnimation(
                .default(maxDuration: 1),
                updatedViewport: .followPuck(zoom: 11.0, bearing: .heading, pitch: 40)
            )
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            mapStyle = .satellite
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            mapStyle = .dark
        }
    }
    
    func setViewportImmediately(_ updatedViewport: Viewport) {
        #if SKIP
        self.viewport.withImmediateTransition(updatedViewport: updatedViewport)
        #else
        self.viewport = updatedViewport
        #endif
    }
    
    func withViewportAnimation(animation: ViewportAnimation = .default, updatedViewport: Viewport, completion: ((Bool) -> Void)? = nil) {
        #if SKIP
        self.viewport.withViewportAnimation(animation: animation, updatedViewport: updatedViewport, completion: completion)
        #else
        MapboxMaps.withViewportAnimation(
            animation,
            body: {
                self.viewport = updatedViewport
            },
            completion: completion
        )
        #endif
    }
    
    @discardableResult
    func withViewportAnimation(_ animation: ViewportAnimation = .default, updatedViewport: Viewport) async -> Bool {
        return await withCheckedContinuation { continuation in
            self.withViewportAnimation(animation: animation, updatedViewport: updatedViewport) { isFinished in
                continuation.resume(returning: isFinished)
            }
        }
    }
}

#Preview {
    MapDemoView()
}
