{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds #-}

module GeoService.DB.Rethink where
import Data.IORef
import System.Environment
import qualified Data.Text as T
import qualified Database.RethinkDB as R
import Database.RethinkDB.Datum (resultToMaybe,resultToEither)
import GeoService.Model.City.Datum
import Database.RethinkDB.NoClash hiding (latitude, longitude)
import GeoService.Model.City
import Data.Maybe
import Data.Pool
import GeoService.Model.SearchCity
import GeoService.Model.SearchCity.Datum

type Model = Pool RethinkDBHandle

initDb :: IO (Model)
initDb = do
    host        <- getEnv "DB_HOST"
    port        <- getEnv "DB_PORT"
    baseName    <- getEnv "DB_NAME"
    authKey     <- lookupEnv "DB_AUTH_KEY"
    dbPoolCount <- fmap (fromMaybe "50") (lookupEnv "DB_POOL_COUNT")
    dbPoolTimeout <- fmap (fromMaybe "60") (lookupEnv "DB_POOL_TIMEOUT")
    let hWithDb h = use (Database (T.pack baseName)) h
    let conn = fmap hWithDb (connect host (read port) authKey)  
    createPool conn (\h -> close h) (read dbPoolCount) (fromInteger (read dbPoolTimeout)) (read dbPoolCount)


-- _getCities :: RethinkDBHandle -> [City]
_getCities model = do
  withResource model $ \conn -> do
    a <- R.run' conn $ table "cities"
    case ((resultToMaybe (fromDatum a)) :: Maybe [City]) of
        Just bbb -> return bbb
        Nothing -> return []

--insertSearchCity ::  SearchCity -> IO ()
insertSearchCity model sc = do
  withResource model $ \conn -> do
    run' conn $ table "cityid_by_name" # insert (toDatum sc)
    return ()

getSearchCity model name = do
  withResource model $ \conn -> do
    h <- R.run' conn $ table "cityid_by_name" # getAll (Index "search") [str name] 
    case ((resultToMaybe (fromDatum h)) :: Maybe [SearchCity]) of
        Just bbb -> do
            return bbb
        Nothing -> return []

--getCities :: Model -> IO()
getCities model = do
    withResource model $ \conn -> do
      a <- R.run' conn $ table "cities" 
      case ((resultToMaybe (fromDatum a)) :: Maybe [City]) of
          Just bbb -> return bbb
          Nothing -> return []

add :: Model -> City -> IO ()
add model city = do
  withResource model $ \conn -> do
    run conn $ table "cities" # insert (toDatum city)
    
