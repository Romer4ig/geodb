{-# LANGUAGE DataKinds #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

import GHC.Generics
import qualified Database.RethinkDB as R
import qualified Data.Text as T
import Data.Text (Text)
import Data.IORef
import qualified Network.Wai
import qualified Network.Wai.Handler.Warp
import Database.RethinkDB.NoClash
import Database.RethinkDB.Datum (resultToMaybe)

import Control.Monad
import Control.Concurrent

import GeoService.Model.City
import GeoService.Model.City.Datum
import Servant
import Api
import Common
import Web
import GeoService.DB.Rethink as DB
--import GeoService.DB.MySql as DB

runTestServer :: App -> IO ()
runTestServer app = Network.Wai.Handler.Warp.run (listenPort app) (test app)

test :: App -> Network.Wai.Application 
test app = serve api (server app)


regenBase app = do
    --DB.getCities
    a <- R.run' (dbConn app) $ table "cities"
    case ((resultToMaybe (fromDatum a)) :: Maybe [City]) of
        Just bbb -> do 
            let ref = (listCity app)
            writeIORef ref bbb            
        Nothing -> return ()

workerRegen app = forever $ do
    regenBase app
    threadDelay 10

main = do    
    dbH <- DB.initDb
    tmp <- newIORef []
    let app = App { 
            dbConn = dbH ,
            listenPort = 8001, 
            listCity = tmp
        }
    regenBase app
    forkIO $ workerRegen app
    runTestServer app
    

    