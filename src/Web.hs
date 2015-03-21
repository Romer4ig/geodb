
module Web where 

import Servant
import qualified Data.Text as T
import qualified Data.List as L
import Control.Monad.IO.Class (liftIO)
import Data.IORef
import GeoService.Model.City
import Api
import GoogleApi
import qualified GoogleApi.Types as GT
import Common
import Numeric.Geocalc
import Data.Ord
import Data.Maybe
import GeoService.DB.Rethink as DB
import qualified GeoService.Model.SearchCity as SearchCity
import Control.Monad

server :: App -> Server Api
server app = searchCountry :<|> serachCountryShort :<|> getAllCites :<|> cityAutocomplete :<|> addCity :<|> refresh :<|> nearCities :<|> nearCity :<|> searchCity

  where searchCountry name = do
            listCity <- liftIO $ readIORef (listCity app)  
            let list = filter (\x -> (country x) == name) listCity 
            return list

        serachCountryShort name = do
            listCity <- liftIO $ readIORef (listCity app)  
            let list = filter (\x -> (country x) == name) listCity 
                list' = map (\x -> cityId x) list
            return list' 

        getAllCites = do 
            listCity <- liftIO $ readIORef (listCity app)
            return listCity

        cityAutocomplete name limit = do
            listCity <- liftIO $ readIORef (listCity app)  
            let list = filter (\x -> any (\y -> T.isInfixOf name (content y)) (cityTranslations x)) listCity             
            return (take (maybe 10 (min 20) limit) list) 

        addCity body =  do
            liftIO $ DB.add (dbConn app) body
            return (cityId body)

        refresh =  do
            return (T.pack "NOT FORKING YET")
        
        nearCities lat lng limit = do 
            listCity <- liftIO $ readIORef (listCity app)
            let target = (lat,lng)  
            let result = take (maybe 5 (min 20) limit) . L.sortBy (comparing(\x -> let p = location x in getDistance target (latitude p,longitude p))) $ listCity
            return result

        nearCity lat lng = do 
            listCity <- liftIO $ readIORef (listCity app)
            let target = (lat,lng)  
            let result = take 1 . L.sortBy (comparing(\x -> let p = location x in getDistance target (latitude p,longitude p))) $ listCity
            return result

        searchCity name = do
            sc <- liftIO $ DB.getSearchCity (dbConn app) (T.unpack  name)
            case sc of 
              [] -> do
                  r <- liftIO $ fmap ( listToMaybe . map (\x -> let g = GT.location (GT.geometry x) in (GT.lat g,GT.lng g)) . GT.results) (getByAddress name)
                  --r1 <- liftIO $ do
                  --             googleResults <- getByAddress name
                  --             let getLatLng x = let g = GT.geometry x 
                  --                    in (GT.lat (GT.location g),GT.lng (GT.location g))
                  --             return (listToMaybe $ map getLatLng $ GT.results googleResults)
                  case r of 
                    Just _ -> do
                               listCity <- liftIO $ DB._getCities (dbConn app)
                               let target = fromJust r
                               let result = listToMaybe . L.sortBy (comparing(\x -> let p = location x in getDistance target (latitude p,longitude p))) $ listCity
                               case result of 
                                 Just c  ->  liftIO $ void $ DB.insertSearchCity (dbConn app) (SearchCity.SearchCity name (cityId c))
                                 Nothing ->  return ()
                               return result
                    Nothing -> return Nothing  
              [a] -> do
                      listCity <- liftIO $ readIORef (listCity app) 
                      return $ L.find (\x -> (cityId x) == (SearchCity.cityId a) ) listCity
                  
                  


                       
          

