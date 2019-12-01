# Magic-mirror-backend
<img src="https://github.com/itggot-adrian-almetunsmeds/magic-mirror-backend/workflows/Ruby/badge.svg" alt="Build status">
<img src="https://github.com/itggot-adrian-almetunsmeds/magic-mirror-backend/workflows/Docs/badge.svg" alt="Docs status">
<br>
The backend source code for a magic mirror
<br>
<br>

## Setup

### Google Calendar

1. Navigate to [developers.google.com](https://console.developers.google.com/)
2. Create a project
3. Under the credentials tab click Create credentials and select OAuth Client ID
4. Under application type select Other and if required fill in information
5. Press the download button and save the file as ``` credentials.json ``` in the root directory

## Running

```
§ rackup
```
or using rerun

```
§ rerun rackup
```
## Errors

Error message: ``` Unable to load the EventMachine C extension; To use the pure-ruby reactor, require 'em/pure_ruby' ```
Solution: On Windows do ``` gem uninstall eventmachine``` and then ``` gem install eventmachine --platform=ruby```

## Documentation

#### See [Github-docs](https://itggot-adrian-almetunsmeds.github.io/magic-mirror-backend/index.html)
# Developer?
## Updating documentation locally

NOTE The documentation is automatically updated when commiting to the master
```
require 'yard'
```
Command to run in the terminal in order to update the documentation.
```
§ yard doc *
```

## Running tests
```
require 'rspec'
```
To run the tests use either
```
§ rake test
```
or
```
§ rspec
```
