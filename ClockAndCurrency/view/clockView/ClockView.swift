//
//  ClockView.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-23.
//

import SwiftUI

struct ClockView: View {
    @StateObject var viewModel = ClockViewModel()
    var body: some View {
        ZStack {
            Color.appWhite.ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Clock")
                        .fontWeight(.bold)
                        .tracking(1)
                        .font(.system(size: 20))
                        .foregroundColor(.appBlack)
                    Spacer()
                }
                .frame(width: Layout.width.rawValue)
                .padding([.top])
                
                Picker("", selection: $viewModel.segmentValue) {
                    Text("Clock").tag(0)
                    Text("Convert").tag(1)
                }
                .pickerStyle(.segmented)
                .frame(width: Layout.width.rawValue + 10)
                
                
                if viewModel.segmentValue == 0 {
                    List {
                        renderDateComponnet()
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.appWhite)
                        renderDateComponnet()
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.appWhite)
                        renderDateComponnet()
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.appWhite)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.appWhite)
                    
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(16)
                                .background(Color.accentColor)
                                .foregroundColor(.appWhite)
                                .clipShape(Circle())
                                
                        }
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, 60)
                    
                    
                   
                } else if viewModel.segmentValue == 1 {
                    renderResultDate()
                    renderResultDate()
                    Spacer()
                    
                }
            }
        }
    }
    
    @ViewBuilder
    func renderDateComponnet()-> some View {
        HStack {
            VStack(spacing:0) {
                Text("London")
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                    .foregroundColor(.appBlack)
                Text("Today, +2hrs")
                    .foregroundColor(.appBlack)
                    .padding([.top], 5)
                
            }
            Spacer()
            Text("12:00 AM")
                .font(.system(size: 35))
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
        }
        .frame(width: Layout.width.rawValue + 10)
    }
    
    @ViewBuilder
    func renderResultDate()-> some View {
        VStack (spacing:0){
            Text("4:00 PM, 12, Aug, 2022")
                .font(.system(size: 30))
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
                .padding(.top, 20)
            
            HStack {
                Text("Osaka")
                Spacer()
                    
            }
            .foregroundColor(.appBlack)
            .padding(.leading, 35)
            .padding(.top, 5)
            
        }
    }
}

struct ClockView_Previews: PreviewProvider {
    static var previews: some View {
        ClockView()
    }
}
