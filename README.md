# NBA Teams Flutter App

## Overview

This Flutter application provides a comprehensive view of NBA teams and their players. Based on the tutorial by [Mitch Koko](https://www.youtube.com/watch?v=MlvqmRXKXyo), this project has been expanded with additional features and optimizations to create a rich, interactive experience for NBA fans.

## Features

- **Team Listing**: Displays all NBA teams with their logos and conference information.
- **Conference Filtering**: Allows users to filter teams by conference (All, West, East).
- **Player Roster**: Shows detailed player information for each team, including:
  - Jersey number
  - Full name
  - Position
  - Country of origin with flag
- **Dynamic UI**: Custom wave painter for the app header and responsive design.
- **API Integration**: Fetches real-time data from the balldontlie API.
- **Error Handling**: Graceful error management and loading states.

## Technologies Used

### Framework
- **Flutter**: Cross-platform UI toolkit for building natively compiled applications.

### State Management
- **StatefulWidget**: Used for managing the app's state.

### APIs
- **balldontlie API**: Provides NBA teams and players data.

### Packages
- `http`: For making HTTP requests to the API.
- `country_flags`: Displays country flags for player nationalities.
- `path_provider`: Manages local file system access.

## Project Structure

The project follows a modular structure:

- `lib/`
  - `main.dart`: Entry point of the application and main UI.
  - `model/`
    - `player.dart`: Player data model.
    - `team.dart`: Team data model.
  - `assets/`
    - `alpha2.json`: JSON file for country code mappings.
    - `nba.png`: NBA logo asset.


## Usage

Upon launching the app:
1. The main screen displays all NBA teams.
2. Use the filter options at the top to view teams by conference.
3. Tap on a team to view its player roster.
4. In the player roster dialog, you can see detailed information about each player.

## Key Components

- **WavePainter**: Custom painter class for creating the wave effect in the app header.
- **Team and Player Models**: Dart classes for structuring team and player data.
- **API Integration**: `getTeams()` and `getPlayers()` methods for fetching data from the balldontlie API.
- **UI Components**: Custom list tiles for teams and players, with conditional styling based on conference.

## Customization

- Team logos are fetched from a predefined URL pattern. You can modify the `imageUrl` in the `Team.fromJson` factory method to use a different image source.
- The color scheme for conferences (West: blue, East: pink) can be adjusted in the UI code.

## Contributing

Contributions to improve the app are welcome. Please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature.
3. Add your changes and commit them.
4. Push to your fork and submit a pull request.

## License

This project is open-source and available under the [MIT License](LICENSE).

## Acknowledgements

- Original tutorial by [Mitch Koko](https://www.youtube.com/watch?v=MlvqmRXKXyo)
- balldontlie API for providing NBA data
- Flutter and Dart teams for their excellent framework and language

## Contact

For any queries or suggestions, please open an issue in the GitHub repository.

---

Enjoy exploring NBA teams and players! 🏀🏆
