//
//  AdminPanelView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 12.08.2023.
//

import SwiftUI

struct AdminPanelView<Content: View>: View {
    
    @State var expand: Bool = false
    @Namespace var namespace
    
    @State var geometry: GeometryProxy?
    @State private var DragXPosition: CGFloat = 0
    @State private var DragYPosition: CGFloat = 0
    
    @State private var OldDragXPosition: CGFloat = 0
    @State private var OldDragYPosition: CGFloat = 0
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                print("x", value.location.x, "y", value.location.y)
                print("width", geometry!.size.width, "height", geometry!.size.height)

                DragYPosition = value.location.y
                DragXPosition = value.location.x
            }
            .onEnded { value in
                let horizontalLimit = geometry!.size.width - 100
                print("Limit:", horizontalLimit)
                if value.location.y < 0 {
                    withAnimation {
                        DragYPosition = OldDragYPosition
                    }
                } else if value.location.x < 0 {
                    withAnimation {
                        DragXPosition = OldDragXPosition
                    }
                } else if value.location.x > horizontalLimit {
                    withAnimation {
                        DragXPosition = horizontalLimit
                    }
                }
                
                else {
                    OldDragYPosition = value.location.y
                    OldDragXPosition = value.location.x
                }
            }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
            GeometryReader { reader in
                ZStack(alignment: .topTrailing) {
                    if expand {
                        VStack { content }
                            .padding(10)
                            .padding(.trailing, 45)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.black.opacity(0.3))
                                    .matchedGeometryEffect(id: "bg", in: namespace)
                            }.fixedSize(horizontal: false, vertical: true)
                    }
                    VStack {
                        ZStack {
                            if !expand {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.black.opacity(0.3))
                                    .matchedGeometryEffect(id: "bg", in: namespace)
                            }
                            Circle()
                                .frame(width: 25)
                                .foregroundColor(.white.opacity(0.5))
                            Circle()
                                .frame(width: 33)
                                .foregroundColor(.white.opacity(0.3))
                            Circle()
                                .frame(width: 40)
                                .foregroundColor(.white.opacity(0.3))
                        }.padding(.top, expand ? 7.5 : 0).padding(.trailing, expand ? 7.5 : 0)
                    }.onTapGesture {
                        withAnimation {
                            expand.toggle()
                        }
                    }
                    
                    
                }.frame(width: expand ? nil : 55, height: 55)
                    .fixedSize(horizontal: true, vertical: true)
                    .padding(.vertical, expand ? 36 : 0)
                    .padding(.horizontal, 16)
                    .offset(x: DragXPosition, y: DragYPosition)
                    .gesture(dragGesture)
                    .onAppear {
                        self.geometry = reader
                    }
            }
        }

    }
}

struct AdminPanelView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("bgColor")
                .ignoresSafeArea()
            RainbowBackgroundView()
            AdminPanelView(content: {
              Text("Test Content inside")
                Text("Test Content inside")
                Text("Test Content inside")
                Text("Test Content inside")
            })
        }
    }
}
