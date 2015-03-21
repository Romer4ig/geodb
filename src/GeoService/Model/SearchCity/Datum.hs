{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}


module GeoService.Model.SearchCity.Datum where

import Database.RethinkDB.Datum
import GeoService.Model.SearchCity

instance ToDatum SearchCity
instance FromDatum SearchCity
