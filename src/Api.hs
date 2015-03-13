{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module Api where

import Servant
import Data.Text (Text)

import GeoService.Model.City

api :: Proxy Api
api = Proxy

type Api =
        -- POST Add city 
       "country" :>  Capture "name" Text :> "cites" :> Get [City]
        -- GET cityId from city by Country
  :<|> "country" :>  Capture "name" Text :> "cites" :> "short" :>  Get [Text]
        -- GET all cites
  :<|> "cities"   :>  Get [City]
        -- GET autocomplite by city in cityTranslation
  :<|> "city"    :>  Capture "name" Text :> "autocomplete" :> QueryParam "limit" Int :> Get [City]