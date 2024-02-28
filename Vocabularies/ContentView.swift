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
    @State private var addingNewWordAlert = false
    @State private var showDict = false
    @State private var sortingMode: Int = 0 //0: none, 1: ascending, 2: descending
    @State private var showPopUp = false
    @State private var editingListIdex: Int = 0
    @State private var selectedFilterOptions: Set<Int> = []//0: starred, 1: done, 2: starred and done
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
    
    
    func sorting(_ a: list.elementInlist, _ b: list.elementInlist, _ method: Int) -> Bool {
        if method == 0 {
            return false
        } else if method == 1 {
            return a.string < b.string
        } else if method == 2 {
            return a.string > b.string
        } else {
            return false
        }
    }
    
    func filtering(_ a: list.elementInlist, _ method: Set<Int>) -> Bool {
        if method.isEmpty{
            return true
        } else if method.contains(0) {
            if method.contains(1) {
                return a.starred || a.done
            } else {
                return a.starred
            }
        } else if method.contains(1) {
            return a.done
        } else if method.contains(2) {
            return a.starred && a.done
        }
        else {
            return false
        }
    }
    
    func createListView(listIndexInLists: Int) -> some View {
        ZStack {
            List {
                ForEach(Array(Lists[listIndexInLists].element.filter {filtering($0, selectedFilterOptions)} .sorted(by: {sorting($0, $1, sortingMode)}).enumerated()), id: \.element.id) { itemIndex, item in
                    if item.string.contains(searchbarItem) || searchbarItem == ""{
                        HStack {
                            Image(systemName: item.done ? "checkmark.circle.fill" : "circle").foregroundStyle(item.done ? .green : .gray)
                                .font(.system(size: 20))
                                .onTapGesture {
                                    toggleDone(listIndexInLists, itemIndex)
                                }
                            HStack{
                                Text(item.string)
                                    .opacity(item.done ? 0.4 : 1)
                                    .strikethrough(item.done)
                                    Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showDefinition(item.string)
                            }
                            Image(systemName: item.starred ? "star.fill" : "star").foregroundStyle(Color.yellow)
                                .font(.system(size: 20))
                                .fontWeight(.light)
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
            .listStyle(.plain)
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
                        if isSearching && !searchbarItem.isEmpty && !Lists[listIndexInLists].element.contains(where: {$0.string == searchbarItem} ) {
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
                    .alert("Append a new item", isPresented: $addingNewWordAlert) {
                        TextField("Enter something", text: $newItem)
                        Button("OK") {
                            if !newItem.isEmpty && !Lists[listIndexInLists].element.contains(where: {$0.string == newItem} ){
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
        .animation(addingNewWordAlert == false ? .easeInOut(duration: 0.2) : .none, value: addingNewWordAlert)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Menu {
                        Button {
                            sortingMode = 0
                        } label: {
                            Text("Manual")
                            if sortingMode == 0 {
                                Image(systemName: "checkmark")
                            }
                        }
                        Button {
                            sortingMode = 1
                        } label: {
                            if sortingMode == 1 {
                                Image(systemName: "checkmark")
                            }
                            Text("Ascending")
                        }
                        Button {
                            sortingMode = 2
                        } label: {
                            if sortingMode == 2 {
                                Image(systemName: "checkmark")
                            }
                            Text("Descending")
                        }
                    } label: {
                        Label("Sort by", systemImage: "arrow.up.arrow.down")
                        Text("\(["Manual", "Ascending", "Descending"][sortingMode])")
                    }
                    
                    Menu {
                        Button {
                            if selectedFilterOptions.contains(0) {
                                selectedFilterOptions.remove(0)
                            } else {
                                selectedFilterOptions.remove(2)
                                selectedFilterOptions.insert(0)
                            }
                        } label: {
                            Text("Starred")
                            if selectedFilterOptions.contains(0) {
                                Image(systemName: "checkmark")
                            }
                        }
                        Button {
                            if selectedFilterOptions.contains(1) {
                                selectedFilterOptions.remove(1)
                            } else {
                                selectedFilterOptions.remove(2)
                                selectedFilterOptions.insert(1)
                            }
                        } label: {
                            Text("Done")
                            if selectedFilterOptions.contains(1) {
                                Image(systemName: "checkmark")
                            }
                        }
                        Button {
                            if selectedFilterOptions.contains(2) {
                                selectedFilterOptions.remove(2)
                            } else {
                                selectedFilterOptions.remove(0)
                                selectedFilterOptions.remove(1)
                                selectedFilterOptions.insert(2)
                            }
                        } label: {
                            Text("Starred AND Done")
                            if selectedFilterOptions.contains(2) {
                                Image(systemName: "checkmark")
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        ForEach(Array(Lists.enumerated()), id: \.element.id) { listIndex, list in
                                NavigationLink{
                                    createListView(listIndexInLists: listIndex)
                                        .navigationTitle(list.name)
                                } label: {
                                    HStack {
                                        Image(systemName: "circle.fill")
                                            .foregroundStyle(list.color)
                                            .font(.largeTitle)
                                            .overlay {
                                                Image(systemName: list.icon)
                                                    .font(.headline)
                                                    .foregroundStyle(.white)
                                            }
                                            .padding(-1)
                                            .padding(.leading, -3)
                                            .onTapGesture {
                                                editingListIdex = listIndex
                                                showPopUp = true
                                            }//on tap gesture
                                        Text(list.name)
                                            .font(.body)
                                        Spacer()
                                        Text("\(Lists[listIndex].element.count)")
                                            .foregroundStyle(.gray)
                                    }//Hstack
                                    .swipeActions(allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            Lists.remove(at: listIndex)
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }//swipe actions
                                    .sheet(isPresented: $showPopUp) {
                                        VStack(spacing: 15) {
                                            VStack(spacing: 10) {
                                                Circle()
                                                    .fill(Lists[editingListIdex].color.gradient)
                                                    .shadow(color: colorScheme == .dark ? Color(white: 0, opacity: 0.33) : Lists[editingListIdex].color.opacity(0.3), radius: 10, x: 0, y: 0)
                                                    .frame(width: 100, height: 100)
                                                    .padding(.vertical, 10)
                                                    .animation(.easeInOut(duration: 0.2), value: Lists[editingListIdex].color)
                                                    .overlay {
                                                        Image(systemName: Lists[editingListIdex].icon)
                                                            .bold()
                                                            .foregroundStyle(colorScheme == .dark ? Color(.white) : Color(.systemGray6))
                                                            .font(.system(size: 50))
                                                            .animation(.easeInOut(duration: 0.1), value: Lists[editingListIdex].icon)
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
                            Text("\(editingListIdex)")
                                .foregroundStyle(colorScheme == .dark ? .black : .white)
                            Spacer()
                            Button {
                                editingListIdex = Lists.count
                                Lists.append(list(name: "New List", color: .red, icon: "list.bullet", element: []))
                                showPopUp.toggle()
                            } label: {
                                Image(systemName: "plus")
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
                
                if !isSearching {
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
            
        }
    }

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
    }
    
    func toggleDone(_ listIndexInLists: Int, _ itemIndex: Int){
        Lists[listIndexInLists].element[itemIndex].done.toggle()
    }
}


#Preview {
    ContentView()
}
