//
//  ClockView.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-23.
//

import SwiftUI

struct ClockView: View {
    @StateObject var viewModel = ClockViewModel()
    @FetchRequest(sortDescriptors: []) var worldClocks: FetchedResults<WorldClock>
    @Environment(\.managedObjectContext) var moc
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
                    ZStack {
                        TimelineView(.everyMinute) { context in
                            if worldClocks.count != 0 {
                                List {
                                    ForEach(worldClocks, id: \.self) { worldClock in
                                        if let identifier = worldClock.identifier {
                                            renderDateComponnet(identifier: identifier)
                                                .listRowSeparator(.hidden)
                                                .listRowBackground(Color.appWhite)
                                        }

                                    }
                                    .onDelete(perform: deleteWorldClock)

                                }
                                .scrollContentBackground(.hidden)
                                .background(Color.appWhite)
                            }

                            Spacer()
                        }
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    viewModel.showWorldClockLList.toggle()
                                }) {
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
                        }
                    }
                } else if viewModel.segmentValue == 1 {
                    ScrollView {
                        renderResultDate(city: viewModel.mainCity, cityValueToDisplay: viewModel.mainCityDateTimeToDisplay)
                        renderResultDate(city: viewModel.secondCity, cityValueToDisplay: viewModel.secondCityDateTimeToDisplay)
                        
                        
                        DatePicker(selection: $viewModel.selectedDateAndTime, displayedComponents: [.date, .hourAndMinute]) {
                            Text("Date")
                                .foregroundColor(.appBlack)
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .tracking(0.5)
                                .padding(.leading, 10)
                        }
                        .frame(width: Layout.width.rawValue)
                        .tint(.accentColor)
                        .padding(.top, 30)
                        BlueDivider()
                        
                        renderCitySelector(city: viewModel.mainCity == "" ? "Select" : viewModel.getCityNamefromTimeZone(timeZoneIdentifiers: viewModel.mainCity)) {
                            viewModel.selectedCity = .main
                            viewModel.showCityListModal.toggle()
                        }
                        .padding(.top, 15)
                        
                        BlueDivider()
                        
                        Image(systemName: "arrow.down")
                            .resizable()
                            .frame(width: 15, height: 20)
                            .foregroundColor(.accentColor)
                            .padding(.vertical, 30)
                        renderCitySelector(city: viewModel.secondCity == "" ? "Select" : viewModel.getCityNamefromTimeZone(timeZoneIdentifiers: viewModel.secondCity)) {
                            viewModel.selectedCity = .second
                            viewModel.showCityListModal.toggle()
                        }
                        BlueDivider()
                        Button(action: {
                            if viewModel.mainCity == "" || viewModel.secondCity == "" {
                                return
                            }
                            viewModel.convertDateTime()
                        }) {
                            Text("Convert")
                                .font(.system(size: 15))
                                .foregroundColor(.appWhite)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.accentColor)
                                .cornerRadius(20)
                        }
                        .padding(.top, 20)
                    }
                   
                }
                
                
            }
        }
        .sheet(isPresented: $viewModel.showCityListModal) {
            VStack {
                BlueBar()
                switch viewModel.loadingState {
                case .completed:
                    renderCityList()
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .padding(.top, 20)
                case .error:
                    Text("Network error")
                }
                
                Spacer()
            }
            .presentationBackground(Color.appWhite)
            .onAppear {
                viewModel.citySearchValue = ""
                viewModel.loadingState = .loading
                TimeZoneApiClient().getAllTimeZone {
                    res in
                    viewModel.timeZoneList = res
                    viewModel.loadingState = .completed
                }
            }
            
            
        }
        .sheet(isPresented: $viewModel.showWorldClockLList) {
            VStack {
                BlueBar()
                renderWorldClockList()
                    .presentationBackground(Color.appWhite)
            }
            .onAppear {
                viewModel.citySearchValue = ""
            }
            
        }
        
        
    }
    
    
    
    @ViewBuilder
    func renderDateComponnet(identifier: String)-> some View {
        HStack {
            let gap = viewModel.getTimeGap(identifier: identifier, date: Date.now)
            let plusOrNot = gap ?? 0 > 0 ? "+" : ""
            VStack(alignment: .leading, spacing:0) {
                Text(viewModel.getCityNamefromTimeZone(timeZoneIdentifiers: identifier))
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                    .foregroundColor(.appBlack)
                Text("\(viewModel.getTodayOrTommorowOrYesterday(identifier: identifier, date: Date.now)), \(plusOrNot)\(gap ?? 0)hrs")
                    .foregroundColor(.appBlack)
                    .padding([.top], 5)
                
            }
            Spacer()
            Text(viewModel.getTimeWithTimeZone(identifier: identifier, date: Date.now))
                .font(.system(size: 35))
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
        }
        .frame(width: Layout.width.rawValue + 10)
    }
    
    @ViewBuilder
    func renderResultDate(city: String, cityValueToDisplay: String)-> some View {
        VStack (spacing:0){
            HStack {
                Text(cityValueToDisplay == "" ? "Select" : cityValueToDisplay)
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                    .padding(.top, 20)
                Spacer()
            }
            .padding(.leading, 35)
            
            HStack {
                Text(city == "" ? "Select" : viewModel.getCityNamefromTimeZone(timeZoneIdentifiers: city))
                Spacer()
                
            }
            .foregroundColor(.appBlack)
            .padding(.leading, 35)
            .padding(.top, 5)
            
        }
    }
    
    @ViewBuilder
    func renderCitySelector(city: String, onTap: @escaping ()-> Void)-> some View {
        HStack {
            Text("City")
                .foregroundColor(.appBlack)
                .font(.system(size: 20))
                .fontWeight(.bold)
                .tracking(0.5)
                .padding(.leading, 10)
            Spacer()
            HStack {
                Text(city == "" ? "Select" : city.replacingOccurrences(of: "_", with: " "))
                    .foregroundColor(.appBlack)
                    .font(.system(size: 20))
                    .fontWeight(.regular)
                    .tracking(0.5)
                    .padding(.leading, 10)
                Image(systemName: "chevron.down")
                    .resizable()
                    .frame(width: 15, height: 10)
                    .foregroundColor(.appGray)
                
                
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            
            
        }
        .frame(width: Layout.width.rawValue)
    }
    
    @ViewBuilder
    func renderCityList ()-> some View {
        SearchBar(text: $viewModel.citySearchValue)
        .frame(width: 300)
        .padding(.top, 10)
        
        List {
            ForEach(alphabet, id: \.self) { letter in
                Section(content: {
                    ForEach(viewModel.timeZoneList, id: \.self) { timezone in
                        let city = viewModel.getCityNamefromTimeZone(timeZoneIdentifiers: timezone)
                        if city != TimeZone.unknown , let fisrt = city.first, fisrt == letter.first {
                            if viewModel.citySearchValue == "" {
                                Button(action: {
                                    viewModel.onTapCity(value: timezone)
                                }) {
                                    Text(city)
                                        .foregroundColor(.appBlack)
                                        .font(Font.system(size: 17))
                                }
                            } else if city.lowercased().contains(viewModel.citySearchValue.lowercased()) {
                                Button(action: {
                                    viewModel.onTapCity(value: timezone)
                                }) {
                                    Text(city)
                                        .foregroundColor(.appBlack)
                                        .font(Font.system(size: 17))
                                }
                            }
                            
                        }
                    }
                    
                }, header: {
                    Text(letter)
                })
                
            }
            .listRowBackground(Color.appWhite)
        }
        .scrollContentBackground(.hidden)
        .background(Color.appWhite)
    }
    
    @ViewBuilder
    func renderWorldClockList()-> some View {
        SearchBar(text: $viewModel.citySearchValue)
        .frame(width: 300)
        .padding(.top, 10)
        List {
            ForEach(alphabet, id: \.self) { letter in
                Section(content: {
                    ForEach(TimeZone.allTimeZonesIdentifiers, id: \.self) { timezone in
                        let city = viewModel.getCityNamefromTimeZone(timeZoneIdentifiers: timezone)
                        if let fisrt = city.first, fisrt == letter.first {
                            if viewModel.citySearchValue == "" {
                                Button(action: {
                                    onTapCityonWorldClockLits(value: timezone)
                                }) {
                                    Text(city)
                                        .foregroundColor(.appBlack)
                                        .font(Font.system(size: 17))
                                }
                            } else if city.lowercased().contains(viewModel.citySearchValue.lowercased()) {
                                Button(action: {
                                    onTapCityonWorldClockLits(value: timezone)
                                }) {
                                    Text(city)
                                        .foregroundColor(.appBlack)
                                        .font(Font.system(size: 17))
                                }
                            }
                            
                        }
                        
                    }
                }, header: {
                    Text(letter)
                })
            }
            .listRowBackground(Color.appWhite)
        }
        .scrollContentBackground(.hidden)
        .background(Color.appWhite)
    }
    
    
    func onTapCityonWorldClockLits(value: String)-> Void {
        let newWorldClock = WorldClock(context: moc)
        newWorldClock.identifier = value
        newWorldClock.id = UUID()
        
        PersistenceController.shared.save()
        viewModel.showWorldClockLList.toggle()
        
    }
    
    func deleteWorldClock(indexSet: IndexSet)-> Void {
        for index in indexSet {
            let clockToDelete = worldClocks[index]
            moc.delete(clockToDelete)
        }
        
        PersistenceController.shared.save()
        
        
    }
    
    
}



enum SelectedCity {
    case main,
         second
}

//struct ClockView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClockView()
//    }
//}
