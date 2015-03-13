

module GeoService.DB.Rethink where

import System.Environment
import qualified Data.Text as T
import qualified Database.RethinkDB as R
import Database.RethinkDB.NoClash

initDb :: IO (RethinkDBHandle)
initDb = do
    host       <- getEnv "GEO_DB_HOST"
    port       <- getEnv "GEO_DB_PORT"
    base_name  <- getEnv "GEO_DB_NAME"
    h <- connect host (read port) Nothing
    let hWithDb = use (Database (T.pack base_name)) h
    return hWithDb