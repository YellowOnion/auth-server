{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE TemplateHaskell    #-}
{-# LANGUAGE TypeFamilies       #-}

module Store where

import           Data.Acid
import           Data.Acid.Remote

import           Data.SafeCopy
import qualified Control.Monad.State  as State
import           Control.Monad.Reader    (ask, asks)

import Data.Typeable

import qualified Data.Map                   as Map

import           Crypto.MAC.SipHash         (SipKey)
import           Data.Word                  (Word64)

import           API                        (API, File, ID)
import           Util

data Store = Store
  { files :: !(Map.Map ID File)
  , count :: !Word64
  , sk  :: !SipKey
  } deriving (Typeable)

$(deriveSafeCopy 0 'base ''ID)
$(deriveSafeCopy 0 'base ''File)
$(deriveSafeCopy 0 'base ''SipKey)
$(deriveSafeCopy 0 'base ''Store)

insertFile :: File -> Update Store ID
insertFile v = do
  (Store f c sk) <- State.get
  let k' = c + 1
  let id' = keyToID sk k'
  State.put (Store (Map.insert id' v f) k' sk)
  return id'

lookupFile :: ID -> Query Store (Maybe File)
lookupFile id' = do
  (Store files _ sk) <- ask
  return $ Map.lookup id' files

dumpStore :: Query Store Store
dumpStore = ask

listAllFiles :: Query Store ([ID])
listAllFiles = do
  f <- asks files
  return $ Map.keys f

$(makeAcidic ''Store ['insertFile, 'lookupFile, 'dumpStore, 'listAllFiles])

openLocalStore :: SipKey -> IO (AcidState Store)
openLocalStore sk = do
  acid <- openLocalState . (Store Map.empty 0) $ sk
  createCheckpoint acid
  return acid
