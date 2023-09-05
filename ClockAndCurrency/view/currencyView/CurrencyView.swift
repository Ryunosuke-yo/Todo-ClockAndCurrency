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
                
                HStack {
                    HStack {
                        Text("1 \(mainCurrency)")
                            .foregroundColor(.appGray)
                        Spacer()
                        Text("\(String(format: "%.2f", viewModel.currentRate)) \(secondCurrency)")
                            .foregroundColor(.appBlack)
                            .font(.system(size: 23))
                            .fontWeight(.bold)
                    }
                    .frame(width: Layout.width.rawValue)
                    .padding([.top], 20)
                }
                .frame(maxWidth: .infinity)
                BlueDivider()
                
                ScrollView {
                    // adjust scroll bar when keyboard is shown
                   
           
                    
                   
                    
                    renderCurrencyInput(currecny: mainCurrency, value: $mainCurrencyValue, currentValueFocus: .main)
                    BlueDivider()
                    Image(systemName: "arrow.up.arrow.down")
                        .resizable()
                        .frame(width: 20, height: 18)
                        .foregroundColor(.appGray)
                        .padding([.top])
                    renderCurrencyInput(currecny: secondCurrency, value: $secondCurrencyValue, currentValueFocus: .second)
                    BlueDivider()
                }
            }
        }
        .onAppear {
            if mainCurrency == "" || secondCurrency == "" || mainCurrencyValue == "" || secondCurrencyValue == "" {
                return
            }
            
            CurrencyAPIClinet.shared.getCurrentcyRate(from: mainCurrency, to: secondCurrency, onCallCompleted: { res in
                guard let firstKey = res.data.keys.first, let value = res.data[firstKey] else {
                    return
                }
                viewModel.currentRate = value
            }, onError: { afError in })
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    showKeyboard.toggle()
                    converCurrenyBasedOnSelectedValue()
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
            .onAppear {
                if viewModel.currencyList.count != 0 {
                    // prevent daily free limit on the currency list end point
                    return
                }
                viewModel.isLoading = .loading
                CurrencyAPIClinet.shared.getCurrencyList(onCallCompleted: {
                    res in
                    viewModel.currencyList = res.data
                    viewModel.isLoading = .completed
                }, onError: {
                    afError in
                    viewModel.isLoading = .error
                })
                
                
                
            }
            
        }
    }
    
    
    @ViewBuilder
    func renderCurrencyInput(currecny: String, value: Binding<String>, currentValueFocus: SelectedValue) -> some View {
        HStack {
            HStack {
                Text(currecny == "" ? "Select" : currecny)
                    .foregroundColor(.appBlack)
                    .font(.system(size: 23))
                    .fontWeight(.bold)
                    .padding(.leading, 10)
                
                Image(systemName: "chevron.down")
                    .resizable()
                    .frame(width: 15, height: 8)
                    .foregroundColor(.appGray)
                    .padding([.leading], 5)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if currentValueFocus == .main {
                    viewModel.selectedValue = .main
                } else {
                    viewModel.selectedValue = .second
                }
                viewModel.showCurrecnyListModal = true
            }
            
            Spacer()
            
            TextField("00000", text: value, onEditingChanged: {
                focused in
                if !focused {return}
                    
                if currentValueFocus == .main {
                    viewModel.selectedValue = .main
                } else {
                    viewModel.selectedValue = .second
                }
            } )
                .frame(width: 150)
                .foregroundColor(.appBlack)
                .font(.system(size: 23))
                .fontWeight(.bold)
                .keyboardType(.decimalPad)
                .focused($showKeyboard)
                .multilineTextAlignment(.trailing)
            
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
                                        onTapCurrecnyOnList(currency: currecny)
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
                                onTapCurrecnyOnList(currency: currecny)
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
    
    
    func onTapCurrecnyOnList(currency: String) -> Void {
        viewModel.showCurrecnyListModal = false
        if viewModel.selectedValue == .main {
            mainCurrency = currency
            if mainCurrency == "" || secondCurrency == "" || mainCurrencyValue == "" || secondCurrencyValue == "" {
                return
            }
            converCurrenyBasedOnSelectedValue()
        } else {
           
            secondCurrency = currency
            if mainCurrency == "" || secondCurrency == "" || mainCurrencyValue == "" || secondCurrencyValue == "" {
                return
            }
            converCurrenyBasedOnSelectedValue()
        }
        
        
         
    }
    
    func converCurrenyBasedOnSelectedValue ()-> Void {
        if viewModel.selectedValue == .main {
            guard let mainValueInDouble = Double(mainCurrencyValue) else {
                return
            }
            CurrencyAPIClinet.shared.getCurrentcyRate(from: mainCurrency, to: secondCurrency, onCallCompleted: { res in
                guard let firstKey = res.data.keys.first, let value = res.data[firstKey] else {
                    return
                }
                viewModel.currentRate = value
                let valueInDouble = CurrencyAPIClinet.shared.convertCurrency(amount: mainValueInDouble, rate: viewModel.currentRate)
                secondCurrencyValue = String(format: "%.2f", valueInDouble)
            }, onError: { afError in })

        } else {
            
            guard let secondValueInDouble = Double(secondCurrencyValue) else {
                return
            }
            CurrencyAPIClinet.shared.getCurrentcyRate(from: secondCurrency, to: mainCurrency, onCallCompleted: { res in
                guard let firstKey = res.data.keys.first, let value = res.data[firstKey] else {
                    return
                }
                viewModel.currentRate = value
                let valueInDouble = CurrencyAPIClinet.shared.convertCurrency(amount: secondValueInDouble, rate: viewModel.currentRate)
                mainCurrencyValue = String(format: "%.2f", valueInDouble)
            }, onError: { afError in })
            
         
        }
        
    }
    
}


//struct CurrencyView_Previews: PreviewProvider {
//    static var previews: some View {
//        CurrencyView()
//    }
//}
