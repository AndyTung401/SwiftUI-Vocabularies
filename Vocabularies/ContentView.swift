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
    let userDefaults = UserDefaults.standard
    @State private var searchbarItem = ""
    @State private var settingPopUp = false
    @State private var isSearching = false
    @State private var newItem = ""
    @State private var addingNewListAlert = false
    @State private var addingNewWordAlert = false
    @State private var showDict = false
    @State var Lists: [list] = [list(name: "list1", element: [list.elementInlist(string: "word1inlist1", starred: false, done: false),
                                                              list.elementInlist(string: "word2inlist1", starred: false, done: false)]),
                                list(name: "list2", element: [list.elementInlist(string: "word1inlist2", starred: false, done: false)])]
    
    func createListView(listIndexInLists: Int) -> some View {
        ZStack {
            List {
                ForEach(Array(Lists[listIndexInLists].element.filter({searchbarItem == "" ? true : $0.string == searchbarItem}).indices), id: \.self) { itemIndex in
                    HStack {
                        Text(Lists[listIndexInLists].element[itemIndex].string)
                        Color(colorScheme == .dark ? .systemGray6 : .white)
                    }
                    .onTapGesture {
                        showDefinition(Lists[listIndexInLists].element[itemIndex].string)
                    }
                }
                .onDelete(perform: { indexSet in
                    Lists[listIndexInLists].element.remove(at: indexSet.first!)
                })
                .onMove(perform: { indices, newOffset in
                    Lists[listIndexInLists].element.move(fromOffsets: indices, toOffset: newOffset)
                })
            }
            .searchable(text: $searchbarItem, isPresented: $isSearching, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for something...")

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        Lists[listIndexInLists].element.append(list.elementInlist(string: searchbarItem, starred:false, done: false))
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.cyan.gradient)
                    }
                    .padding()
                }
            }.opacity(isSearching ? 1 : 0)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    return
                } label: {
                    Image(systemName: "ellipsis.circle")
                }

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
                        .onDelete(perform: deleteList)
                        .onMove(perform: moveList)
                    } header: {
                        HStack{
                            Text("My Lists").font(.title).foregroundStyle(colorScheme == .dark ? Color(.white) : Color(.black)).padding(.bottom, 5)
                            Spacer()
                            Button {
                                addingNewListAlert.toggle()
                            } label: {
                                Image(systemName: "plus")
                            }
                            .alert("Add a list", isPresented: $addingNewListAlert) {
                                TextField("Enter a title", text: $newItem)
                                Button("OK") {addNewList()}
                                Button("Cancel", role: .cancel) {
                                    addingNewListAlert.toggle()
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
                    Text("Total: \(Lists.count) lists")
                        .font(.callout)
                        .foregroundStyle(Color.gray)
                        .padding()
                }
            }//Vstack
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
    
    
    func addNewList() -> Void{
        if !newItem.isEmpty {
            Lists.append(list(name: newItem, element: []))
            newItem = ""
        }
    }
    
    func deleteList(at offsets: IndexSet) {
        Lists.remove(atOffsets: offsets)
    }

    func moveList(from source: IndexSet, to destination: Int) {
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
