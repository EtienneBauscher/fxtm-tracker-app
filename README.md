# FXTM App

This Flutter application displays a list of trading instruments from OANDA, categorized into Major, Minor, and Exotic pairs. It features real-time price updates via a WebSocket connection to the Finnhub API, with visual indicators for price changes.

## Setup Instructions

To set up the project, ensure you have the following installed:

- **[Lefthook](https://github.com/evilmartians/lefthook)**: For managing Git hooks.
- **[FVM (Flutter Version Management)](https://fvm.app/)**: For managing Flutter SDK versions.

Additionally, create a `.env.development` file in the root directory with the following content:

```
forexBaseUrl=https://finnhub.io/api/v1
apiKey=*****insert-your-own-api-key
finnhubws=ws.finnhub.io
scheme=wss
```

Replace `*****insert-your-own-api-key` with your actual Finnhub API key.

Be sure to run the following commands to build all the neccessary items for the project

```
fvm flutter clean
```
```
fvm flutter pub get
```
```
fvm dart run build_runner build --delete-conflicting-outputs
```


## Running the App

Please insert your respective deviceIds in the `launch.json` and select the device you want to run the app on. 
To run the app, use the following command or use the debugger if you are using VSCode:

```
fvm flutter run --dart-define=ENV=development
```

Make sure you have the correct Flutter version installed via FVM.

## Testing

- Unit tests are implemented for business logic.

To run tests, use:

```
fvm flutter test
```

## Architecture and Design

For a detailed explanation of the architecture, design decisions, state management approach, and third-party libraries used, please refer to [ARCHITECTURE.md](ARCHITECTURE.md).

## Additional Notes

- The Finnhub WebSocket allows only one connection at a time and has a subscription limit of 50 symbols. The app manages subscriptions dynamically based on the selected pair category.
- Ensure a stable internet connection for real-time data updates.
- An error can be forced with erractic selection of different tabs. This will cause an exception as the connection can not be upgraded to a WebSocket. This error was dealt with gracefully and will inform the user to wait for a couple of seconds before navigating again