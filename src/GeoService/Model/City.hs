{-# LANGUAGE DataKinds #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module GeoService.Model.City where

import Data.Aeson
import GHC.Generics

data CityTranslation = CityTranslation {
    content :: String,
    lang :: String
} deriving (Show,Generic)

data Location = Location {
    lng :: Float,
    lat :: Float
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
--    location :: Location,
--    population :: Population,
    region :: String
} deriving (Show,Generic)

instance FromJSON City 
instance FromJSON CityTranslation
instance FromJSON Location 
instance FromJSON Population 
instance ToJSON City 
instance ToJSON CityTranslation
instance ToJSON Location 
instance ToJSON Population