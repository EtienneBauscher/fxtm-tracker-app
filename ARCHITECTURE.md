Below is a comprehensive `ARCHITECTURE.md` file based on the details you provided. This document outlines the architectural decisions, design principles, and technical approaches used in the development of the FXTM App.

---

# Architecture and Design

This document provides an overview of the architectural decisions, design principles, and technical approaches used in the development of the FXTM App. The application is built using Flutter and follows best practices for code structure, state management, and real-time data handling to ensure a robust and scalable solution.

## Table of Contents
- [Architecture and Design](#architecture-and-design)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [State Management](#state-management)
  - [Separation of Concerns](#separation-of-concerns)
  - [Scalability and Extensibility](#scalability-and-extensibility)
  - [Localization](#localization)
  - [Real-time Data Handling](#real-time-data-handling)
  - [UI Design](#ui-design)
  - [Third-party Libraries](#third-party-libraries)
  - [Testing](#testing)
  - [Error Handling](#error-handling)
  - [Performance Optimization](#performance-optimization)
  - [Conclusion](#conclusion)

---

## Introduction
The FXTM App is a Flutter-based application designed to display a list of trading instruments (Major, Minor, and Exotic pairs) sourced from OANDA, with real-time price updates. The app leverages the Finnhub API via WebSocket for live price ticks and a REST API to fetch the list of trading symbols. Its primary goal is to provide a seamless and responsive user experience while efficiently managing frequent data updates.

---

## State Management
The application adopts a single state management approach using **Bloc** but is not cast in stone for future features:
- **Bloc**: Handles simple, widget-level state management with updates triggered via events.

The current utilization of Bloc ensures efficient state handling, minimizing unnecessary widget rebuilds and optimizing performance.

---

## Separation of Concerns
The application is structured to maintain a clear separation of concerns, adhering to **SOLID principles**:
- **UI Layer**: Focuses on rendering the interface using Flutter widgets.
- **Business Logic Layer**: Encapsulates core logic, including data processing and WebSocket management.
- **Data Layer**: Manages interactions with the Finnhub API (REST and WebSocket) and handles data persistence when required.

This modular structure enhances maintainability and allows independent development and testing of each layer.

---

## Scalability and Extensibility
The application is designed for scalability and future growth:
- **Router Service with GoRouter**: A GoRouter-based router service is implemented to support easy addition of new routes and screens as the app evolves, despite currently featuring a single page.
- **Navigation State Object**: A navigation state object manages the app’s navigation stack, simplifying future expansion of navigation flows.
- **Modular Code Structure**: The codebase is organized into modules (e.g., features, services, models), enabling seamless integration of new functionality.

---

## Localization
Localization is primed in the app to support future addition of multiple languages:
- **ARB Files**: Currently only the English Application Resource Bundle (ARB) file exists but extending it to include all of the Flutter supported locales is quick and easy. Also, with a script, all the translations can be handled via Google's translation API.
- **Dynamic Locale Switching**: Once all ARB files have been added and set up with the relevant translations, the app can support runtime locale changes, making it adaptable for international use.

---

## Real-time Data Handling
Real-time price updates are powered by a WebSocket connection to the Finnhub API:
- **Single WebSocket Connection**: Due to API restrictions (one connection at a time), a single WebSocket is maintained.
- **Dynamic Subscriptions**: The app subscribes to up to 50 trading symbols at once, based on the selected category (Major, Minor, or Exotic). For Exotic pairs exceeding this limit, the list is split into two groups, managed via a tab bar.

This ensures compliance with API constraints while delivering real-time updates effectively.

---

## UI Design
The UI is designed for simplicity and responsiveness:
- **Single Page with Tabs**: A bottom navigation bar allows switching between Major, Minor, and Exotic pairs. Exotic pairs use an additional tab bar to toggle between split groups.
- **Price Change Indicators**: Each instrument row shows the current price with visual cues (e.g., color changes) to indicate price increases, decreases, or stability.

This layout provides an intuitive and uncluttered user experience.

---

## Third-party Libraries
Key third-party libraries enhance the app’s functionality:
- **GoRouter**: Manages navigation and routing.
- **Flutter Bloc**: Facilitate state management.
- **WebSocket Channel**: Powers WebSocket connections.
- **DIO**: Handles REST API requests for trading symbol data.
- **Flutter Localizations**: Supports localization and internationalization.
- **GetIt**: Supports location and clean implementation of services via dependecy injection.
- **Freezed**: Powerful for the creation of type safe classes through code generation.

These libraries were chosen for their performance, reliability, and strong community backing.

---

## Testing
A robust testing strategy ensures code quality:
- **Unit Tests**: Validate business logic, including data processing and state management.
- **Test-Driven Development (TDD)**: Applied where feasible, writing tests before implementation to align code with requirements.

This approach minimizes bugs and maintains high standards throughout development.

---

## Error Handling
The app gracefully manages errors to enhance user experience:
- **API Failures**: Catches and communicates REST API errors (e.g., invalid API key).
- **Stream Reconnection**: Automatically attempts to reconnect to the WebSocket if the connection drops.

These measures ensure stability and clear feedback during disruptions.

---

## Performance Optimization
Performance is fine-tuned for efficiency:
- **On-demand Resource Loading**: Loads price empty instruments based on the selected category group. The symbol split into groups takes place, once, from the API response. This reduces UI latency from a rendering perspective. Price ticks becomes available as the subscriptions are made via the WebSocket.

This optimization keeps the app user friendly not having to wait until all initial prices are loaded.

---

## Conclusion
The FXTM App is designed as a robust, scalable, and maintainable solution. By leveraging best practices like separation of concerns, SOLID principles, and efficient state management, it is well-equipped for future enhancements. Features such as real-time data handling, localization, and thorough testing ensure a high-quality user experience, positioning the app for long-term success.

--- 

This `ARCHITECTURE.md` file provides a detailed and structured overview of the Trading Instruments App’s design and implementation, ensuring clarity and alignment with modern development standards.