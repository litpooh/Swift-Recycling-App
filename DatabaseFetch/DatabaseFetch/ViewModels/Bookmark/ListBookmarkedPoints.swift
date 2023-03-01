//
//  ListBookmarkedPoints.swift
//  DatabaseFetch
//
//  Created by hi on 11/4/2022.
//

import SwiftUI
import CoreLocation

struct ListBookmarkedPoints: View {
    @ObservedObject private var locationManager = LocationManager()
    
    var email:String = UserDefaults.standard.value(forKey: "email") as? String ?? ""
    var userlocation:CLLocationCoordinate2D {
        if locationManager.location != nil {
            return locationManager.location!.coordinate
        }
        else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
    }
    
    @StateObject var selected_legends = SelectedLegends(legends: Set(Types().legends_all))
    @StateObject var selected_accessibility_notes = SelectedAccessibilityNotes(accessibility_notes: Set(Types().accessibility_notes_all))

    @StateObject var original_points = OriginalCollectionPoints()
    @StateObject var filtered_points = FilteredCollectionPoints()
    @StateObject var result_points = ResultCollectionPoints()
    
    @StateObject var showFilter = ShowFilter()
    @StateObject var filterStatus = FilterStatus()
    
    @StateObject var selected_order = SelectedOrder(order: Types().orders[0])
    @StateObject var showOrder = ShowOrder()
    

    var body: some View {
        ZStack {
            List(result_points.points, id: \.cp_id) { point in
                NavigationLink(destination: MapAndPoint(userLocation: userlocation, point: point)
                    .environmentObject(result_points)){
                    CollectionPointRow(point: point)
                }
            }
            
            if showFilter.show == true {
                GeometryReader{ proxy in
                    
                    Color.primary
                        .opacity(0.15)
                        .ignoresSafeArea()
                    
                    let size = proxy.size
                    
                    Filter2_Separate(userLocation: userlocation)
                    .frame(width: size.width - 40, height: size.height/1.5, alignment: .center)
                    .cornerRadius(15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            
            if showOrder.show == true {
                GeometryReader{ proxy in
                    
                    Color.primary
                        .opacity(0.15)
                        .ignoresSafeArea()
                    
                    let size = proxy.size
                    
                    Order_Separate(userLocation: userlocation)
                    .frame(width: size.width - 40, height: size.height/1.5, alignment: .center)
                    .cornerRadius(15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .environmentObject(selected_legends)
        .environmentObject(selected_accessibility_notes)
        .environmentObject(original_points)
        .environmentObject(filtered_points)
        .environmentObject(result_points)
        .environmentObject(showFilter)
        .environmentObject(filterStatus)
        .environmentObject(selected_order)
        .environmentObject(showOrder)
        .navigationTitle("Bookmarked Points")
        .onAppear{
            if filterStatus.filtered == false {
                Database().listBookmarkedPoints(userLocation2D: userlocation, email: email) { points in
                    original_points.points = points
                    original_points.points = original_points.points.sorted{
                        $0.distance < $1.distance
                    }
                    
//                            var original_accepted_points:[CollectionPoint] = [CollectionPoint]()
//                            for point in original_points.points {
//                                if point.cp_state != "Closed" {
//                                    original_accepted_points.append(point)
//                                }
//                            }
//                            result_points.points = original_accpeted_points
                    
                    // 14-3-2022
                    // result_points.points = original_points.points -> checkopen()
                    var original_open_accepted_points:[CollectionPoint] = []
                    for point in original_points.points {
                        if checkOpen(date: Date(), point: point) == true {
                            original_open_accepted_points.append(point)
                        }
                    }
                    original_open_accepted_points = original_open_accepted_points.filter(){$0.cp_state != "Closed"}
                    result_points.points = original_open_accepted_points
                }
            }
            else {
                result_points.points = filtered_points.points
            }
        }
        .navigationBarItems(trailing: HStack {
                Button {
                    showFilter.show = true
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        Text("Filter")
                    }
                }
                .font(.system(size: 20))
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            
                Button {
                    showOrder.show = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Order")
                    }
                }
                .tint(.pink)
                .font(.system(size: 20))
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            }
        )
//        .onAppear{
//            Database().getPosts(waste_types: waste_types, userLocation2D: userlocation) { points in
//                result_points.points = points
//            }
//        }
        
    }
}

struct ListBookmarkedPoints_Previews: PreviewProvider {
    static var previews: some View {
        ListBookmarkedPoints()
    }
}
