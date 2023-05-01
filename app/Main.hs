{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE RecordWildCards #-}

module Main where

import Servant.Server

import API hiding (app)
import Data.Proxy

import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import Data.ByteString (ByteString)
import Data.Text.Encoding (encodeUtf8)

import Util (hashToken, convertToBase64, convertFromBase64, convertFromBase64')
import Settings
import Network.Wai.Middleware.RequestLogger (logStdout)

server :: SettingsBytes -> Server API
server (SettingsBytes salt hashedToken) = postServer
  where
    postServer :: OnPublish -> Handler NoContent
    postServer OnPublish{..} = do
      name' <- case convertFromBase64' $ encodeUtf8 name of
        Left _ -> throwError err404
        Right n -> return n
      if hashToken name' salt == hashedToken
        then return NoContent
        else throwError err404


appAPI :: Proxy API
appAPI = Proxy

app :: SettingsBytes -> Application
app s = serve appAPI $ server s


main :: IO ()
main = do
  s <- readSettingsFile
  case s of
    Nothing -> error "failed to open auth.json"
    Just settings -> do
      run 8081 (logStdout $ app settings)
