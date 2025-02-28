# BreezeFlow
A decentralized weather and outdoor activities recommendation system built on Stacks blockchain.

## Features
- Store and retrieve weather data on-chain
- Activity recommendations based on weather conditions
- Enhanced user feedback and rating system
- Secure weather data oracle integration
- Temperature validation and bounds checking
- Event logging system

## Contract Functions
### Oracle Management
- Add and remove authorized oracles (owner only)
- Secure weather data submission

### Weather Operations
- Submit weather data (authorized oracles only)
- Get weather conditions for a location
- Temperature validation (-100°F to 150°F)

### Activity Management
- Submit and retrieve activity recommendations
- Rate activities (1-5 scale)
- Get activity ratings and statistics

### Events
- Automatic event logging for important operations
- Traceable weather updates
