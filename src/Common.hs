module Common where

import GeoService.Model.City
import Data.IORef
import GeoService.DB.Rethink as DB

data App = App { dbConn     :: DB.Model
	       , listenPort :: Int
               , listCity   :: IORef [City]               
}
