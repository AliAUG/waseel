# Google Maps Setup

To enable the map feature, add your Google Maps API key:

## Android
1. Get an API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable "Maps SDK for Android"
3. Open `android/app/src/main/AndroidManifest.xml`
4. Replace `YOUR_GOOGLE_MAPS_API_KEY` with your key

## iOS
1. Add your key to `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

// In didFinishLaunchingWithOptions, before return:
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```
