//
//  ContentView.swift
//  Tella
//
//  Created by Anessa Petteruti on 1/30/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)

                    VStack(alignment: .leading, spacing: 50) {
                        HStack {
                        Text("TELLA")
                            .font(.custom("Avenir Next Ultra Light", size: 55))
                        .background(Color.black)
                        .foregroundColor(.white)
                        .font(.title)
                            .padding(.leading, 40)
                            .padding(.trailing, 140)
                            .padding(.top, 10)

                            Button(action: {
                                print("shutdown buttonn")
                            }) {
                        Image("shutdown-icon")
                        .renderingMode(.original).resizable()
                            .frame(width: 40.0, height: 40.0)
                            }


                        Spacer()
                        }
                        Spacer()

                    }

                    VStack {


                    Button(action: {
                       print("camera buttonn")
                   }) {
                       Image("camera-icon")
                       .renderingMode(.original).resizable()
                       .frame(width: 35.0, height: 35.0)
                        .padding(.trailing, 10)

                        Text("CAMERA")
                    .font(.custom("Avenir Next Ultra Light", size: 35))
                    .background(Color.black)
                    .foregroundColor(.white)
                    .font(.title)


                   }.padding(20)
                    .border(Color.white, width: 1)
                        .cornerRadius(25)



                    Button(action: {
                        print("record buttonn")
                    }) {
                        Image("record-icon")
                        .renderingMode(.original).resizable()
                        .frame(width: 35.0, height: 35.0)
                            .padding(.trailing, 10)

                         Text("RECORD")
                     .font(.custom("Avenir Next Ultra Light", size: 35))
                     .background(Color.black)
                     .foregroundColor(.white)
                     .font(.title)


                    }.padding(20)

                     .border(Color.white, width: 1)
                        .cornerRadius(25)


                }
                    HStack {
                    Button(action: {
                        print("collect buttonn")
                    }) {
                        Image("collect-icon")
                        .renderingMode(.original).resizable()
                        .frame(width: 25.0, height: 25.0)
                            .padding(.trailing, 5)

                         Text("Collect")
                     .font(.custom("Avenir Next Ultra Light", size: 25))
                     .background(Color.black)
                     .foregroundColor(.white)
                     .font(.title)


                    }.padding(20)

                        .cornerRadius(25)

                        Button(action: {
                            print("gallery buttonn")
                        }) {
                            Image("gallery-icon")
                            .renderingMode(.original).resizable()
                            .frame(width: 25.0, height: 25.0)
                                .padding(.trailing, 5)

                             Text("Gallery")
                         .font(.custom("Avenir Next Ultra Light", size: 25))
                         .background(Color.black)
                         .foregroundColor(.white)
                         .font(.title)


                        }.padding(20)

                            .cornerRadius(25)
                    }.padding(.top, 700)

                    HStack {
                        Button(action: {
                            print("settings buttonn")
                        }) {
                            Image("settings-icon")
                            .renderingMode(.original).resizable()
                            .frame(width: 25.0, height: 25.0)


                        }

                    }.padding(.top, 810)
                    }



            }        }





struct Gallery: View {
           var body: some View {
              Text("Hello, World!")
           }
        }    

struct ontentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
