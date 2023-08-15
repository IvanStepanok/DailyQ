//
//  CalendarView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 08.08.2023.
//

import SwiftUI

import SwiftUI

struct CalendarView: View {
    let calendar = Calendar.current
    let currentDate = Date()
    
    var winnerDates: [Date]
    var showWinnerAnimation: Bool
    
    @State var animate: Bool = false
    @State var animateTwo: Bool = false
    @State var startBorn: Bool = false
    
    
    private let columns = [GridItem(.flexible()),
                           GridItem(.flexible()),
                           GridItem(.flexible()),
                           GridItem(.flexible()),
                           GridItem(.flexible()),
                           GridItem(.flexible()),
                           GridItem(.flexible())]
    
    var body: some View {
        ZStack(alignment: .center) {
        VStack(spacing: 20) {
//            Text("Месяц \(calendar.component(.month, from: currentDate))")
//                .font(.title)
//                .padding()
            
            LazyVGrid(columns: columns) {
                ForEach(1..<8, id: \.self) { dayOfWeek in
                    Text("\(self.weekdaySymbol(dayOfWeek))")
                        .font(.system(size: 12, weight: .semibold, design: .default))
                }
            }
                LazyVGrid(columns: columns) {
                    ForEach(Array(daysInCurrentMonth().enumerated()), id: \.offset) { _, day in
                        if day != 0 {
                            let isWinnerDate = winnerDates.contains { winnerDate in
                                let components = calendar.dateComponents([.year, .month, .day], from: winnerDate)
                                return components.year == calendar.component(.year, from: currentDate) &&
                                components.month == calendar.component(.month, from: currentDate) &&
                                components.day == day
                            }
                            let today = calendar.component(.day, from: currentDate)
                            let isToday = today == day
                            
                            if isWinnerDate {
                                Text("⭐️")
                                    .offset(x: 0.5, y: -0.5)
                                    .scaleEffect(!isToday ? 1 : 0)
                                    .font(.system(size: 18, weight: .regular, design: .default))
                                    .font(.headline)
                                    .frame(width: 30, height: 30)
                                    .background(isToday ? .red : .white.opacity(0.1))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(lineWidth: 1)
                                            .fill(today >= day ? .white.opacity(0.2) : .clear)
                                            .opacity(isToday ? 0 : 1)
                                    )
                                    .overlay {
                                        if isToday {
                                            Text("⭐️")
                                                .scaleEffect(animate ? 1 : 100)
                                                .rotationEffect(Angle(degrees: animate ? 0 : 180))
                                                .blur(radius: animate ? 0 : 40)
                                                .offset(x: animate ? 0 : -500,
                                                        y: animate ? 0 : -1000)
                                        }
                                    }
                            } else {
                                Text("\(day)")
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .font(.headline)
                                    .frame(width: 30, height: 30)
                                    .background(isToday ? .green : .clear)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(lineWidth: 1)
                                            .fill(today >= day  ? .white.opacity(0.2) : .clear)
                                    )
                            }
                        } else {
                            VStack {}
                        }
                    }
                }
        }.onFirstAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                
//                withAnimation(Animation.interpolatingSpring(mass: 0.3, stiffness: 0.1, damping: 1, initialVelocity: 0.3) ) {
                withAnimation(Animation.spring(response: 1, dampingFraction: 0.9, blendDuration: 1.4)) {
                    animate = true
                }
            }
        }
        }
    }
    
    func daysInCurrentMonth() ->  [Int] {
        var days: [Int] = []
        let result = 1..<calendar.range(of: .day, in: .month, for: currentDate)!.count + 1
        
        for _ in 0...dayOfMonthStart() {
            days.append(0)
        }
        for day in result {
            days.append(day)
        }
        return days
    }
    
    func dayOfMonthStart() -> Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        guard let firstDayOfMonth = calendar.date(from: components) else {
            return 0 // В случае ошибки вернем 0
        }
        let dayOfWeek = calendar.component(.weekday, from: firstDayOfMonth)
        
        
        // Преобразуем результат, чтобы учитывать начало недели с понедельника (1) или воскресенья (7)
        let adjustedDayOfWeek = (dayOfWeek - calendar.firstWeekday + 7) % 7 - 1// + 1

        return adjustedDayOfWeek
    }

    
    func weekdaySymbol(_ dayOfWeek: Int) -> String {
        let weekdaySymbols = calendar.shortWeekdaySymbols
        let index = (dayOfWeek - calendar.firstWeekday + 7) % 7
        return weekdaySymbols[index]
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            RainbowBackgroundView(timeInterval: 3)
            CalendarView(winnerDates: [
                //        DateComponents(calendar: Calendar.current, year: 2023, month: 8, day: 1).date!,
                //        DateComponents(calendar: Calendar.current, year: 2023, month: 8, day: 2).date!,
                        DateComponents(calendar: Calendar.current, year: 2023, month: 8, day: 3).date!,
                        DateComponents(calendar: Calendar.current, year: 2023, month: 8, day: 4).date!,
                //        DateComponents(calendar: Calendar.current, year: 2023, month: 8, day: 5).date!,
                        DateComponents(calendar: Calendar.current, year: 2023, month: 8, day: 6).date!,
                //        DateComponents(calendar: Calendar.current, year: 2023, month: 8, day: 7).date!,
                        DateComponents(calendar: Calendar.current, year: 2023, month: 8, day: 8).date!,
                        DateComponents(calendar: Calendar.current, year: 2023, month: 8, day: 11).date!
            ], showWinnerAnimation: true)
        }
    }
}
