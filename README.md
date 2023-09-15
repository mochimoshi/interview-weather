# Weather (Interview)

Alex Wang (alex@milktea.io)

## Features

* Get weather for a location (accepts addresses, neighborhoods, cities, postalcodes)
* Show current weather condition, temperatures (current, high, low, feels like) in either Fahrenheit or Celcius, depending on the user's locale
* Save the last 10 searched locations to easily access weather again. Weather data is cached if retrieved within the last 15 minutes
* Support dark mode, dynamic type, rotation, etc

### Technologies Used

Include:
* UIKit and SwiftUI
* Swift's async/await pattern
* Combine framework
* Core Data
* Core Location

## Things Todo

* More user friendly error messages
* Autocomplete/typeahead for location names (and giving choices when there are ambiguities - e.g. London England vs London Ontario)
* Writing unit tests
* Clearing individual / all weather entries
* Having one central place for strings for localization

## Third party libraries used

* https://github.com/AsyncSwift/AsyncLocationKit , to simplify usage of CoreLocation by wrapping delegate methods into the new concurrency model
* https://github.com/leoz/CachedImage , due to a bug in AsyncImage in Lists / UITableViews prematurely cancelling the first load of an image (see comments in code.)
