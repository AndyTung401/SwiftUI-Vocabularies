//
//  individualListView.swift
//  Vocabularies
//
//  Created by 董承威 on 2024/4/1.
//

import SwiftUI
import Combine

final class KeyboardMonitor: ObservableObject {
    @Published var willShow: Bool = false
    private var cancellables = Set<AnyCancellable>()
    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification, object: nil)
            .sink { _ in
                self.willShow = true
            }
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification, object: nil)
            .sink { _ in
                self.willShow = false
            }
            .store(in: &cancellables)
    }
}

struct IndividualListView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var monitor = KeyboardMonitor()
    @Binding var Lists: [list]
    var listIndexInLists: Int
    @State private var listFilterOption: Int = 0 //0: none, 1: starred, 2: unstarred
    @State private var starredOnTop = false
    @State private var checkedOnBottom = false
    @State private var showCheckedItems = true
    @State private var searchbarItem = ""
    @State private var newItem = ""
    @State private var isSearching = false
    @State private var addingNewWordAlert = false
    @State private var showSortFilterAlert = false
    @State private var editListInfoPopUp = false
    @State private var sortingMode: Int = 0 //0: none, 1: ascending, 2: descending
    
    func sortingBool (_ a: Bool, _ b: Bool, _ method: Int, _ groupingOnTop: Bool) -> Bool {
        if !groupingOnTop {
            return false
        } else if !a && b {
            return true
        } else {
            return false
        }
    }
    
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
    
    func filtering(_ a: list.elementInlist, _ method: Int) -> Bool {
        if !showCheckedItems && a.checked {
            return false
        } else {
            if method == 1 {
                return a.starred
            } else if method == 2 {
                return !a.starred
            } else {
                return true
            }
        }
    }
    
    func showDefinition(_ word: String){
        UIApplication
            .shared.connectedScenes.map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.first?
            .rootViewController?.present(UIReferenceLibraryViewController(term: word), animated: true, completion: nil)
    }
    
    func toggleStarred(_ listIndexInLists: Int, _ itemIndex: Int){
        Lists[listIndexInLists].element[itemIndex].starred.toggle()
    }
    
    func toggleChecked(_ listIndexInLists: Int, _ itemIndex: Int){
        Lists[listIndexInLists].element[itemIndex].checked.toggle()
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(Array(Lists[listIndexInLists].element.enumerated().filter {filtering($0.1, listFilterOption)}.sorted(by: {sorting($0.1, $1.1, sortingMode)}).sorted(by: {sortingBool($0.1.checked, $1.1.checked, listFilterOption, checkedOnBottom)}).sorted(by: {sortingBool(!$0.1.starred, !$1.1.starred, listFilterOption, starredOnTop)})), id: \.element.id) { itemIndex, item in
                    if item.string.contains(searchbarItem) || searchbarItem == ""{
                        HStack {
                            Image(systemName: item.checked ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.checked ? .green : .gray)
                                .font(.system(size: 20))
                                .onTapGesture {
                                    toggleChecked(listIndexInLists, itemIndex)
                                }
                            HStack {
                                Text(item.string)
                                    .opacity(item.checked ? 0.4 : 1)
                                    .strikethrough(item.checked && !item.starred)
                                    .bold(item.starred)
                                    .underline(item.starred)
                                    Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showDefinition(item.string)
                            }
                            Image(systemName: item.starred ? "star.fill" : "star")
                                .foregroundStyle(.yellow)
                                .font(.system(size: item.starred ? 21 : 19))
                                .fontWeight(.thin)
                                .frame(width: 25)
                                .onTapGesture {
                                    toggleStarred(listIndexInLists, itemIndex)
                                }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                toggleChecked(listIndexInLists, itemIndex)
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
                        .alert("Turn off Filter, Grouping, Sorting and Show Checked Items to movme items", isPresented: $showSortFilterAlert) {
                            Button {
                                showSortFilterAlert = false
                            } label: {
                                Text("OK")
                            }
                        }
                    }
                }
                .onMove(perform: { indices, newOffset in
                    if sortingMode != 0 || listFilterOption != 0 {
                        showSortFilterAlert = true
                    }
                    Lists[listIndexInLists].element.move(fromOffsets: indices, toOffset: newOffset)
                    isSearching = false
                    searchbarItem = ""
                })
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .searchable(text: $searchbarItem, isPresented: $isSearching, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for something...")
            .safeAreaInset(edge: .bottom) {
                if !monitor.willShow {
                    Image(systemName: "circle")
                        .font(.system(size: 60))
                        .padding()
                        .opacity(0)
                }
            }
            
            VStack {
                Spacer()
//                if !isSearching && !addingNewWordAlert && !editListInfoPopUp{
                    Text("\(Lists[listIndexInLists].element.count) items")
                        .font(.callout)
                        .foregroundStyle(Color.gray)
                        .padding()
//                }
            }
            .ignoresSafeArea(.keyboard)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        if !searchbarItem.isEmpty {
                            showDefinition(searchbarItem)
                        }
                    } label: {
                        Image(systemName: "book.closed.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.brown.gradient)
                    }
                    .background{
                        Circle()
                            .padding(5)
                            .foregroundStyle(Color(.systemBackground))
                    }
                    .opacity(isSearching ? 1 : 0)
                    .animation(.easeInOut, value: isSearching)
                    Button {
                        if isSearching && !searchbarItem.isEmpty && !Lists[listIndexInLists].element.contains(where: {$0.string == searchbarItem} ) {
                            Lists[listIndexInLists].element.insert(list.elementInlist(string: searchbarItem, starred:false, checked: false), at: 0)
                            searchbarItem = ""
                        } else if !isSearching || isSearching && searchbarItem.isEmpty {
                            addingNewWordAlert = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.cyan.gradient)
                    }
                    .background{
                        Circle()
                            .padding(5)
                            .foregroundStyle(Color(.systemBackground))
                    }
                    .opacity(addingNewWordAlert ? 0 : 1)
                    .animation(!addingNewWordAlert ? .easeInOut(duration: 0.2) : .none, value: addingNewWordAlert)
                    .alert("Add a new item", isPresented: $addingNewWordAlert) {
                        TextField("Enter something", text: $newItem)
                        Button("OK") {
                            if !newItem.isEmpty && !Lists[listIndexInLists].element.contains(where: {$0.string == newItem} ){
                                Lists[listIndexInLists].element.insert(list.elementInlist(string: newItem, starred:false, checked: false), at: 0)
                            }
                            newItem = ""
                        }
                        Button("Cancel", role: .cancel) {
                            addingNewWordAlert = false
                            newItem = ""
                        }
                    }
                }
                .padding()
            }
        }//Zstack
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Menu {
                        Picker(selection: $listFilterOption) {
                            Text("None").tag(0)
                            Text("Show starred only").tag(1)
                            Text("Show NON-starred only").tag(2)
                        } label: {
                            EmptyView()
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        Text("\(["", "Starred only", "NON-starred only"][listFilterOption])")
                    }//filter menu
                    
                    Menu {
                        Button {
                            starredOnTop.toggle()
                        } label: {
                            Label(starredOnTop ? "Ungroup starred items" : "Group starred items", systemImage: starredOnTop ? "square.slash" : "rectangle.3.group")
                        }
                        Button {
                            checkedOnBottom.toggle()
                        } label: {
                            Label(checkedOnBottom ? "Ungroup checked items" : "Group checked items", systemImage: checkedOnBottom ? "square.slash" : "rectangle.3.group")
                        }
                    } label: {
                        Label("Grouping", systemImage: "rectangle.3.group")
                        Text("\(starredOnTop ? "Stars" : "")\(starredOnTop && checkedOnBottom ? " & " : "")\(checkedOnBottom ? "Checkmarks" : "")")
                    }//grouping menu
                    
                    Menu {
                        Picker(selection: $sortingMode) {
                            Text("Manual").tag(0)
                            Text("Ascending (A→Z)").tag(1)
                            Text("Descending (Z→A)").tag(2)
                        } label: {
                            EmptyView()
                        }
                    } label: {
                        Label("Sorting", systemImage: "arrow.up.arrow.down")
                        Text("\(["Manual", "Ascending", "Descending"][sortingMode])")
                    }//sorting menu
                    
                    Divider()
                    
                    Button {
                        showCheckedItems.toggle()
                    } label: {
                        Text("\(showCheckedItems ? "Hide" : "Show") checked items")
                        Image(systemName: showCheckedItems ? "eye.slash" : "eye")
                    }

                    Divider()
                    
                    Button {
                        editListInfoPopUp.toggle()
                        newItem = Lists[listIndexInLists].name
                    } label: {
                        Text("Edit list info")
                        Image(systemName: "info.circle")
                    }
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $editListInfoPopUp){
            EditListInfoPopUp(Lists: $Lists, editingListIndex: listIndexInLists)
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}
