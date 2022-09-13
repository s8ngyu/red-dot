//
//  ContentView.swift
//  reddot
//
//  Created by Soongyu Kwon on 9/12/22.
//

import UIKit
import SwiftUI

struct ContentView: View {
    @State private var dotColour = Color.red
    @State private var showingAlert = false
    @State private var showingError = false
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Rectangle()
                    .frame(width: 200, height: 100)
                    .foregroundColor(Color(UIColor.systemGray6))
                    .cornerRadius(20)
                ZStack(alignment: .topTrailing) {
                    Text("Red Dot")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(8)
                    ZStack {
                        Circle()
                            .frame(width: 30)
                            .foregroundColor(dotColour)
                        Text("2")
                            .foregroundColor(.white)
                    }
                }.padding()
                .frame(width: 200, height: 100)
            }.frame(width: 200, height: 100)
            
            ColorPicker(selection: $dotColour) {
                Text("Badge colour")
            }.padding(.horizontal, 110)
            
            Spacer()
            if #available(iOS 15.0, *) {
                Text("made with ❤️ by Soongyu Kwon")
                    .alert("Finished!", isPresented: $showingAlert
                    ) {
                        Button("Okay") {
                            // handle retry action.
                        }
                    } message: {
                        Text("Respring your device using TrollStore to apply changes.")
                    }
            } else {
                Text("made with ❤️ by Soongyu Kwon")
                    .alert(isPresented: $showingError) {
                        Alert(title: Text("Error!"), message: Text("App is running in sandbox!\nPlease install it via TrollStore."), dismissButton: .default(Text("Dismiss")))
                    }
            }
            HStack {
                Text("Follow me on")
                Link(destination: URL(string: "https://twitter.com/soongyu_kwon")!, label: {
                    Text("Twitter")
                })
                Text("&")
                Link(destination: URL(string: "https://instagram.com/s8ngyu.kwon")!, label: {
                    Text("Instagram")
                })
            }
            Spacer()
                .frame(height: 20)
            Button(action: {
                let fileManager = FileManager.default
                do {
                    try fileManager.removeItem(atPath: "/var/mobile/Library/Caches/MappedImageCache/Persistent/SBIconBadgeView.BadgeBackground:26:26.cpbitmap")
                } catch {
                    print("Failed to revert changes")
                }
                showingAlert.toggle()
            }) {
                Text("Revert changes")
            }.disabled(!isSandboxEscaped())
            if #available(iOS 15.0, *) {
                Button(action: {
                    changeColour(colour: UIColor(dotColour))
                    showingAlert.toggle()
                }) {
                    Text("Apply")
                        .frame(width: UIScreen.main.bounds.size.width-80)
                        .padding()
                        .foregroundColor(.white)
                }
                .background(Color.accentColor)
                .cornerRadius(25)
                .disabled(!isSandboxEscaped())
                .padding(.bottom)
                .alert("Finished!", isPresented: $showingAlert
                ) {
                    Button("Okay") {
                        // handle retry action.
                    }
                } message: {
                    Text("Respring your device using TrollStore to apply changes.")
                }
            } else {
                Button(action: {
                    changeColour(colour: UIColor(dotColour))
                    showingAlert.toggle()
                }) {
                    Text("Apply")
                        .frame(width: UIScreen.main.bounds.size.width-80)
                        .padding()
                        .foregroundColor(.white)
                }
                .background(Color.accentColor)
                .cornerRadius(25)
                .disabled(!isSandboxEscaped())
                .padding(.bottom)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Finished!"), message: Text("Respring your device using TrollStore to apply changes."), dismissButton: .default(Text("Okay")))
                }
            }
        }
        .onAppear() {
            if !isSandboxEscaped() {
                showingError.toggle()
            }
        }
    }
}

func isSandboxEscaped() -> Bool {
    let fileManager = FileManager.default
    fileManager.createFile(atPath: "/var/mobile/me.soongyu.red-dot", contents: nil)
    if fileManager.fileExists(atPath: "/var/mobile/me.soongyu.red-dot") {
        do {
            try fileManager.removeItem(atPath: "/var/mobile/me.soongyu.red-dot")
        } catch {
            print("Failed to remove sandbox check file")
        }
        return true
    }
    
    return false
}

func changeColour(colour: UIColor) {
    var badge: UIImage = getRoundImage(12, 24, 24)!
    
    if UIDevice.current.userInterfaceIdiom == .pad {
        badge = getRoundImage(24, 48, 48)!
    }
    
    badge = changeImageColour(badge, colour)!
    
    let savePath = "/var/mobile/SBIconBadgeView.BadgeBackground:26:26.cpbitmap"
    let targetPath = "/var/mobile/Library/Caches/MappedImageCache/Persistent/SBIconBadgeView.BadgeBackground:26:26.cpbitmap"
    
    let helper = ObjCHelper()
    helper.image(toCPBitmap: badge, path: savePath)
    
    let fileManager = FileManager.default
    do {
        try fileManager.removeItem(atPath: targetPath)
    } catch {
        print("Failed to revert changes")
    }
    do {
        try fileManager.moveItem(atPath: savePath, toPath: targetPath)
    } catch {
        print("Failed to move item")
    }
}

func changeImageColour(_ src_image: UIImage?, _ color: UIColor?) -> UIImage? {

    let rect = CGRect(x: 0, y: 0, width: src_image?.size.width ?? 0.0, height: src_image?.size.height ?? 0.0)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    let context = UIGraphicsGetCurrentContext()
    if let CGImage = src_image?.cgImage {
        context?.clip(to: rect, mask: CGImage)
    }
    if let cgColor = color?.cgColor {
        context?.setFillColor(cgColor)
    }
    context?.fill(rect)
    let colorized_image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return colorized_image
}

func getRoundImage(_ radius: Int, _ width: Int, _ height: Int) -> UIImage? {
    
    let rect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(UIColor.black.cgColor)
    context?.fill(rect)
    let src_image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    let image_layer = CALayer()
    image_layer.frame = CGRect(x: 0, y: 0, width: src_image?.size.width ?? 0.0, height: src_image?.size.height ?? 0.0)
    image_layer.contents = src_image?.cgImage

    image_layer.masksToBounds = true
    image_layer.cornerRadius = CGFloat(radius)

    UIGraphicsBeginImageContextWithOptions(src_image?.size ?? CGSize.zero, false, 0.0)
    if let aContext = UIGraphicsGetCurrentContext() {
        image_layer.render(in: aContext)
    }
    let rounded_image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return rounded_image
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
