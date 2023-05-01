{-# LANGUAGE OverloadedStrings #-}
module Util where

import qualified Data.ByteString        as B

import Data.ByteArray.Encoding (convertToBase, convertFromBase, Base(Base64URLUnpadded))

import qualified Crypto.KDF.Argon2 as Argon2

import Crypto.Error (maybeCryptoError)
import Data.Maybe (fromJust)
import Data.Either (fromRight)

convertToBase64 :: B.ByteString -> B.ByteString
convertToBase64 = convertToBase Base64URLUnpadded
convertFromBase64 :: B.ByteString -> B.ByteString
convertFromBase64 = fromRight (error "can't decode Base64") . convertFromBase Base64URLUnpadded


convertFromBase64' :: B.ByteString -> Either String B.ByteString
convertFromBase64' = convertFromBase Base64URLUnpadded

hashToken password salt = fromJust . maybeCryptoError $ Argon2.hash Argon2.defaultOptions password salt 16
