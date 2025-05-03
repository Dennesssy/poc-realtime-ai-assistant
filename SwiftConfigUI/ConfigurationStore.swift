import Foundation
import Combine

class ConfigurationStore: ObservableObject {
    // Environment variables
    @Published var openAIApiKey: String = ""
    @Published var personalizationFilePath: String = "./personalization.json"
    @Published var scratchPadDir: String = "./scratchpad"
    @Published var activeMemoryFile: String = "./active_memory.json"
    @Published var firecrawlApiKey: String = ""
    @Published var postgresURL: String = ""
    @Published var sqliteURL: String = "./db/mock_sqlite.db"
    @Published var duckdbURL: String = "./db/mock_duck.duckdb"
    
    // Personalization settings
    @Published var browserURLs: [String] = []
    @Published var browserCommand: String = "open -a 'Google Chrome'"
    @Published var aiAssistantName: String = "Ada"
    @Published var humanName: String = "Dan"
    @Published var sqlDialect: String = "duckdb"
    @Published var systemMessageSuffix: String = ""
    
    // File paths
    private let envFilePath: String
    private let personalizationPath: String
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Construct paths relative to the app's working directory
        let baseDir = FileManager.default.currentDirectoryPath
        self.envFilePath = "\(baseDir)/.env"
        self.personalizationPath = "\(baseDir)/personalization.json"
        
        // Load settings
        loadEnvVariables()
        loadPersonalizationSettings()
        
        // Set up automatic saving
        setupAutosave()
    }
    
    private func setupAutosave() {
        // Debounce changes and save automatically
        Publishers.MergeMany(
            $openAIApiKey.dropFirst(),
            $personalizationFilePath.dropFirst(),
            $scratchPadDir.dropFirst(),
            $activeMemoryFile.dropFirst(),
            $firecrawlApiKey.dropFirst(),
            $postgresURL.dropFirst(),
            $sqliteURL.dropFirst(),
            $duckdbURL.dropFirst()
        )
        .debounce(for: .seconds(1), scheduler: RunLoop.main)
        .sink { [weak self] _ in
            self?.saveEnvVariables()
        }
        .store(in: &cancellables)
        
        Publishers.MergeMany(
            $browserCommand.dropFirst(),
            $aiAssistantName.dropFirst(),
            $humanName.dropFirst(),
            $sqlDialect.dropFirst(),
            $systemMessageSuffix.dropFirst()
        )
        .debounce(for: .seconds(1), scheduler: RunLoop.main)
        .sink { [weak self] _ in
            self?.savePersonalizationSettings()
        }
        .store(in: &cancellables)
        
        // Observe browserURLs as a whole for changes
        $browserURLs
            .dropFirst()
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.savePersonalizationSettings()
            }
            .store(in: &cancellables)
    }
    
    func loadEnvVariables() {
        do {
            let fileExists = FileManager.default.fileExists(atPath: envFilePath)
            let envContent = fileExists ? try String(contentsOfFile: envFilePath) : ""
            
            // Parse .env file
            let lines = envContent.components(separatedBy: .newlines)
            for line in lines {
                let parts = line.split(separator: "=", maxSplits: 1)
                if parts.count == 2 {
                    let key = String(parts[0])
                    let value = String(parts[1])
                    
                    switch key {
                    case "OPENAI_API_KEY": openAIApiKey = value
                    case "PERSONALIZATION_FILE": personalizationFilePath = value
                    case "SCRATCH_PAD_DIR": scratchPadDir = value
                    case "ACTIVE_MEMORY_FILE": activeMemoryFile = value
                    case "FIRECRAWL_API_KEY": firecrawlApiKey = value
                    case "POSTGRES_URL": postgresURL = value
                    case "SQLITE_URL": sqliteURL = value
                    case "DUCKDB_URL": duckdbURL = value
                    default: break
                    }
                }
            }
        } catch {
            print("Error loading .env file: \(error)")
        }
    }
    
    func saveEnvVariables() {
        let envContent = """
        OPENAI_API_KEY=\(openAIApiKey)
        PERSONALIZATION_FILE=\(personalizationFilePath)
        SCRATCH_PAD_DIR=\(scratchPadDir)
        ACTIVE_MEMORY_FILE=\(activeMemoryFile)
        FIRECRAWL_API_KEY=\(firecrawlApiKey)
        POSTGRES_URL=\(postgresURL)
        SQLITE_URL=\(sqliteURL)
        DUCKDB_URL=\(duckdbURL)
        """
        
        do {
            try envContent.write(toFile: envFilePath, atomically: true, encoding: .utf8)
            print("Environment variables saved successfully")
        } catch {
            print("Error saving .env file: \(error)")
        }
    }
    
    func loadPersonalizationSettings() {
        do {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: personalizationPath))
            let personalization = try JSONDecoder().decode(PersonalizationSettings.self, from: jsonData)
            
            self.browserURLs = personalization.browser_urls
            self.browserCommand = personalization.browser_command
            self.aiAssistantName = personalization.ai_assistant_name
            self.humanName = personalization.human_name
            self.sqlDialect = personalization.sql_dialect
            self.systemMessageSuffix = personalization.system_message_suffix
        } catch {
            print("Error loading personalization settings: \(error)")
        }
    }
    
    func savePersonalizationSettings() {
        let settings = PersonalizationSettings(
            browser_urls: browserURLs,
            browser_command: browserCommand,
            ai_assistant_name: aiAssistantName,
            human_name: humanName,
            sql_dialect: sqlDialect,
            system_message_suffix: systemMessageSuffix
        )
        
        do {
            let jsonData = try JSONEncoder().encode(settings)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            try jsonString.write(toFile: personalizationPath, atomically: true, encoding: .utf8)
            print("Personalization settings saved successfully")
        } catch {
            print("Error saving personalization settings: \(error)")
        }
    }
    
    func launchAssistant(withInitialPrompt prompt: String? = nil) -> Bool {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        
        let promptArgs = prompt != nil ? ["--prompts", prompt!] : []
        task.arguments = ["python", "-m", "src.realtime_api_async_python.main"] + promptArgs
        
        do {
            try task.run()
            return true
        } catch {
            print("Error launching assistant: \(error)")
            return false
        }
    }
    
    func resetToDefaults() {
        // Reset environment variables
        openAIApiKey = ""
        personalizationFilePath = "./personalization.json"
        scratchPadDir = "./scratchpad"
        activeMemoryFile = "./active_memory.json"
        firecrawlApiKey = ""
        postgresURL = ""
        sqliteURL = "./db/mock_sqlite.db"
        duckdbURL = "./db/mock_duck.duckdb"
        
        // Reset personalization
        browserURLs = ["https://google.com", "https://chat.openai.com", "https://claude.ai/chat"]
        browserCommand = "open -a 'Google Chrome'"
        aiAssistantName = "Ada"
        humanName = "User"
        sqlDialect = "duckdb"
        systemMessageSuffix = "Keep all of your responses ultra short."
        
        // Save changes
        saveEnvVariables()
        savePersonalizationSettings()
    }
}

struct PersonalizationSettings: Codable {
    var browser_urls: [String]
    var browser_command: String
    var ai_assistant_name: String
    var human_name: String
    var sql_dialect: String
    var system_message_suffix: String
}
