{-# LANGUAGE DeriveGeneric #-}

module GeoService.Model.City where

import Data.Aeson
import GHC.Generics

data CityTranslation = CityTranslation {
    content :: String,
    lang :: String
} deriving (Show,Generic)

data Location = Location {
    longitude :: Double,
    latitude :: Double
} deriving (Show,Generic)

data Population = Population {
    count :: Int,
    year :: Int
} deriving (Show,Generic)


data City = City {
    city :: String,
    cityId :: String,
    cityTranslations :: [CityTranslation],
    country :: String,
    location :: Location,
--    population :: Population,
    region :: String
} deriving (Show,Generic)

instance FromDatum City where
  parseDatum (Object v) = City
                          <$> (v .: "cityId")
                          <*> (v .: "country")
                          <*> (v .: "city")
                          <*> (v .: "cityTranslations")
                          <*> (v .: "region")
                          <*> (v .: "location")
  parseDatum _          = mzero

instance FromJSON City 
instance FromJSON CityTranslation
instance FromJSON Location 
instance FromJSON Population 
instance ToJSON City 
instance ToJSON CityTranslation
instance ToJSON Location 
instance ToJSON Population