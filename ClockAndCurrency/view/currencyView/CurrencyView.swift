//
//  CurrencyView.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-23.
//

import SwiftUI
import Charts

struct dummyData: Identifiable {
    var currencyValue:Double
    var day: Int
    var id = UUID()
}

struct CurrencyView: View {
    @StateObject var viewModel = CurrencyViewModel()
    @FocusState var showKeyboard: Bool
    @Environment(\.managedObjectContext) var managedObjectContext
    @AppStorage("mainCurrecny") private var mainCurrency = ""
    @AppStorage("secondCurrecny") private var secondCurrency = ""
    @AppStorage("mainCurrecnyValue") private var mainCurrencyValue = ""
    @AppStorage("secondCurrecnyValue") private var secondCurrencyValue = ""
    
    
 
    
    let data = [
        dummyData(currencyValue: 2.3, day: 1),
        dummyData(currencyValue: 5.4444444, day: 2),
        dummyData(currencyValue: 1, day: 3),
        dummyData(currencyValue: 1, day: 4),
        dummyData(currencyValue: 2, day: 5),
        dummyData(currencyValue: 5, day: 6),
        dummyData(currencyValue: 1, day: 7),
        dummyData(currencyValue: 1, day: 8),
    ]
    var body: some View {
        ZStack {
            Color.appWhite.ignoresSafeArea()
            VStack {
                HStack {
                    Text("Currency")
                        .fontWeight(.bold)
                        .tracking(1)
                        .font(.system(size: 20))
                        .foregroundColor(.appBlack)
                    Spacer()
                }
                .frame(width: Layout.width.rawValue)
                .padding([.top], 10)
                
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(height: 1)
                ScrollView {
                    // adjust scroll bar when keyboard is shown
                    HStack {
                        HStack {
                            Text("1 \(mainCurrency)")
                                .foregroundColor(.appGray)
                            Spacer()
                            Text("100 \(secondCurrency)")
                                .foregroundColor(.appBlack)
                                .font(.system(size: 23))
                                .fontWeight(.bold)
                        }
                        .frame(width: Layout.width.rawValue)
                        .padding([.top], 20)
                    }
                    .frame(maxWidth: .infinity)
                    BlueDivider()
                    
                    Chart {
                        ForEach(data) { data in
                            LineMark(x: .value("day", data.day), y: .value("day", data.currencyValue))
                                .foregroundStyle(Color.accentColor.gradient)
                            
                        }
                        
                    }
                    .frame(width: Layout.width.rawValue, height: 300)
                    .padding([.vertical], 30)
                    .chartPlotStyle {
                        content in
                        content
                            .background(Color.appWhite)
                        
                    }
                    .chartYScale(domain: [0, 10])
                    .chartXAxis {
                        AxisMarks()
                    }
                    .chartYAxis {
                        AxisMarks()
                    }
                    
                    renderCurrencyInput(currecny: mainCurrency, value: $mainCurrencyValue) {
                        viewModel.selectedValue = .main
                        viewModel.showCurrecnyListModal = true
                    }
                    BlueDivider()
                    Image(systemName: "arrow.up.arrow.down")
                        .resizable()
                        .frame(width: 20, height: 18)
                        .foregroundColor(.appGray)
                        .padding([.top])
                    renderCurrencyInput(currecny: secondCurrency, value: $secondCurrencyValue) {
                        viewModel.selectedValue = .second
                        viewModel.showCurrecnyListModal = true
                    }
                    BlueDivider()
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    showKeyboard.toggle()
                }
            }
            
        }
        .sheet(isPresented: $viewModel.showCurrecnyListModal) {
            ZStack {
                Color.appWhite.ignoresSafeArea()
                VStack {
                    BlueBar()
                    
                    
                    switch viewModel.isLoading {
                    case .loading:
                        ProgressView()
                            .tint(.accentColor)
                            .padding(.top, 10)
                        Spacer()
                    case .error:
                        Text("Network error happened")
                            .font(.system(size: 20))
                            .foregroundColor(.accentColor)
                            .tracking(0.5)
                            .padding(.top, 10)
                        Spacer()
                        
                    case .completed:
                        renderCurrencyList()
                    }
                }
                
            }
            .onDisappear {
                viewModel.currecnySearchValue = ""
            }
            .task {
                do {
                    viewModel.isLoading = .loading
                    let list = try await CurrencyAPIClinet.shared.getCurrencyList()
                    viewModel.currencyList = list.symbols
                    viewModel.isLoading = .completed
                    
                } catch APIError.invalidUrl {
                    print("invalid url")
                    viewModel.isLoading = .error
                } catch APIError.decodeError {
                    print("decode")
                    viewModel.isLoading = .error
                } catch APIError.invalidResponse {
                    print("respnse")
                    viewModel.isLoading = .error
                } catch {
                    print("unexpexted")
                    viewModel.isLoading = .error
                }
                
            }
            
        }
    }
    
    
    @ViewBuilder
    func renderCurrencyInput(currecny: String, value: Binding<String>, onTapCurrecny: @escaping ()-> Void)-> some View {
        HStack {
            HStack {
                Text(currecny == "" ? "Select" : currecny)
                    .foregroundColor(.appBlack)
                    .font(.system(size: 23))
                    .fontWeight(.bold)
                    .onTapGesture {
                        onTapCurrecny()
                    }
                    .padding(.leading, 10)
                
                Image(systemName: "chevron.down")
                    .resizable()
                    .frame(width: 15, height: 8)
                    .foregroundColor(.appGray)
                    .padding([.leading], 5)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.showCurrecnyListModal = true
            }
            
            Spacer()
            
           
                Text("$")
                    .foregroundColor(.appGray)
                    .font(.system(size: 23))
                    .fontWeight(.bold)
                
                TextField("00000", text: value)
                    .frame(width: 100)
                    .foregroundColor(.appBlack)
                    .font(.system(size: 23))
                    .fontWeight(.bold)
                    .keyboardType(.decimalPad)
                    .focused($showKeyboard)
            
        }
        .frame(width: Layout.width.rawValue)
        .padding([.top, ], 20)
    }
    
    @ViewBuilder
    func renderCurrencyList()-> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.accentColor)
            
            TextField("", text: $viewModel.currecnySearchValue)
                .padding([.vertical], 10)
                .padding([.horizontal], 5)
            
        }
        .padding([.horizontal], 10)
        .background(Color.lightGray)
        .clipShape(Capsule())
        .frame(width: 300)
        .padding(.top, 10)
        
        
        
        if viewModel.currecnySearchValue == "" {
            List {
                ForEach(alphabet, id: \.self) { letter in
                    Section(content: {
                        ForEach(Array(viewModel.currencyList.keys), id: \.self) { currecny in
                            if let fisrt = currecny.first, fisrt == letter.first {
                                Button(action: {
                                    Task {
                                        try await onTapCurrecnyOnList(currency: currecny)
                                    }
                                }) {
                                    Text(currecny)
                                        .foregroundColor(.appBlack)
                                        .font(Font.system(size: 17))
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
        } else if viewModel.doesListInclude(viewModel.currecnySearchValue.uppercased())  {
            List {
                Section(content: {
                    ForEach(Array(viewModel.currencyList.keys), id: \.self) { currecny in
                        if currecny.contains(viewModel.currecnySearchValue.uppercased()) {
                            Button(action: {
                                Task {
                                    try await onTapCurrecnyOnList(currency: currecny)
                                    
                                }
                                
                                
                            }) {
                                Text(currecny)
                                    .foregroundColor(.appBlack)
                                    .font(Font.system(size: 17))
                            }
                        }
                        
                    }
                    .listRowBackground(Color.appWhite)
                    
                }
                )
            }
        }
        
        Spacer()
        
    }
    
    
    func onTapCurrecnyOnList(currency: String) async throws -> Void {
        if viewModel.selectedValue == .main {
            mainCurrency = currency
        } else {
            secondCurrency = currency
        }
        viewModel.showCurrecnyListModal = false
        let res = try await CurrencyAPIClinet.shared.getLatestRate(base: mainCurrency, symbols: [secondCurrency])
     
    }
}


//struct CurrencyView_Previews: PreviewProvider {
//    static var previews: some View {
//        CurrencyView()
//    }
//}
