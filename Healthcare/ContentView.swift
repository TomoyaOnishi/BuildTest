//
//  ContentView.swift
//  Healthcare
//
//  Created by Shin on 2021/05/16.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var vm: ContentViewModel

    var body: some View {

        if self.vm.binding.isfirstOpen {
            OnboardingView( vm: vm)

        } else {
        TabView {
            NavigationView {
                DataListView(vm: DataListViewModel())
                   .navigationBarTitle(Text("血圧・体重"))
            }.tabItem {
                VStack {
                    Image(systemName: "heart.text.square")
                    Text("血圧・体重")
                }
            }.tag(0)
            NavigationView {
                TraningTopView()
                   .navigationBarTitle(Text("リハビリ"))
            }.tabItem {
                VStack {
                    Image(systemName: "figure.walk")
                    Text("リハビリ")
                }
            }.tag(1)
//            NavigationView {
//                TelenursingView()
//                   .navigationBarTitle(Text("テレナーシング"))
//            }.tabItem {
//                VStack {
//                    Image(systemName: "video.circle.fill")
//                    Text("テレナーシング")
//                }
//            }.tag(2)
            NavigationView {
                TraningTopView()
                   .navigationBarTitle(Text("マイページ"))
            }.tabItem {
                VStack {
                    Image(systemName: "person.fill")
                    Text("マイページ")
                }
            }.tag(3)
        }

        }

//        .fullScreenCover(isPresented: self.vm.$binding.isfirstOpen) {
//            OnboardingView()
//        }.animation(nil)

    }
}
