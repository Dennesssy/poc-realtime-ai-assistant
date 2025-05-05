import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var configStore: ConfigurationStore
    @State private var selectedTab = 0
    @State private var initialPrompt: String = ""
    @State private var showLaunchSuccessMessage = false
    
    func setupAIAssistant() {
        configStore.saveAllConfigurations()  // Calls the new method in ConfigurationStore
       
        // Simulate or perform AI assistant setup (e.g., launch a process or log success)
        // In a real scenario, this could involve additional logic like validating keys.
        print("AI Assistant setup initiated with saved configuration.")
       
        showLaunchSuccessMessage = true  // Toggle the success message
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            EnvironmentVariablesView()
                .tabItem {
                    Label("Environment", systemImage: "gear")
                }
                .tag(0)
            
            PersonalizationView()
                .tabItem {
                    Label("Personalization", systemImage: "person.crop.circle")
                }
                .tag(1)
            
            LaunchView(
                initialPrompt: $initialPrompt,
                showLaunchSuccessMessage: $showLaunchSuccessMessage,
                onLaunch: {
                    let success = configStore.launchAssistant(withInitialPrompt: initialPrompt.isEmpty ? nil : initialPrompt)
                    showLaunchSuccessMessage = success
                    return success
                }
            )
            .tabItem {
                Label("Launch", systemImage: "play.circle")
            }
            .tag(2)
        }
        .padding()
        .frame(minWidth: 650, minHeight: 500)
        .alert("Assistant Launched", isPresented: $showLaunchSuccessMessage) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The AI Assistant has been successfully launched!")
        }
    }
}

struct EnvironmentVariablesView: View {
    @EnvironmentObject private var configStore: ConfigurationStore
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Environment Variables")
                    .font(.largeTitle)
                    .padding(.bottom, 10)
                
                Group {
                    SecureFieldRow(title: "OpenAI API Key:", text: $configStore.openAIApiKey)
                    TextFieldRow(title: "Personalization File:", text: $configStore.personalizationFilePath)
                    TextFieldRow(title: "Scratch Pad Directory:", text: $configStore.scratchPadDir)
                    TextFieldRow(title: "Active Memory File:", text: $configStore.activeMemoryFile)
                    SecureFieldRow(title: "Firecrawl API Key:", text: $configStore.firecrawlApiKey)
                    TextFieldRow(title: "Postgres URL:", text: $configStore.postgresURL)
                    TextFieldRow(title: "SQLite URL:", text: $configStore.sqliteURL)
                    TextFieldRow(title: "DuckDB URL:", text: $configStore.duckdbURL)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button("Save") {
                        configStore.saveEnvVariables()
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }
            .padding()
        }
    }
}

struct PersonalizationView: View {
    @EnvironmentObject private var configStore: ConfigurationStore
    @State private var newURL: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Personalization Settings")
                    .font(.largeTitle)
                    .padding(.bottom, 10)
                
                Group {
                    VStack(alignment: .leading) {
                        Text("Browser URLs:")
                            .bold()
                        
                        List {
                            ForEach(configStore.browserURLs.indices, id: \.self) { index in
                                HStack {
                                    TextField("URL", text: $configStore.browserURLs[index])
                                    Button(action: {
                                        configStore.browserURLs.remove(at: index)
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                        .frame(height: 120)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(4)
                        
                        HStack {
                            TextField("New URL", text: $newURL)
                                .onSubmit {
                                    if !newURL.isEmpty {
                                        configStore.browserURLs.append(newURL)
                                        newURL = ""
                                    }
                                }
                            
                            Button(action: {
                                if !newURL.isEmpty {
                                    configStore.browserURLs.append(newURL)
                                    newURL = ""
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    
                    TextFieldRow(title: "Browser Command:", text: $configStore.browserCommand)
                    TextFieldRow(title: "AI Assistant Name:", text: $configStore.aiAssistantName)
                    TextFieldRow(title: "Human Name:", text: $configStore.humanName)
                    
                    Picker("SQL Dialect:", selection: $configStore.sqlDialect) {
                        Text("DuckDB").tag("duckdb")
                        Text("SQLite").tag("sqlite")
                        Text("PostgreSQL").tag("postgres")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    VStack(alignment: .leading) {
                        Text("System Message Suffix:")
                            .bold()
                        TextEditor(text: $configStore.systemMessageSuffix)
                            .font(.body)
                            .frame(height: 100)
                            .padding(4)
                            .background(Color(.textBackgroundColor))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button("Save") {
                        configStore.savePersonalizationSettings()
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }
            .padding()
        }
    }
}

struct LaunchView: View {
    @Binding var initialPrompt: String
    @Binding var showLaunchSuccessMessage: Bool
    let onLaunch: () -> Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Launch AI Assistant")
                .font(.largeTitle)
                .padding(.bottom, 10)
            
            VStack(alignment: .leading) {
                Text("Initial Prompt (Optional):")
                    .bold()
                TextEditor(text: $initialPrompt)
                    .font(.body)
                    .frame(height: 150)
                    .padding(4)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
            
            Text("This will launch the AI Assistant in a terminal window. The application will continue running in the background even after closing this configuration UI.")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                let success = onLaunch()
                showLaunchSuccessMessage = success
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Launch Assistant")
                }
                .padding()
                .frame(minWidth: 200)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .keyboardShortcut(.return, modifiers: [.command])
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TextFieldRow: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text(title)
                .frame(width: 150, alignment: .trailing)
            TextField("", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct SecureFieldRow: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text(title)
                .frame(width: 150, alignment: .trailing)
            SecureField("", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ConfigurationStore())
}
