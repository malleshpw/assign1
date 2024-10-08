import SwiftUI

struct Location: Codable, Identifiable {
    var id: Int
    var name: String
    var category: String
    var city: String
    var state: String
    var park: String
    var description: String
    var imageName: String
    var isCompleted: Bool
    
    var image: Image {
        Image(imageName)
    }
}

class LocationViewModel: ObservableObject {
    @Published var locations: [Location] = []
    
    init() {
        load()
    }
    
    func load() {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("locationData.json")
            
            if fileManager.fileExists(atPath: fileURL.path) {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let decodedLocations = try JSONDecoder().decode([Location].self, from: data)
                    self.locations = decodedLocations
                    print("Loaded data from Documents directory.")
                } catch {
                    print("Error loading JSON data from Documents: \(error)")
                }
            } else {
          
                if let bundleURL = Bundle.main.url(forResource: "locationData", withExtension: "json") {
                    do {
                        let data = try Data(contentsOf: bundleURL)
                        let decodedLocations = try JSONDecoder().decode([Location].self, from: data)
                        self.locations = decodedLocations
                        print("Loaded data from app bundle.")
                    } catch {
                        print("Error loading JSON data from bundle: \(error)")
                    }
                }
            }
        }
    }
    

    func save() {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("locationData.json")
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: fileURL)
                print("Saved data to \(fileURL)")
            } catch {
                print("Error saving JSON data: \(error)")
            }
        }
    }

    func toggleCompletion(for location: Location) {
        if let index = locations.firstIndex(where: { $0.id == location.id }) {
            locations[index].isCompleted.toggle()
            save()
        }
    }
}


struct StarView: View {
    @ObservedObject var viewModel: LocationViewModel
    var location: Location
    
    var body: some View {
        Image(systemName: location.isCompleted ? "star.fill" : "star")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(location.isCompleted ? .yellow : .gray)
            .onTapGesture {
                
                viewModel.toggleCompletion(for: location)
            }
    }
}


struct ContentView: View {
    @ObservedObject var viewModel = LocationViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.locations) { location in
                NavigationLink(destination: LocationDetailView(location: location, viewModel: viewModel)) {
                    HStack {
                    
                        location.image
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(location.name)
                                .font(.headline)
                            Text(location.park)
                                .font(.subheadline)
                        }
                        Spacer()
                        
                      
                        StarView(viewModel: viewModel, location: location)
                    }
                }
            }
            .navigationTitle("Locations")
        }
    }
}


struct LocationDetailView: View {
    var location: Location
    @ObservedObject var viewModel: LocationViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                
                Color(location.isCompleted ? .green : .red)
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            location.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                                .frame(width: 250, height: 250)
                                .offset(y: 125)
                        }
                    )
                    .padding(.bottom, 125)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text(location.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(location.park)
                        Spacer()
                        Text(location.state)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text("About \(location.name)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(location.description)
                        .font(.body)
                    
                    HStack {
                        StarView(viewModel: viewModel, location: location)
                        Text(location.isCompleted ? "Completed" : "Not Completed")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

