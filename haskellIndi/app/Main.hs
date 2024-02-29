{-# LANGUAGE RecordWildCards #-}
module Main where

import Control.Concurrent
import Control.Monad
import System.Random

-- A User in the newtwork
data User = User
  { username :: String
  , messageBox :: MVar [Message]
  , onlineStatus :: MVar Bool -- added filed to know the online status
  } deriving (Eq)

-- Messages sent between users
data Message = Message
  { fromUser :: String
  , content :: String
  } deriving (Show)

-- Create a new user with a given username
newUser :: String -> IO User
newUser name = do
  mbox <- newMVar []
  online <- newMVar True -- initially setting the user as online
  return User { username = name, messageBox = mbox, onlineStatus = online }

-- Simulate a user by randomly sending messages to other users
simulateUser :: User -> [User] -> IO ()
simulateUser sender@User{..} others = forever $ do 
  -- Randomly updating online status
  online <- randomIO :: IO Bool
  modifyMVar_ onlineStatus (\_ -> return online)

  --Proceed only if the user is online
  isOnline <- readMVar onlineStatus
  when isOnline $ do
    idx <- randomRIO (0, length others - 1)
    let receiver = others !! idx 
    
  -- create a random message
    message <- generateRandomMessage sender

  -- send the message
    sendMessage receiver message

  -- wait for a random interval
    delay <- randomRIO (1,5)
    threadDelay (delay * 1000000) 

-- generate a random message from a user
generateRandomMessage :: User -> IO Message
generateRandomMessage User{..} = do
  let msgContent = "Hello from " ++ username
  return Message { fromUser = username, content = msgContent }

-- send a message to a user
sendMessage :: User -> Message -> IO ()
sendMessage User{..} message = do
  messages <- takeMVar messageBox
  putMVar messageBox (message:messages)

-- get the number of messages a user has received
getMessageCount :: User -> IO Int
getMessageCount User{..} = do
  messages <- readMVar messageBox
  return $ length messages

-- main function
main :: IO ()
main = do
--create 10 users
  users <- mapM newUser ["Kaushik", "Spirit", "Skor", "Shlok", "Anik", "Jack", "Sam", "Razin", "Ayat", "Khan"] 

-- user interactions
  mapM_ (\user -> forkIO $ simulateUser user (filter (/= user) users)) users

-- wait till 100 messages have been sent in total
  waitTillMessageSent users 100

-- output 
  mapM_ (\user -> do
            count <- getMessageCount user
            online <- readMVar (onlineStatus user)
            let status = if online then "Online" else "Offline"
            putStrLn (username user ++ " has " ++ show count ++ " messages in the inbox(" ++ status ++ ")") 
    )  users

waitTillMessageSent :: [User] -> Int -> IO ()
waitTillMessageSent users totalMessages = do
  counts <- mapM getMessageCount users
  let sumMessages = sum counts
  when (sumMessages < totalMessages) $ do
    threadDelay 1000000
    waitTillMessageSent users totalMessages