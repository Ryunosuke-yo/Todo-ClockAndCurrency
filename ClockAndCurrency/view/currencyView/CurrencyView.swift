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
    @State var value = ""
    
    let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
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
                    HStack {
                        Text("1 JPY")
                            .foregroundColor(.appGray)
                        Spacer()
                        Text("100 CAD")
                            .foregroundColor(.appBlack)
                            .font(.system(size: 23))
                            .fontWeight(.bold)
                    }
                    .frame(width: Layout.width.rawValue)
                    .padding([.top], 20)
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
                    
                    renderCurrencyInput()
                    BlueDivider()
                    Image(systemName: "arrow.up.arrow.down")
                        .resizable()
                        .frame(width: 20, height: 18)
                        .foregroundColor(.appGray)
                        .padding([.top])
                    renderCurrencyInput()
                    BlueDivider()
                }
            }
        }
        .sheet(isPresented: $viewModel.showCurrecnyListModal) {
            ZStack {
                Color.appWhite.ignoresSafeArea()
                VStack {
                    Capsule()
                        .foregroundColor(.accentColor)
                        .frame(width: 70, height: 6)
                        .padding(.top, 20)
                    
                    
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
            .task {
                do {
                    viewModel.isLoading = .loading
                    let list = try await CurrencyAPIClinet.shared.getCurrencyList()
                    viewModel.currencyList = list.symbols
                    viewModel.isLoading = .completed
                    
                } catch CurrecnyAPIError.invalidUrl {
                    print("invalid url")
                    viewModel.isLoading = .error
                } catch CurrecnyAPIError.decodeError {
                    print("decode")
                    viewModel.isLoading = .error
                } catch CurrecnyAPIError.invalidResponse {
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
    func renderCurrencyInput()-> some View {
        HStack {
            HStack {
                Text("JPY")
                    .foregroundColor(.appBlack)
                    .font(.system(size: 23))
                    .fontWeight(.bold)
                
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
            TextField("0000", text: $value)
                .frame(width: 150)
                .foregroundColor(.appBlack)
                .font(.system(size: 23))
                .fontWeight(.bold)
        }
        .frame(width: Layout.width.rawValue)
        .padding([.top], 20)
    }
    
    @ViewBuilder
    func renderCurrencyList()-> some View {
            HStack {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.accentColor)
                
                TextField("", text: $value)
                    .padding([.vertical], 10)
                    .padding([.horizontal], 5)
                
            }
            .padding([.horizontal], 10)
            .background(Color.lightGray)
            .clipShape(Capsule())
            .frame(width: 300)
            .padding(.top, 10)
            
            
            List {
                ForEach(alphabet, id: \.self) { letter in
                    Section(content: {
                        Text("c")
                        
                    }, header: {
                        Text(letter)
                    })
                    
                }
                .listRowBackground(Color.appWhite)
            }
            .scrollContentBackground(.hidden)
            .background(Color.appWhite)
        }
    }


struct CurrencyView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyView()
    }
}
