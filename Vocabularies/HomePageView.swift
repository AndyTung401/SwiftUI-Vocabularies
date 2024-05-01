//
//  File.swift
//  Translator
//
//  Created by 董承威 on 2024/2/18.
//

import SwiftUI
import ColorGrid

extension Color {
    static subscript(name: String) -> Color {
        switch name {
            case "red":
                return Color.red
            case "orange":
                return Color.orange
            case "yellow":
                return Color.yellow
            case "green":
                return Color.green
            case "cyan":
                return Color.cyan
            case "blue":
                return Color.blue
            case "indigo":
                return Color.indigo
            case "pink":
                return Color.pink
            case "purple":
                return Color.purple
            case "brown":
                return Color.brown
            case "gray":
                return Color.gray
            case "pink2":
                return Color(.init(red: 0.8196078431, green: 0.6588235294, blue: 0.6235294118))
            default:
                return Color.accentColor
        }
    }
}

extension String {
    static subscript(name: Color) -> String {
        switch name {
        case .red:
                return "red"
        case .orange:
                return "orange"
        case .yellow:
                return "yellow"
            case .green:
                return "green"
            case .cyan:
                return "cyan"
            case .blue:
                return "blue"
            case .indigo:
                return "indigo"
            case .pink:
                return "pink"
            case .purple:
                return "purple"
            case .brown:
                return "brown"
            case .gray:
                return "gray"
            case Color(.init(red: 0.8196078431, green: 0.6588235294, blue: 0.6235294118)):
                return "pink2"
            default:
                return "red"
        }
    }
}

struct list: Hashable, Identifiable, Codable {
    var id = UUID()
    var name: String
    var color: String
    var icon: String
    var element: [elementInlist]
    
    struct elementInlist: Hashable, Identifiable, Codable {
        var id = UUID()
        var string: String
        var starred: Bool
        var checked: Bool
    }
}

let icons = ["list.bullet", "bookmark.fill", "mappin", "graduationcap.fill", "backpack.fill", "pencil.and.ruler.fill", "doc.fill", "book.fill", "note.text", "textformat.alt", "highlighter", "book.pages.fill"]


struct HomePageView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.editMode) private var editMode
    let userDefaults = UserDefaults.standard
    @State private var searchbarItem = ""
    @State private var isSearching = false
    @State private var newItem = ""
    @State private var showDict = false
    @State private var showPopUp = false
    @State private var editingListIndex: Int = 0
    @State private var selectedColor = Color.red
    @State var Lists: [list] = [list(name: "An example list", color: "blue", icon: "list.bullet", element: [list.elementInlist(string: "This is a sample list", starred: false, checked: false),
                                                                                                           list.elementInlist(string: "Swipe left to remove/star an item", starred: false, checked: false),
                                                                                                           list.elementInlist(string: "Swipe right to chack an item", starred: false, checked: false),
                                                                                                           list.elementInlist(string: "Tap and Hold to rearrange", starred: false, checked: false),
                                                                                                           list.elementInlist(string: "↓ Tap on it for definitions", starred: false, checked: false),
                                                                                                           list.elementInlist(string: "Apple", starred: false, checked: false),
                                                                                                           list.elementInlist(string: "Try the search bar", starred: false, checked: false)]),
                                list(name: "Tap on the icon to customize", color: "orange", icon: "mappin", element: [list.elementInlist(string: "Constitude", starred: false, checked: false),
                                                                                                                     list.elementInlist(string: "Provision", starred: false, checked: false),
                                                                                                                     list.elementInlist(string: "Convince", starred: false, checked: false),
                                                                                                                     list.elementInlist(string: "Appropriate", starred: false, checked: false),
                                                                                                                     list.elementInlist(string: "Delegate", starred: false, checked: false),
                                                                                                                     list.elementInlist(string: "Adequate", starred: false, checked: false),
                                                                                                                     list.elementInlist(string: "Seduce", starred: false, checked: false),
                                                                                                                     list.elementInlist(string: "Abbreviate", starred: false, checked: false)])]
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        ForEach(Array(Lists.enumerated()), id: \.element.id) { listIndex, list in
                                NavigationLink{
                                    IndividualListView(Lists: $Lists, listIndexInLists: listIndex)
                                        .navigationTitle(list.name)
                                } label: {
                                    HStack {
                                        Image(systemName: "circle.fill")
                                            .foregroundStyle(Color[list.color])
                                            .font(.largeTitle)
                                            .overlay {
                                                Image(systemName: list.icon)
                                                    .font(.headline)
                                                    .foregroundStyle(.white)
                                            }
                                            .padding(-1)
                                            .padding(.leading, -3)
                                            .onTapGesture {
                                                editingListIndex = listIndex
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
                            Text("\(editingListIndex)")
                                .foregroundStyle(colorScheme == .dark ? Color(.black) : Color(.systemGray6))
                            Spacer()
                            Button {
                                editingListIndex = 0
                                Lists.insert(list(name: "New List", color: "red", icon: "list.bullet", element: []), at: 0)
                                saveData()
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
                
//                if !isSearching {
                    Text("\(Lists.count) lists")
                        .font(.callout)
                        .foregroundStyle(Color.gray)
                        .padding()
//                }
            }//Vstack
            .background(colorScheme == .dark ? Color.black : Color(UIColor.systemGray6))
            .ignoresSafeArea(.keyboard)
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
        .onAppear{
            getSavedData()
        }
        .onChange(of: Lists, saveData)
        .sheet(isPresented: $showPopUp) {
            EditListInfoPopUp(Lists: $Lists, editingListIndex: editingListIndex)
        }//sheet
    }

    func moveList(from source: IndexSet, to destination: Int) {
        Lists.move(fromOffsets: source, toOffset: destination)
    }
    
    func showDefinition(_ word: String){
        UIApplication
            .shared.connectedScenes.map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.first?
            .rootViewController?.present(UIReferenceLibraryViewController(term: word), animated: true, completion: nil)
    }
    
    func saveData() {
        do {
            let jsonData = try JSONEncoder().encode(Lists)
//                                    let jsonString = String(data: jsonData, encoding: .utf8)!
            UserDefaults.standard.set(jsonData, forKey: "Lists")
            
            if let savedModel = UserDefaults.standard.value(forKey: "Lists") as? Data {
                if let decodedData = try? JSONDecoder().decode([list].self, from: savedModel) {
//                    print(decodedData)
                    Lists = decodedData
                }
            }
        } catch { print(error) }
    }
    
    func getSavedData() {
        do {
            if let savedModel = UserDefaults.standard.value(forKey: "Lists") as? Data {
                if let decodedData = try? JSONDecoder().decode([list].self, from: savedModel) {
                    Lists = decodedData
                }
            }
        }
    }
}


#Preview {
    HomePageView()
}
