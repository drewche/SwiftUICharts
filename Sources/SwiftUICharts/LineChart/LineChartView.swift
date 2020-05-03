//
//  LineChartView.swift
//  ChartTest
//
//  Created by Andrew Che on 5/2/20.
//  Copyright © 2020 Andrew Che. All rights reserved.
//

import SwiftUI

public struct LineChartView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var data:ChartData
    @ObservedObject var headData:ChartData
    public var title: String
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    
    public var formSize:CGSize
    public var dropShadow: Bool
    public var valueSpecifier:String
    public var frame: CGSize
    
    @State private var touchLocation:CGPoint = .zero
    @State private var showIndicatorDot: Bool = false
    @State private var showHeadIndicatorDot: Bool = false
    @State private var currentValue: Double = 2 {
        didSet{
            if (oldValue != self.currentValue && showIndicatorDot) {
//                HapticFeedback.playSelection()
            }
            
        }
    }
    @State private var currentHeadValue: Double = 2 {
        didSet{
            if (oldValue != self.currentHeadValue && showHeadIndicatorDot) {
//                HapticFeedback.playSelection()
            }
            
        }
    }
    private var rateValue: Int
    
    public init(data: [Double],
                headData: [Double],
                title: String,
                legend: String? = nil,
                style: ChartStyle = Styles.lineChartStyleOne,
                form: CGSize? = ChartForm.medium,
                rateValue: Int? = 14,
                dropShadow: Bool? = true,
                valueSpecifier: String? = "%.1f",
                frame: CGSize? = CGSize(width: 360, height: 140)) {
        
        self.data = ChartData(points: data)
        self.headData = ChartData(points: headData)
        self.title = title
        self.legend = legend
        self.style = style
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
        self.formSize = form!
        self.rateValue = rateValue!
        self.dropShadow = dropShadow!
        self.valueSpecifier = valueSpecifier!
        self.frame = frame!
    }
    
    public var body: some View {
        ZStack(alignment: .center){
            RoundedRectangle(cornerRadius: 20)
                .fill(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
                .shadow(color: Color(hexString: "#D9DADC"), radius: self.dropShadow ? 8 : 0)
            VStack {
                HStack {
                    if(!self.showIndicatorDot && !self.showHeadIndicatorDot){
                    VStack(alignment: .leading, spacing: 4){
//                        Text(self.title)
//                            .font(.title)
//                            .bold()
//                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                        if (self.legend != nil){
                            Text(self.legend!)
                                .font(.callout)
                                .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor :self.style.legendTextColor)
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeIn(duration: 0.1))
                    .padding(.leading)
                    .padding(.top, 10)
                    } else {
                        EmptyView()
                    }
                    Spacer()
                }
                Spacer()
            }

            VStack(alignment: .center, spacing: 0) {
                // EYE DATA
                HStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack {
                            if (self.showIndicatorDot) {
                                HStack{
                                    Spacer()
                                    Text("\(self.currentValue, specifier: self.valueSpecifier)")
                                        .font(.system(size: 41, weight: .bold, design: .default))
                                        .offset(x: 0, y: 0)
                                    Spacer()
                                }
                                .transition(.scale)
                            }
                            GeometryReader{ geometry in
                                Line(data: self.data,
                                    frame: .constant(geometry.frame(in: .local)),
                                    touchLocation: self.$touchLocation,
                                    showIndicator: self.$showIndicatorDot,
                                    flip: false,
                                    minDataValue: .constant(0),
                                    maxDataValue: .constant(nil),
                                    showBackground: false,
                                    gradient: GradientColors.orange
                                )
                            }
                            .frame(width: frame.width - 30, height: frame.height)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .offset(x: 0, y: 0)
                        
                        }
                    }.frame(width: self.frame.width - 30, height: self.frame.height - 30)
                    .gesture(DragGesture()
                    .onChanged({ value in
                        self.touchLocation = value.location
                        self.showIndicatorDot = true
                        self.getClosestDataPoint(toPoint: value.location, width:self.frame.width, height: self.frame.height, eye: true)
                    })
                        .onEnded({ value in
                            self.showIndicatorDot = false
                        })
                    )
                }
                Divider()
                    .padding(.leading, 25)
                // HEAD DATA
                HStack {
                    Spacer()
                    VStack(alignment: .leading){
                        ZStack {
                            if(self.showHeadIndicatorDot){
                                HStack{
                                    Spacer()
                                    Text("\(self.currentHeadValue, specifier: self.valueSpecifier)")
                                        .font(.system(size: 41, weight: .bold, design: .default))
                                        .offset(x: 0, y: 0)
                                    Spacer()
                                }
                                .transition(.scale)
                            }
                            GeometryReader{ geometry in
                                Line(data: self.headData,
                                    frame: .constant(geometry.frame(in: .local)),
                                    touchLocation: self.$touchLocation,
                                    showIndicator: self.$showHeadIndicatorDot,
                                    flip: false,
                                    minDataValue: .constant(nil),
                                    maxDataValue: .constant(0),
                                    showBackground: false
                                )
                            }
                            .frame(width: frame.width - 30, height: frame.height - 30)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .offset(x: 0, y: 0)
                        }
                    }.frame(width: self.frame.width - 30, height: self.frame.height - 30)
                    .gesture(DragGesture()
                    .onChanged({ value in
                        self.touchLocation = value.location
                        self.showHeadIndicatorDot = true
                        self.getClosestDataPoint(toPoint: value.location, width:self.frame.width, height: self.frame.height, eye: false)
                    })
                        .onEnded({ value in
                            self.showHeadIndicatorDot = false
                        })
                    )
                }
                
            }
            // AXES LABELS
            VStack {
                Spacer()
                Divider()
                    .padding(.leading, 25)
                    .padding(.bottom, 3)
                Text("Time (ms)")
                    .font(.system(size: 11, weight: .bold, design: .default))
                    .foregroundColor(self.colorScheme == .dark ?  self.darkModeStyle.legendTextColor :self.style.legendTextColor)
                    .offset(y: -5)
            }
            HStack {
                Text("Velocity (°/s)")
                    .font(.system(size: 11, weight: .bold, design: .default))
                    .foregroundColor(self.colorScheme == .dark ?          self.darkModeStyle.legendTextColor :self.style.legendTextColor)
                    .rotationEffect(.degrees(-90))
                    .offset(x: -25)
                Divider()
                    .offset(x: -60)
                    .padding(.bottom, 25)
                    .padding(.top, 35)
                Spacer()
            }

        }
        .frame(width: frame.width, height: frame.height * 2, alignment: .center)
    }
    
    @discardableResult func getClosestDataPoint(toPoint: CGPoint, width:CGFloat, height: CGFloat, eye: Bool) -> CGPoint {
        var points: [Double]
        if (eye) {
            points = self.data.onlyPoints()
        } else {
            points = self.headData.onlyPoints()
        }
        
        let stepWidth: CGFloat = width / CGFloat(points.count-1)
        let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)
        
        let index:Int = Int(round((toPoint.x)/stepWidth))
        if (index >= 0 && index < points.count){
            if (eye) {
                self.currentValue = points[index]
            } else {
                self.currentHeadValue = points[index]
            }
                
            return CGPoint(x: CGFloat(index)*stepWidth, y: CGFloat(points[index])*stepHeight)
        }
        return .zero
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LineChartView(data: [0.3,0.2,0.1,0.4,0.6,0.5,0.4,0.1,0.1], headData: [-0.3,-0.2,-0.1,-0.4,-0.6,-0.5,-0.4,-0.1,-0.1], title: "Line chart", legend: "Basic")
                .environment(\.colorScheme, .light)
        }
    }
}
