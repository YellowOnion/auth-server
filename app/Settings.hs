{-# LANGUAGE DeriveGeneric #-}

module Settings where

import Data.ByteString
import GHC.Generics ( Generic )

import Data.Aeson
import Data.Text (Text)
import Data.Text.Encoding (decodeUtf8, encodeUtf8)

import Control.Monad (liftM)

import Util

data Settings = Settings
  { salt :: Text
  , hashedToken :: Text
  } deriving (Show, Eq, Generic)

data SettingsBytes = SettingsBytes
  { saltBytes :: ByteString
  , hashedTokenBytes :: ByteString
  } deriving (Show, Eq, Generic)

bytesToBase64Text = decodeUtf8 . convertToBase64
bytesFromBase64Text = convertFromBase64 . encodeUtf8

bytesToSettings (SettingsBytes s h) = Settings (bytesToBase64Text s) (bytesToBase64Text h)
bytesFromSettings (Settings s h) = SettingsBytes (bytesFromBase64Text s) (bytesFromBase64Text h)

instance ToJSON Settings where
  toEncoding = genericToEncoding defaultOptions
instance FromJSON Settings

readSettingsFile :: IO (Maybe SettingsBytes)
readSettingsFile = liftM (fmap bytesFromSettings) (decodeFileStrict "auth.json")
writeSettingsFileBytes :: ByteString -> ByteString -> IO ()
writeSettingsFileBytes a b = encodeFile "auth.json" . bytesToSettings $ SettingsBytes a b
