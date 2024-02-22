//
//  File.swift
//  Translator
//
//  Created by 董承威 on 2024/2/18.
//

import SwiftUI
import PopupView



struct list: Hashable, Codable, Identifiable {
    var id = UUID()
    var name:String
    var element: [elementInlist]
    
    struct elementInlist: Hashable, Codable, Identifiable {
        var id = UUID()
        var string: String
        var starred: Bool
        var done: Bool
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var Lists: [list] = [list(name: "list1", element: [list.elementInlist(string: "word1inlist1", starred: false, done: false),
                                                              list.elementInlist(string: "word2inlist1", starred: false, done: false)]),
                                list(name: "list2", element: [list.elementInlist(string: "word1inlist2", starred: false, done: false)])]
    let userDefaults = UserDefaults.standard
    @State private var newItem = ""
    @State private var isEditing = false
    @State private var settingPopUp = false
    @FocusState private var isFocused: Bool
    
    func createListView(listIndexInLists: Int) -> some View {
        List {
            ForEach(Array(Lists[listIndexInLists].element.enumerated()), id: \.element.id) { itemIndex, _ in
                Text(Lists[listIndexInLists].element[itemIndex].string)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Look up something...", text: $newItem)
                        .padding(7)
                        .padding(.horizontal, 25)
                        .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray5))
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
                        .focused($isFocused)
                        .onTapGesture {
                            self.isEditing = true
                            isFocused = true
                        }
                        .submitLabel(.search)
                        .onSubmit{
                            self.isEditing = false
                            showDefinition(newItem)
                            newItem = ""
                        }
                    if isEditing {
                        Button{
                            self.isEditing = false
                            self.newItem = ""
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        } label: {
                            Text("Cancel")
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, -7)
                        .padding(.trailing, 10)
                    }
                }//Textfield Hstack
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                
                List {
                    Section {
                        ForEach(Array(Lists.enumerated()), id: \.element.id){ listIndex, _ in
                                NavigationLink{
                                    createListView(listIndexInLists: listIndex)
                                        .navigationTitle(Lists[listIndex].name)
                                } label: {
                                    Text(Lists[listIndex].name)
                                        .foregroundColor(.black)
                                }
                        }//ForEach
                    } header: {
                        Text("My Lists").font(.title).foregroundStyle(Color(.black))
                    }
                }
                
                if !isEditing {
                    Text("Total: \(self.Lists.count) lists")
                        .font(.callout)
                        .foregroundStyle(Color.gray)
                        .padding()
                }
            }//Vstack
            
                
                
                
    //            if Lists.count==0{
    //                if newItem==""{
    //                    HStack {
    //                        Image(systemName: "arrow.up")
    //                        Text("Enter a new vocabulary to the list")
    //                    }
    //                    .padding(5)
    //                }
    //                Spacer()
    //            } else {
    //                List {
    //                    ForEach(items.filter({newItem.isEmpty ? true : $0.contains(newItem)}), id: \.self) { item in
    //                        HStack {
    //                            Text(Lists)
    //                                .frame(maxWidth: .infinity, alignment: .leading)
    //                                .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
    //                                .onTapGesture {
    //                                    showDefinition(item)
    //                                }
    //                            Image(systemName: "star")
    //                                .foregroundStyle(Color.yellow)
    //                        }
    //                    }
    //                    .onDelete(perform: deleteItems)
    //                    .onMove(perform: moveItems)
    //                }
    //                .scrollContentBackground(.hidden)
    //            }
                
    //            if !isEditing {
    //                Text("List Count: \(self.items.count)")
    //                    .font(.callout)
    //                    .foregroundStyle(Color.gray)
    //                    .padding()
    //            }

            .background(colorScheme == .dark ? Color.black : Color(UIColor.systemGray6))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("test")
                }
            }

            .animation(.easeInOut, value: isEditing)
    //        .overlay {
    //            if isEditing {
    //                HStack {
    //                    Spacer()
    //                    VStack(alignment: .trailing) {
    //                        Spacer()
    //                        if items.count == 0 && !(newItem==""){
    //                            HStack(spacing:3){
    //                                Image(systemName: "arrow.down.right")
    //                                Text("Tap to Look up / Append")
    //                            }
    //                            .padding(.bottom, 1)
    //                            .padding(.trailing, -5)
    //                        }
    //                        HStack {
    //                            Button{
    //                                showDefinition(newItem)
    //                            } label: {
    //                                Image(systemName: "character.book.closed.fill")
    //                                    .foregroundStyle(.brown.gradient)
    //                            }
    //                            Button {
    //                                addItem()
    //                            } label: {
    //                                Image(systemName: "plus.circle.fill")
    //                                    .foregroundStyle(.cyan.gradient)
    //                            }
    //                        }
    //                        .font(.system(size: 50))
    //                    }
    //                    .padding()
    //                    .padding(.trailing, 5)
    //                }
    //            }
    //        }
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
    }
    
//    var addButton: some View {
//        HStack {
//            TextField("Enter new item", text: $newItem)
//                .padding(.vertical, 8)
//            Button{
//                addItem()
//            } label: {
//                Text("Add")
//            }
//        }
//        .padding(.horizontal)
//    }
    
//    func addItem() {
//        if !newItem.isEmpty {
//            items.append(newItem)
//            newItem = ""
//        }
//    }
    
//    func deleteItems(at offsets: IndexSet) {
//        items.remove(atOffsets: offsets)
//    }
//
//    func moveItems(from source: IndexSet, to destination: Int) {
//        items.move(fromOffsets: source, toOffset: destination)
//    }
    
    func showDefinition(_ word: String){
        UIApplication
            .shared.connectedScenes.map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.first?
            .rootViewController?.present(UIReferenceLibraryViewController(term: word), animated: true, completion: nil)
    }
}


#Preview {
    ContentView()
}
