
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
server app = searchCountry :<|> serachCountryShort :<|> getAllCites :<|> cityAutocomplete :<|> cityAutocomplete' :<|> addCity :<|> refresh :<|> nearCities :<|> nearCity :<|> searchCity

  where searchCountry name = do
            listCity <- liftIO $ readIORef (listCity app)  
            let list = filter (\x -> (T.toLower(country x)) == (T.toLower name)) listCity 
            return list

        serachCountryShort name = do
            listCity <- liftIO $ readIORef (listCity app)  
            let list = filter (\x -> (T.toLower(country x)) == (T.toLower name)) listCity 
                list' = map (\x -> cityId x) list
            return list' 

        getAllCites = do 
            listCity <- liftIO $ readIORef (listCity app)
            return listCity

        cityAutocomplete name limit = do
            listCity <- liftIO $ readIORef (listCity app)  
            let isPrefixLower a b = (T.toLower a) `T.isPrefixOf` (T.toLower b)
                isOnlyInfix a b = (T.toLower a) `T.isInfixOf` (T.toLower b) && (not( isPrefixLower a b))
                list = filter (\x -> any (\y -> isPrefixLower name (content y)) (cityTranslations x) ) listCity ++ filter (\x -> any (\y -> isOnlyInfix name (content y)) (cityTranslations x)) listCity
--                       any (\x -> (T.toLower name) `T.isPrefixOf` (T.toLower(content y))) s) ++ filter (\x -> (T.toLower name) `isInfixOf` (T.toLower(content y)) &&-- (not ((T.toLower name) `isPrefixOf` (T.toLower(content y)))) listCity
            return (take (maybe 10 (min 20) limit) list) 

        cityAutocomplete' limit = do
            return []

        addCity body =  do
            liftIO $ DB.add (dbConn app) body
            return (cityId body)

        refresh =  do
            liftIO $ DB.getCities (dbConn app) >>= writeIORef (listCity app )
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
                      let city = L.find (\x -> (cityId x) == (SearchCity.cityId a) ) listCity
                      return city
                  
                  


                       
          

