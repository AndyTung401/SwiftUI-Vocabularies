//
//  File.swift
//  Translator
//
//  Created by 董承威 on 2024/2/18.
//

import SwiftUI
import ColorGrid

struct list: Hashable, Identifiable {
    var id = UUID()
    var name: String
    var color: Color
    var icon: String
    var element: [elementInlist]
    
    struct elementInlist: Hashable, Identifiable {
        var id = UUID()
        var string: String
        var starred: Bool
        var done: Bool
    }
}

let icons = ["list.bullet", "bookmark.fill", "mappin", "graduationcap.fill", "backpack.fill", "pencil.and.ruler.fill", "doc.fill", "book.fill", "note.text", "textformat.alt", "highlighter", "book.pages.fill"]


struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.editMode) private var editMode
    let userDefaults = UserDefaults.standard
    @State private var searchbarItem = ""
    @State private var isSearching = false
    @State private var newItem = ""
    @State private var addingNewListAlert = false
    @State private var addingNewWordAlert = false
    @State private var showDict = false
    @State private var sortingMode = 0 //0:none
    @State private var showColorPicker = false
    @State private var editingListIdex = 0
    @State var Lists: [list] = [list(name: "An exanple list", color: .blue, icon: "list.bullet", element: [list.elementInlist(string: "This is a sample list", starred: false, done: false),
                                                              list.elementInlist(string: "Swipe left to remove/star an item", starred: false, done: false),
                                                              list.elementInlist(string: "Swipe right to chack an item", starred: false, done: false),
                                                              list.elementInlist(string: "Tap and Hold to rearrange", starred: false, done: false),
                                                              list.elementInlist(string: "↓ Tap on it for definitions", starred: false, done: false),
                                                              list.elementInlist(string: "Apple", starred: false, done: false),
                                                              list.elementInlist(string: "Try the search bar", starred: false, done: false)]),
                                list(name: "Tap on title for settings", color: .orange, icon: "mappin", element: [list.elementInlist(string: "Constitude", starred: false, done: false),
                                                              list.elementInlist(string: "Convince", starred: false, done: false),
                                                              list.elementInlist(string: "Delegate", starred: false, done: false),
                                                              list.elementInlist(string: "Abbreviate", starred: false, done: false)])]
    
    func createListView(listIndexInLists: Int) -> some View {
        ZStack {
            List {
                ForEach(Array(Lists[listIndexInLists].element.indices), id: \.self) { itemIndex in
                    if Lists[listIndexInLists].element[itemIndex].string.contains(searchbarItem) || searchbarItem == ""{
                        HStack {
                            Image(systemName: Lists[listIndexInLists].element[itemIndex].done ? "checkmark.circle.fill" : "circle").foregroundStyle(Lists[listIndexInLists].element[itemIndex].done ? .green : .gray)
                                .font(.system(size: 20))
                                .onTapGesture {
                                    toggleDone(listIndexInLists, itemIndex)
                                }
                            HStack{
                                Text(Lists[listIndexInLists].element[itemIndex].string)
                                    .opacity(Lists[listIndexInLists].element[itemIndex].done ? 0.4 : 1)
                                    .strikethrough(Lists[listIndexInLists].element[itemIndex].done)
                                    Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showDefinition(Lists[listIndexInLists].element[itemIndex].string)
                            }
                            Image(systemName: Lists[listIndexInLists].element[itemIndex].starred ? "star.fill" : "star").foregroundStyle(Color.yellow)
                                .font(.system(size: 20))
                                .onTapGesture {
                                    toggleStarred(listIndexInLists, itemIndex)
                                }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                toggleDone(listIndexInLists, itemIndex)
                            } label: {
                                Image(systemName: "checkmark.circle")
                            }
                            .tint(.green)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                toggleStarred(listIndexInLists, itemIndex)
                            } label: {
                                Image(systemName: "star")
                            }
                            .tint(.yellow)
                            Button(role: .destructive) {
                                Lists[listIndexInLists].element.remove(at: itemIndex)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        .contentShape(Rectangle())
                    }
                }
                .onMove(perform: { indices, newOffset in
                    Lists[listIndexInLists].element.move(fromOffsets: indices, toOffset: newOffset)
                    isSearching = false
                    searchbarItem = ""
                })
            }
            .scrollContentBackground(.hidden)
            .searchable(text: $searchbarItem, isPresented: $isSearching, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for something...")
            
            VStack {
                Spacer()
                if !isSearching && !addingNewWordAlert{
                    Text("\(Lists[listIndexInLists].element.count) items")
                        .font(.callout)
                        .foregroundStyle(Color.gray)
                        .padding()
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        if isSearching && !searchbarItem.isEmpty {
                            Lists[listIndexInLists].element.append(list.elementInlist(string: searchbarItem, starred:false, done: false))
                            searchbarItem = ""
                        } else if !isSearching || isSearching && searchbarItem.isEmpty {
                            addingNewWordAlert = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.cyan.gradient)
                    }
                    .opacity(addingNewWordAlert ? 0 : 1)
                    .padding()
                    .alert("Add a word", isPresented: $addingNewWordAlert) {
                        TextField("Enter something", text: $newItem)
                        Button("OK") {
                            if !newItem.isEmpty {
                                Lists[listIndexInLists].element.append(list.elementInlist(string: newItem, starred:false, done: false))
                            }
                            newItem = ""
                        }
                        Button("Cancel", role: .cancel) {
                            addingNewWordAlert = false
                            newItem = ""
                        }
                    }
                }
            }
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
        .background(colorScheme == .dark ? Color.black : Color(UIColor.systemGray6))
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
                                    HStack {
                                        HStack {
                                            Image(systemName: "circle.fill")
                                                .foregroundStyle(Lists[listIndex].color)
                                                .font(.largeTitle)
                                                .overlay {
                                                    Image(systemName: Lists[listIndex].icon)
                                                        .font(.headline)
                                                        .foregroundStyle(.white)
                                                }
                                                .padding(-1)
                                                .padding(.leading, -3)
                                            Text(Lists[listIndex].name)
                                                .font(.body)
                                        }//hstack for clickable elements
                                        .onTapGesture {
                                            editingListIdex = listIndex
                                            showColorPicker = true
                                        }//on tap gesture
                                        .swipeActions(allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                Lists.remove(at: listIndex)
                                            } label: {
                                                Image(systemName: "trash")
                                            }
                                        }//swipe actions
                                        Spacer()
                                        Text("\(Lists[listIndex].element.count)")
                                            .foregroundStyle(.gray)
                                    }//Hstacl
                                }
                        }//ForEach
                        .onMove(perform: {indicies, newOffest in
                            moveList(from: indicies, to: newOffest)
                            isSearching = false
                            searchbarItem = ""
                        })
                    } header: {
                        HStack{
                            Text("My Lists")
                                .font(.title)
                                .foregroundStyle(colorScheme == .dark ? Color(.white) : Color(.black))
                                .padding(.bottom, 5)
                                .bold()
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
                .searchable(text: $searchbarItem, isPresented: $isSearching, placement: .navigationBarDrawer(displayMode: .always), prompt: "Look up something...")
                .onSubmit(of: .search) {
                    showDefinition(searchbarItem)
                    isSearching = false
                    searchbarItem = ""
                }
                
                if !isSearching && !addingNewListAlert{
                    Text("\(Lists.count) lists")
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
            .sheet(isPresented: $showColorPicker) {
                VStack(spacing: 15) {
                    VStack(spacing: 10) {
                        Circle()
                            .fill(Lists[editingListIdex].color.gradient)
                            .shadow(radius: 5, x: 0, y: 0)
                            .frame(width: 100, height: 100)
                            .padding(.vertical, 10)
                            .overlay {
                                Image(systemName: Lists[editingListIdex].icon)
                                    .bold()
                                    .foregroundStyle(colorScheme == .dark ? Color(.white) : Color(.systemGray6))
                                    .font(.system(size: 50))
                            }
                        TextField(Lists[editingListIdex].name, text: $Lists[editingListIdex].name)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Lists[editingListIdex].color)
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
                        selection: $Lists[editingListIdex].color
                    )
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .circular)
                            .fill(
                                Color(colorScheme == .dark ? .systemGray5 : .white)
                            )
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
                                                Lists[editingListIdex].icon = icons[row * 6 + column]
                                            }
                                        if Lists[editingListIdex].icon == icons[row * 6 + column] {
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
            }//sheet
        }
    }
    
    
    func addNewList() -> Void{
        if !newItem.isEmpty {
            Lists.append(list(name: newItem, color: .blue, icon: "List.bullet", element: []))
            newItem = ""
        }
    }
    
//    func deleteList(at offsets: IndexSet) {
//        Lists.remove(atOffsets: offsets)
//    }

    func moveList(from source: IndexSet, to destination: Int) {
        Lists.move(fromOffsets: source, toOffset: destination)
    }
    
    func showDefinition(_ word: String){
        UIApplication
            .shared.connectedScenes.map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.first?
            .rootViewController?.present(UIReferenceLibraryViewController(term: word), animated: true, completion: nil)
    }
    
    func toggleStarred(_ listIndexInLists: Int, _ itemIndex: Int){
        Lists[listIndexInLists].element[itemIndex].starred.toggle()
//        if Lists[listIndexInLists].element[itemIndex].starred && Lists[listIndexInLists].element[itemIndex].done {
//            Lists[listIndexInLists].element[itemIndex].done.toggle()
//        }
    }
    
    func toggleDone(_ listIndexInLists: Int, _ itemIndex: Int){
        Lists[listIndexInLists].element[itemIndex].done.toggle()
//        if Lists[listIndexInLists].element[itemIndex].starred && Lists[listIndexInLists].element[itemIndex].done {
//            Lists[listIndexInLists].element[itemIndex].starred.toggle()
//        }
    }
}


#Preview {
    ContentView()
}
