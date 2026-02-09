# 🎮 Tic-Tac-Toe
A simple yet engaging game of Tic-Tac-Toe built with Flutter using the Dart programming language.

## Table of Contents
1. [Project Description](#project-description)
2. [Installation Instructions](#installation-instructions)
3. [Usage](#usage)
4. [Features](#features)
5. [Contributing Guidelines](#contributing-guidelines)
6. [License](#license)
7. [Author/Contact](#authorcontact)

## Project Description
Tic-Tac-Toe is a first game made in Flutter, a popular framework for building natively compiled applications for mobile, web, and desktop. This game is a classic implementation of the X-O game, where two players take turns marking a square on a 3x3 grid with either an X or an O.

## Installation Instructions
To run this project, follow these steps:
1. **Clone the repository**: `git clone https://github.com/Aniketjamunde9146/Tic-Tac-Toe.git`
2. **Install Flutter**: Download and install the latest version of Flutter from the official [Flutter website](https://flutter.dev/docs/get-started/install).
3. **Install dependencies**: Run `flutter pub get` in the project directory to install the required dependencies.
4. **Run the application**: Use `flutter run` to launch the application on a connected device or emulator.

## Usage
To play the game, simply run the application and start marking squares with X or O. The game will automatically switch between players and declare a winner or a draw.

### Example Code
```dart
// Create a new game board
GameBoard board = GameBoard();

// Make a move
board.makeMove(0, 'X');

// Get the current state of the board
List<String> currentState = board.getCurrentState();
```

## Features
* **Simple and intuitive gameplay**: Easy to understand and play, with a clean and minimalistic design.
* **Automatic player switching**: The game automatically switches between players after each move.
* **Win and draw detection**: The game detects when a player has won or when the game is a draw.
* **Responsive design**: The game is optimized for various screen sizes and devices.

## Contributing Guidelines
To contribute to this project, please follow these steps:
1. **Fork the repository**: Create a fork of the repository on GitHub.
2. **Create a new branch**: Create a new branch for your feature or bug fix.
3. **Make changes**: Make the necessary changes to the code.
4. **Submit a pull request**: Submit a pull request to the main repository.

## License
This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

## Author/Contact
* **GitHub Repository**: [https://github.com/Aniketjamunde9146/Tic-Tac-Toe](https://github.com/Aniketjamunde9146/Tic-Tac-Toe)
* **Stars**: 0
* **Forks**: 0
* **Author**: Aniket Jamunde
* **Contact**: [Aniket Jamunde](https://github.com/Aniketjamunde9146)

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
