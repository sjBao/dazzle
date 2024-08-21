### LiveView Events
Main Concepts:
- Receives the event
- Changes the state
- Renders based on the state

### LiveView Event Infrastructure
- Initial Page Loads
 - Sets up framework JavaScript (websockets, etc)
- Change detected on Client (browser)
  - Framework JS sends message to Phoenix Socket
  - Phoenix pass message to LiveView Process as OTP Message  (every LiveView process is a GenServer)
  - LiveView `handle_cast` callback passes a message to `handle_event` callback

### `handle_event/3`
- The event: a string
- event-metadata: ie: a form validation sends form content in the form of metadata.
- socket: data for the live view.

Each `handle_event` function is just a function is essentially a reducer that takes in some metadata with current socket data and returns the new socket data (the state of the liveview).

### `render`
Only returns the difference between this render and the last one.

