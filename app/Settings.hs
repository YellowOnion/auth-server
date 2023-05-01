{-# LANGUAGE DeriveGeneric #-}

module Settings where

import Data.ByteString
import GHC.Generics ( Generic )

import Data.Aeson
import Data.Text (Text)
import Data.Text.Encoding (decodeUtf8, encodeUtf8)

import Control.Monad (liftM)
import Control.Applicative

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
readSettingsFile = (fmap bytesFromSettings)
                <$> (    decodeFileStrict "/var/lib/auth-server/auth.json"
                     <|> decodeFileStrict "auth.json")

readSettingsFile' f = (fmap bytesFromSettings) <$> decodeFileStrict f

writeSettingsFileBytes :: FilePath -> ByteString -> ByteString -> IO ()
writeSettingsFileBytes f a b = encodeFile f . bytesToSettings $ SettingsBytes a b
