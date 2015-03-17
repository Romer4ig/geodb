module Common where

import GeoService.Model.City
import Data.IORef
import Database.RethinkDB as DB

data App = App { dbConn     :: DB.RethinkDBHandle -- RethinkHandle
			   , listenPort :: Int
               , listCity   :: IORef [City]
}