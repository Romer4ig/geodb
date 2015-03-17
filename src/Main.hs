import qualified Database.RethinkDB as R
import qualified Network.Wai
import qualified Network.Wai.Handler.Warp
import qualified GeoService.DB.Rethink as DB
import Database.RethinkDB.NoClash
import Data.IORef
import System.Environment

import Control.Monad
import Control.Concurrent

import GeoService.Model.City
import GeoService.Model.City.Datum
import Servant
import Api
import Common
import Web


runTestServer :: App -> IO ()
runTestServer app = Network.Wai.Handler.Warp.run (listenPort app) (test app)

test :: App -> Network.Wai.Application 
test app = serve api (server app)


regenBase app = do
    DB.getCities app   

workerRegen app = forever $ do
    regenBase app
--    threadDelay 10000000

main = do    
    dbH <- DB.initDb
    tmp <- newIORef []
    port <- getEnv "GEO_LISTEN_PORT"
    let app = App { 
            dbConn = dbH ,
            listenPort = (read port), 
            listCity = tmp
        }
    regenBase app
    forkIO $ workerRegen app
    runTestServer app
    

    