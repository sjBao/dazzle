### Chapter 1: LifeCycle and Flow of a LiveView
- Historically, web applications have been built with a request/response cycle. IE: the client makes a request to the server, the server processes the request and sends a response back to the client.
- As the layers between the client and servers increased in complexity, patterns like MVC (model view contoller) were introduced to help manage the complexity.
- Today, we face even more complexity as we build applications orders of magnitude more interactive and stateful than early web applications.
- Phoenix LiveView is elixir's take on helping programmers build complex, interactive, single-page applications.

### LiveView Main Concepts
- Without going under the hood, the main concept of phoenix liveview involves **CRC: Construct, Reduce, and Convert**.
  - **Construct**: functions like `mount/3` that sets the initial state of our application.
  - **Reduce**: functions like `handle_event/3` that responds to user events and updates the state of the application.
  - **Convert**: functions like `render/1` takes the state and converts it into HTML string (or any other representation).
- Under the hood, LiveView uses a websocket connection to communicate between the client and server. Phoenix takes care  of the real-time update so you as the programmer will not have to write a single line of javascript.

### End of Chapter Question(s):
- Why can’t you simply show a current-time on the web page without first adding the data to the socket?
  - Phoenix needs to establish a connection between the client and the state in our liveview application. Without this connection, Phoenix would not know how to update the client with the most up-to-date state which will cause our clock to remain static.
  



