{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module API where
import Servant.API
import Data.Text (Text)

import Data.Aeson

import GHC.Generics ( Generic )
import Web.FormUrlEncoded (FromForm)
import Data.Data (Typeable)

data OnPublish = OnPublish
  { call     :: Maybe Text
  , addr     :: Maybe Text
  , clientid :: Maybe Text
  , app      :: Maybe Text
  , flashVer :: Maybe Text
  , swfUrl   :: Maybe Text
  , tcUrl    :: Maybe Text
  , pageUrl  :: Maybe Text
  , name     :: Text
  } deriving (Show, Eq, Generic, Typeable)

instance FromForm OnPublish

type API = ReqBody '[FormUrlEncoded] OnPublish :> Post '[PlainText] NoContent
