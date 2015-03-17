{-# LANGUAGE DeriveGeneric #-}

module GeoService.Model.City where

import Data.Aeson
import GHC.Generics
import Data.Text

data CityTranslation = CityTranslation {
    content :: Text,
    lang :: Text
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
    city :: Text,
    cityId :: Text,
    cityTranslations :: [CityTranslation],
    country :: Text,
    location :: Location,
--    population :: Population,
    region :: Text
} deriving (Show,Generic)


instance FromJSON City 
instance FromJSON CityTranslation
instance FromJSON Location 
instance FromJSON Population 
instance ToJSON City 
instance ToJSON CityTranslation
instance ToJSON Location 
instance ToJSON Population