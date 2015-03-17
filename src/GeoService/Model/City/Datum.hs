{-# LANGUAGE OverloadedStrings #-}
module GeoService.Model.City.Datum where

import GeoService.Model.City
import qualified Database.RethinkDB.NoClash
import Database.RethinkDB.Datum
import Control.Monad
import Control.Applicative
import qualified Data.Text as T


instance FromDatum City where
  parseDatum (Object v) = City
                          <$> (v .: "cityId")
                          <*> (v .: "country")
                          <*> (v .: "city")
                          <*> (v .: "cityTranslations")
                          <*> (v .: "region")
                          <*> (v .: "location")
  parseDatum _          = mzero

instance FromDatum Location where
  parseDatum (Point rethinkPoint) = return (Location (fromRational . toRational $ (Database.RethinkDB.Datum.latitude rethinkPoint)) (fromRational . toRational $ (Database.RethinkDB.Datum.longitude rethinkPoint)))
  parseDatum _          = mzero

instance FromDatum CityTranslation

instance ToDatum City where
  toDatum  a = object [ "cityId"  .= toDatum (cityId a)
                     , "country" .= toDatum (country a)
                     , "city"    .= toDatum (city a)
                     , "cityTranslations" .= toDatum (cityTranslations a)
                     , "region"     .= toDatum (region a)
                     , "location"   .= LonLat { Database.RethinkDB.Datum.longitude = GeoService.Model.City.longitude (location a)
                                             ,  Database.RethinkDB.Datum.latitude  = GeoService.Model.City.latitude (location a)
                                         }                   
              ]

instance ToDatum CityTranslation where
  toDatum a = object [ "content"  .= toDatum (content a)
                     , "lang" .= toDatum (lang a)                  
              ]
