{-# LANGUAGE OverloadedStrings #-}

module GeoService.DB.Rethink where
import Data.IORef
import System.Environment
import qualified Data.Text as T
import qualified Database.RethinkDB as R
import Database.RethinkDB.Datum (resultToMaybe)
import GeoService.Model.City.Datum
import Database.RethinkDB.NoClash
import GeoService.Model.City
import Common

initDb :: IO (RethinkDBHandle)
initDb = do
    host       <- getEnv "GEO_DB_HOST"
    port       <- getEnv "GEO_DB_PORT"
    base_name  <- getEnv "GEO_DB_NAME"
    h <- connect host (read port) Nothing
    let hWithDb = use (Database (T.pack base_name)) h
    return hWithDb

getCities :: App -> IO()
getCities app = do
    a <- R.run' (dbConn app) $ table "cities"
    case ((resultToMaybe (fromDatum a)) :: Maybe [City]) of
        Just bbb -> do 
            let ref = (listCity app)
            print bbb
            writeIORef ref bbb            
        Nothing -> return ()

add :: App -> City -> IO ()
add app city = do
    run (dbConn app) $ table "cities" # insert (toDatum city)
    
