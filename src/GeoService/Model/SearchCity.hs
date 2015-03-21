{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module GeoService.Model.SearchCity where

import Data.Text (Text)
import Data.Aeson
import GHC.Generics


data SearchCity = SearchCity { search :: Text
                             , cityId :: Text 
} deriving (Show , Generic) 

instance ToJSON SearchCity 
instance FromJSON SearchCity
