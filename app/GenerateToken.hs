{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.ByteString as B
import qualified Data.Text as T
import qualified Data.Text.IO as T

import System.IO

import Util
import Settings

main = do
  withFile "/dev/urandom" ReadMode $ \f -> do
    salt <- B.hGet f 16
    token <- B.hGet f 16
    let hashedToken = hashToken token salt
    writeSettingsFileBytes salt hashedToken
    settings <- readSettingsFile
    case settings of
      Nothing -> T.putStrLn "ERROR"
      Just (SettingsBytes salt' hashedToken') -> do
        T.putStrLn $ "Token: " <> (bytesToBase64Text token)
        T.putStrLn $ "auth.json is: " <>
          if salt == salt' && hashedToken == hashedToken'
          then "valid" else "invalid"
