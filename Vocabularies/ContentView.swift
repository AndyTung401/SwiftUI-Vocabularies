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
    @State private var searchbarItem = ""
    @State private var settingPopUp = false
    @State private var isSearching = false
    @State private var newItem = ""
    @State private var showingAlert = false
    @State private var showDict = false
    
    func createListView(listIndexInLists: Int) -> some View {
        List {
            ForEach(Array(Lists[listIndexInLists].element.indices), id: \.self) { itemIndex in
                Text(Lists[listIndexInLists].element[itemIndex].string)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {

                
                
                List {
                    Section {
                        ForEach(Array(Lists.indices), id: \.self){ listIndex in
                                NavigationLink{
                                    createListView(listIndexInLists: listIndex)
                                        .navigationTitle(Lists[listIndex].name)
                                } label: {
                                    Text(Lists[listIndex].name)
                                }
                        }//ForEach
                        .onDelete(perform: deleteItems)
                        .onMove(perform: moveItems)
                    } header: {
                        HStack{
                            Text("My Lists").font(.title).foregroundStyle(colorScheme == .dark ? Color(.white) : Color(.black)).padding(.bottom, 5)
                            Spacer()
                            Button {
                                showingAlert.toggle()
                            } label: {
                                Image(systemName: "plus")
                            }
                            .alert("Enter your name", isPresented: $showingAlert) {
                                TextField("Enter your name", text: $newItem)
                                Button("OK") {addItem()}
                                Button("Cancel", role: .cancel) {
                                    showingAlert.toggle()
                                    newItem = ""
                                }
                            }

                            EditButton().padding(5)
                        }.textCase(nil)
                    }
                }
                .searchable(text: $searchbarItem, isPresented: $isSearching, prompt: "Look up something...")
                .onSubmit(of: .search) {
                    showDefinition(searchbarItem)
                    isSearching = false
                    searchbarItem = ""
                }
                
                if !isSearching {
                    Text("Total: \(self.Lists.count) lists")
                        .font(.callout)
                        .foregroundStyle(Color.gray)
                        .padding()
                }
            }//Vstack
            
                
                
                
    //            if Lists.count==0{
    //                if searchbarItem==""{
    //                    HStack {
    //                        Image(systemName: "arrow.up")
    //                        Text("Enter a new vocabulary to the list")
    //                    }
    //                    .padding(5)
    //                }
    //                Spacer()
    //            } else {
    //                List {
    //                    ForEach(items.filter({searchbarItem.isEmpty ? true : $0.contains(searchbarItem)}), id: \.self) { item in
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
                    Button {
                        return
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }

                }
            }

    //        .overlay {
    //            if isEditing {
    //                HStack {
    //                    Spacer()
    //                    VStack(alignment: .trailing) {
    //                        Spacer()
    //                        if items.count == 0 && !(searchbarItem==""){
    //                            HStack(spacing:3){
    //                                Image(systemName: "arrow.down.right")
    //                                Text("Tap to Look up / Append")
    //                            }
    //                            .padding(.bottom, 1)
    //                            .padding(.trailing, -5)
    //                        }
    //                        HStack {
    //                            Button{
    //                                showDefinition(searchbarItem)
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
    
    
    func addItem() -> Void{
        if !newItem.isEmpty {
            Lists.append(list(name: newItem, element: []))
            newItem = ""
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        Lists.remove(atOffsets: offsets)
    }

    func moveItems(from source: IndexSet, to destination: Int) {
        Lists.move(fromOffsets: source, toOffset: destination)
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
