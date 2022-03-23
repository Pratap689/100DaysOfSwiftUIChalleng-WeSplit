//
//  ContentView.swift
//  WeSplit
//
//  Created by netset on 16/02/22.
//

import SwiftUI

struct ContentView: View {
    enum Units: String {
        case Meter, KM, Miles, Yards, Feets, none
    }
    var unitsArr: [Units] = [Units.Meter, Units.KM, Units.Miles, Units.Yards, Units.Feets]
    @State var selectedInputUnit: Units = .KM
    @State var selectedOutputUnit: Units = .Feets
    @State var selectedInputValue: String = ""
    @State var selectedOutputValue: String = "0"
    @State var showAlert: Bool = false
    @State var previousVal: Units = .none
    @State var previousOutVal: Units = .none
    @FocusState var isKeyboadVisible: Bool
    @ObservedObject var model: AlertsProperties = AlertsProperties()
    
    var body: some View {
        VStack {
            Form {
                Section("Select Input Unit") {
                    VStack {
                        Picker("", selection: $selectedInputUnit) {
                            ForEach(unitsArr, id: \.self) { units in
                                Text(units.rawValue)
                                    .font(.system(size: 20, weight: .bold, design: .default))
                            }
                        }.onAppear(perform: {
                            previousVal = selectedInputUnit
                        })
                            .onChange(of: selectedInputUnit, perform: { newValue in
                                if selectedInputUnit == selectedOutputUnit {
                                    model.isValid = true
                                } else {
                                    previousVal = selectedInputUnit
                                    model.isValid = false
                                }
                                print("bbbb\(previousVal)", selectedInputUnit)
                            })
                            .alert(isPresented: $model.isValid, content: {
                                LoadAlertView.bodyWithAction(message: "Input and Output Unit Can't Be Same") {
                                    model.isValid.toggle()
                                    selectedInputUnit = previousVal
                                    print("do something", model.isValid)
                                }
                            })
                            .pickerStyle(.segmented)
                        
                        TextField("", text: $selectedInputValue)
                            .modifier(PlaceholderStyle(showPlaceHolder: selectedInputValue.isEmpty, placeholder: "Enter Input Value",color: .white))
                            .padding()
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .keyboardType(.numberPad)
                            .focused($isKeyboadVisible)
                    }
                }
                
                Section("Select Output Unit") {
                    Picker("Output Unit", selection: $selectedOutputUnit) {
                        ForEach(unitsArr, id: \.self) { units in
                            Text(units.rawValue)
                                .font(.system(size: 20, weight: .bold, design: .default))
                        }
                    }
                    .onAppear(perform: {
                        print("eeee")
                        previousOutVal = selectedOutputUnit
                    })
                    .onChange(of: selectedOutputUnit, perform: { newValue in
                        if selectedInputUnit == selectedOutputUnit {
                            model.showOutputAlert = true
                        } else {
                            previousOutVal = selectedOutputUnit
                            model.showOutputAlert = false
                        }
                        print("bbbb1 \(previousOutVal)", selectedOutputUnit)
                    })
                    .alert(isPresented: $model.showOutputAlert, content: {
                        LoadAlertView.bodyWithAction(message: "Input and Output Unit Can't Be Same") {
                            model.showOutputAlert.toggle()
                            selectedOutputUnit = previousOutVal
                            print("do something fuck\(previousOutVal)", model.isValid)
                        }
                    })
                    .pickerStyle(.segmented)
                }
                
                Text("Output Value:- \(selectedOutputValue)")
            }
            Button {
                checkAndCalculate()
                print("Button Tapped")
            } label: {
                Text("Convert").font(.system(size: 20, weight: .medium, design: .default))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50, alignment: .center)
                    .background(Color.pink)
                    .cornerRadius(10)
            }
            .alert(isPresented: $model.showAlertForEmptyInput, content: {
                LoadAlertView.bodyWithAction(message: "Input field can't be Empty") {
                    print("okay vro")
                }
            })
            .padding([.bottom], 50)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            isKeyboadVisible = false
                        }
                    }
                }
            }
            Spacer()
            
        }.background(Color.init(r: 239, g: 238, b: 246))
    }
    
    func checkAndCalculate() {
        if !selectedInputValue.isEmpty {
            selectedOutputValue = "\((Double(selectedInputValue) ?? 0)/1000)"
        } else {
            model.showAlertForEmptyInput = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


class AlertsProperties: ObservableObject {
    @Published var isValid: Bool = false
    @Published var showOutputAlert: Bool = false
    @Published var showAlertForEmptyInput: Bool = false
}

struct LoadAlertView {
    static func bodyWithAction(message: String, withTwoButtons: Bool = false, _ onAction: @escaping () -> Void) -> Alert {
        let alert = withTwoButtons ? Alert(title: Text("Error"), message: Text(message), primaryButton: .default(Text("Ok"), action: {
            onAction()
        }), secondaryButton: .default(Text("Cancel"), action: {
            onAction()
        })): Alert(title: Text("Error"), message: Text(message), dismissButton: .default(Text("Ok"), action: {
            onAction()
        }))
        return alert
    }
}

public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    var color: Color
    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
            }
            content
                .foregroundColor(color)
                .padding(5.0)
        }
    }
}


extension Color {
    init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0)
    }
}
