# FW/1 & CFMigrations Example
An example of using CFMigrations as a Subsystem in an FW/1 application.

## Requirements

* Lucee 5.x+
* ACF 2016+ (With some tweaking. See note below.)
* FW/1 4.x+

> NOTE: This example application has been setup to run on Lucee 5.3 with an H2 database. You will need to do some tweaking to use a different engine/db.

## Installation

### CommandBox

- Make sure you have [Commandbox installed](https://commandbox.ortusbooks.com/content/setup/installation.html).
- Clone the repo or drop the zipped contents into a directory.
- Fire up Commandbox by entering `box` in your terminal and `cd` into the project root directory.
- Run `install && start`.
- Start hacking away!

## Usage

From the project root, start CommandBox in your preferred terminal. Make sure you have included the test dependencies project dependencies by running `install`. Start the server by executing `server start`. The server instance will be located at `http://127.0.0.1:8520`.

### Running The Application

Once the server has started, you will have a simple FW/1 application to navigate through.

### Running Tests With CommandBox & TestBox

TODO: Update test cases.

Once the server has started, you can run `testbox run` in the terminal to execute the tests. To view the test results in the browser, you can navigate to `http://127.0.0.1:8520/tests/runner.cfm`.
