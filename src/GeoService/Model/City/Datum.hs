{-# LANGUAGE OverloadedStrings #-}
module GeoService.Model.City.Datum where

import GeoService.Model.City
import qualified Database.RethinkDB.NoClash
import qualified Database.RethinkDB.Datum as Datum
import Database.RethinkDB.Datum hiding (LonLat(..))
import Control.Monad
import Control.Applicative
import qualified Data.Text as T


instance FromDatum City where
  parseDatum (Object v) = City
                          <$> (v .: "city")                          
                          <*> (v .: "cityId")
                          <*> (v .: "cityTranslations")  
                          <*> (v .: "country")                        
                          <*> (v .: "location")
                          <*> (v .: "region")
  parseDatum _          = mzero

instance FromDatum Location where
  parseDatum (Point rethinkPoint) = return (Location { latitude  = (fromRational . toRational $ (Datum.latitude rethinkPoint))
                                                     , longitude = (fromRational . toRational $ (Datum.longitude rethinkPoint))})
  parseDatum _          = mzero

instance FromDatum CityTranslation

instance ToDatum City where
  toDatum  a = object [ "city"    .= toDatum (city a)
                     , "cityId"  .= toDatum (cityId a)
                     , "cityTranslations" .= toDatum (cityTranslations a)
                     , "country" .= toDatum (country a)               
                     
                     , "location"   .= Datum.LonLat { Datum.longitude = longitude (location a)
                                                    ,  Datum.latitude  = latitude (location a)
                                         }     
                     , "region"     .= toDatum (region a)             
              ]

instance ToDatum CityTranslation where
  toDatum a = object [ "content"  .= toDatum (content a)
                     , "lang" .= toDatum (lang a)                  
              ]
