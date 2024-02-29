# Network User Interaction Simulation in Haskell

## Overview
This Haskell program simulates user interactions within a network environment, emphasizing concurrency and safe state management. The program uses several data types and concurrent programming techniques to model and manage user interactions.

## Design Decisions

### User and Message Types

#### User Type
The `User` type is central to our simulation, capturing essential aspects of network users:

- **Username**: Serves as a unique identifier for each user.
- **MessageBox (`MVar [Message]`)**: A thread-safe container to store incoming messages for the user. The choice of `MVar` ensures that access and modification of the message list are free from race conditions.
- **OnlineStatus (`MVar Bool`)**: Indicates whether the user is currently online or offline. We use `MVar` to safely encapsulate this mutable state in a concurrent environment.

Our design is minimalist yet sufficient to represent a user's state within the messaging system comprehensively.

#### Message Type
The `Message` type holds the structure of network messages, including the sender's username and the content. This type supports the basic functionality needed for the simulation's messaging requirements.

### Use of MVars
`MVar`s are instrumental in managing state across the concurrent aspects of the simulation:

- **MessageBox**: Ensures that multiple concurrent message transmissions to the same user do not result in data corruption.
- **OnlineStatus**: Enables thread-safe updates and checks of a user's status, a critical feature in the dynamic environment of network simulations.

### RecordWildCards Extension
Utilizing the `RecordWildCards` language extension has greatly simplified the manipulation of record types. It has improved the readability and maintainability of the code, particularly when updating and accessing `User` type fields within functions like `simulateUser`.

### Extension: Online Status Indicator
Implementing an online status indicator posed challenges initially, particularly in handling randomness to reflect user status dynamically. By utilizing `readMVar`, we were able to fetch the current status (`Online` or `Offline`) safely. Subsequent conditional checks are applied to this value to determine the true status of the user.

## Usage

Run the simulation using the following command:

```bash
stack run
