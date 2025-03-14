{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# OPTIONS -fno-warn-orphans #-}

module Hell.Types where

import Control.Monad.Reader

import Data.Default
import Data.IORef
import GhcMonad

import System.Console.Haskeline.History

-- | Shell config.
data Config = Config
  { configImports :: ![String] -- ^ Starting imports.
  , configWelcome :: String -- ^ A welcome string.
  , configHistory :: FilePath
  , configPrompt  :: String -> FilePath -> Hell String -- ^ An action to generate the prompt.
  }

-- | State of the shell.
data HellState = HellState
  { stateConfig    :: !Config
  , stateHistory   :: !(IORef History)
  , stateUsername  :: !String
  , stateHome      :: !FilePath
  , stateFunctions :: ![String]
  }

-- | Hell monad, containing user information and things like that.
newtype Hell a = Hell { runHell :: ReaderT HellState Ghc a }
  deriving (Monad
           ,MonadIO
           ,Functor
           ,MonadReader HellState)

instance Default Config where
  def = Config
    { configImports =
        map ("import "++)
            ["Hell"]
    , configWelcome = "Welcome to Hell!"
    , configPrompt = \username pwd -> return (username ++ ":" ++ pwd ++ "$ ")
    , configHistory = "~/.hell-history"
    }

-- | Hopefully this shouldn't be a problem because while this is a
-- library it has a very narrow use-case.
instance MonadIO Ghc where
  liftIO = GhcMonad.liftIO
