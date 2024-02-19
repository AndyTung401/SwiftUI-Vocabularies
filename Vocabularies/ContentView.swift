//
//  File.swift
//  Translator
//
//  Created by 董承威 on 2024/2/18.
//

import SwiftUI
import PopupView

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("items") private var items = ["This is a sample list", "You can swipe left to remove an item", "Tap and Hold to rearrange", "↓ Tap on a item to expand definitions", "Apple", "Now, please remove all the items"]
    @State private var newItem = ""
    @State private var isEditing = false
    @State private var settingPopUp = false
    
    
    var body: some View {
        VStack{
            HStack{
                Button{
                    settingPopUp = true
                } label: {
                    Image(systemName: "gear")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.gray)
                .padding(.leading, 7)
                .padding(.trailing, -8)
                TextField("Enter a vocabulary", text: $newItem)
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.gray)
                                .padding(.leading, 8)
                            Spacer()
                            if isEditing {
                                Button{
                                    self.newItem = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                        }
                    )
                    .padding(.horizontal, 10)
                    .onTapGesture {
                        self.isEditing = true
                    }
                if isEditing {
                    Button{
                        self.isEditing = false
                        self.newItem = ""
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } label: {
                        Text("Done")
                    }
                    .padding(.trailing, 10)
                }
            }//Hstack
            .frame(height: 70)
            .padding(.horizontal, 5)
            .background(Color(.systemBackground))
            
            if items.count==0{
                if newItem==""{
                    HStack {
                        Image(systemName: "arrow.up")
                        Text("Enter a new vocabulary to the list")
                    }
                    .padding(5)
                }
                Spacer()
            } else {
                List {
                    ForEach(items.filter({newItem.isEmpty ? true : $0.contains(newItem)}), id: \.self) { item in
                        HStack {
                            Text(item)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                .onTapGesture {
                                    showDefinition(item)
                                }
                            Image(systemName: "star")
                                .foregroundStyle(Color.yellow)
                        }
                    }
                    .onDelete(perform: deleteItems)
                    .onMove(perform: moveItems)
                }
                .scrollContentBackground(.hidden)
            }
            
            if !isEditing {
                Text("List Count: \(self.items.count)")
                    .font(.callout)
                    .foregroundStyle(Color.gray)
                    .padding()
            }
        }//Vstack
        .background(colorScheme == .dark ? Color.black : Color(UIColor.systemGray6))
        .animation(.easeInOut, value: isEditing)
        .overlay {
            if isEditing {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Spacer()
                        if items.count == 0 && !(newItem==""){
                            HStack(spacing:3){
                                Image(systemName: "arrow.down.right")
                                Text("Tap to Look up / Append")
                            }
                            .padding(.bottom, 1)
                            .padding(.trailing, -5)
                        }
                        HStack {
                            Button{
                                showDefinition(newItem)
                            } label: {
                                Image(systemName: "character.book.closed.fill")
                                    .foregroundStyle(.brown.gradient)
                            }
                            Button {
                                addItem()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.cyan.gradient)
                            }
                        }
                        .font(.system(size: 50))
                    }
                    .padding()
                    .padding(.trailing, 5)
                }
            }
        }
        .popup(isPresented: $settingPopUp) {
            VStack(alignment: .center, spacing: 5) {
                Text("Go to")
                    .bold()
                    .frame(width: 250, alignment: .leading)
                Text("Settings > General > Dictionaries")
                    .frame(width: 250, alignment: .leading)
                    .padding(.bottom, 25)
                Link(destination: URL(string: "app-settings:root=General")!) {
                    Label("Open Settings", systemImage: "arrow.up.forward.app")
                        .font(.body)
                        .foregroundStyle(Color.white)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                        }

                }
            }
            .frame(width: 320, height: 230)
            .background {
                VStack{
                    HStack{
                        Spacer()
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.gray)
                            .padding()
                            .onTapGesture {
                                settingPopUp = false
                            }
                    }
                    Spacer()
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(.systemGray6):.white)
            }
        } customize: {
            $0
                .animation(.snappy)
                .closeOnTapOutside(true)
                .backgroundColor(.black.opacity(0.5))
        }
    }
    
    var addButton: some View {
        HStack {
            TextField("Enter new item", text: $newItem)
                .padding(.vertical, 8)
            Button{
                addItem()
            } label: {
                Text("Add")
            }
        }
        .padding(.horizontal)
    }
    
    func addItem() {
        if !newItem.isEmpty {
            items.append(newItem)
            newItem = ""
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func moveItems(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
    
    func showDefinition(_ word: String){
        UIApplication
            .shared.connectedScenes.map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.first?
            .rootViewController?.present(UIReferenceLibraryViewController(term: word), animated: true, completion: nil)
    }
}


#Preview {
    ContentView()
}
