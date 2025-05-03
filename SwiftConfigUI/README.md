# AI Assistant Configuration UI

A SwiftUI-based macOS application for configuring and launching the Realtime AI Assistant.

## Features

- Configure environment variables
- Customize personalization settings
- Launch the AI assistant with optional initial prompts
- Auto-saving of configuration changes

## Requirements

- macOS 13.0 or later
- Xcode 14.0 or later
- Swift 5.9 or later

## Building the Application

1. Open the SwiftConfigUI directory in Xcode
2. Select the AIAssistantConfig scheme
3. Build and run the application (⌘R)

## Usage

The application provides three main tabs:

1. **Environment**: Configure API keys and file paths
2. **Personalization**: Customize the assistant's behavior and appearance
3. **Launch**: Start the AI assistant with optional initial prompts

All changes are automatically saved to the appropriate configuration files.

## Integration with Python

This SwiftUI app integrates with the Python-based AI assistant by:

1. Reading and writing to the .env file and personalization.json
2. Launching the Python assistant process
3. Providing a user-friendly interface for configuration

## Development

The app is built using the latest SwiftUI 6 features, including:

- Observable macro for state management
- Structured concurrency integration
- Modern SwiftUI navigation and layout APIs
