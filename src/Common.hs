module Common where

import GHC.Generics
import GeoService.Model.City
import Data.IORef
import System.Environment
import Database.RethinkDB as DB

data App = App { dbConn     :: DB.RethinkDBHandle -- RethinkHandle
			   , listenPort :: Int
               , listCity   :: IORef [City]
}