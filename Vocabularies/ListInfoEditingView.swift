//
//  ListInfoEditingView.swift
//  Vocabularies
//
//  Created by 董承威 on 2024/4/19.
//

import SwiftUI
import ColorGrid

struct EditListInfoPopUp: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var Lists: [list]
    var editingListIndex: Int
    @State var selectedColor = Color.red
    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: 10) {
                Circle()
                    .fill(Color[Lists[editingListIndex].color].gradient)
                    .shadow(color: colorScheme == .dark ? Color(white: 0, opacity: 0.33) : Color[Lists[editingListIndex].color].opacity(0.3), radius: 10, x: 0, y: 0)
                    .frame(width: 100, height: 100)
                    .padding(.vertical, 10)
                    .animation(.easeInOut(duration: 0.2), value: Lists[editingListIndex].color)
                    .overlay {
                        Image(systemName: Lists[editingListIndex].icon)
                            .bold()
                            .foregroundStyle(colorScheme == .dark ? Color(.white) : Color(.systemGray6))
                            .font(.system(size: 47))
                            .animation(.easeInOut(duration: 0.1), value: Lists[editingListIndex].icon)
                    }
                    
                TextField(Lists[editingListIndex].name, text: $Lists[editingListIndex].name)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color[Lists[editingListIndex].color])
                    .font(.title2)
                    .bold()
                    .padding(.vertical, 15)
                    .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        Color(colorScheme == .dark ? .systemGray4 : .systemGray6)
                                    )
                    )
                
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20, style: .circular)
                    .fill(
                        Color(colorScheme == .dark ? .systemGray5 : .white)
                    )
            }
            .padding(.top, 25)
            CGPicker(
                colors: [.red, .orange, .yellow, .green, .cyan, .blue, .indigo, .pink, .purple, .brown, .gray, Color(.init(red: 0.8196078431, green: 0.6588235294, blue: 0.6235294118))],
                selection: $selectedColor
            )
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .circular)
                    .fill(
                        Color(colorScheme == .dark ? .systemGray5 : .white)
                    )
            }
            .onChange(of: selectedColor) { oldValue, newValue in
                Lists[editingListIndex].color = String[selectedColor]
            }
            VStack(spacing: 15) {
                ForEach(0..<icons.count/6) { row in // create number of rows
                    HStack(spacing: 5) {
                        ForEach(0..<6) { column in // create 3 columns
                            ZStack {
                                Image(systemName: icons[row * 6 + column])
                                    .foregroundStyle(Color(colorScheme == .dark ? .white : .init(hue: 0, saturation: 0, brightness: 0.3)))
                                    .bold()
                                    .font(.title3)
                                    .frame(width: 40, height: 40)
                                    .background {
                                        Circle()
                                            .fill(
                                                Color(colorScheme == .dark ? .systemGray4 : .systemGray6)
                                            )
                                    }
                                    .onTapGesture {
                                        Lists[editingListIndex].icon = icons[row * 6 + column]
                                    }
                                if Lists[editingListIndex].icon == icons[row * 6 + column] {
                                    Circle()
                                        .fill(Color.clear)
                                        .stroke(Color(colorScheme == .dark ? .systemGray2 : .systemGray3), lineWidth: 3)
                                }
                            }
                            .frame(width: 50, height: 50)
                        }
                    }
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20, style: .circular)
                    .fill(
                        Color(colorScheme == .dark ? .systemGray5 : .white)
                    )
            }
            Spacer()
        }//vstack
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .presentationBackground(colorScheme == .dark ? Color(.systemGray6):Color(.systemGray6))
        .presentationDragIndicator(.visible)
        .presentationDetents([.fraction(0.9)])
        .presentationCornerRadius(15)
        .onAppear {
            selectedColor = Color[Lists[editingListIndex].color]
        }
    }
}
