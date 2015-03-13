
module GeoService.Model.City.Datum where

import GeoService.Model.City
import Database.RethinkDB.NoClash

instance FromDatum City
instance FromDatum CityTranslation