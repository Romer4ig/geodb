{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module Api where

import Servant
import Data.Text (Text)

import GeoService.Model.City
import GoogleApi.Types

api :: Proxy Api
api = Proxy

type Api = 
       "country" :>  Capture "name" Text :> "cities" :> Get [City]
        -- GET cityId from city by Country
  :<|> "country" :>  Capture "name" Text :> "cities" :> "short" :>  Get [Text]
        -- GET all cites
  :<|> "cities"   :>  Get [City]
        -- GET autocomplite by city in cityTranslation
  :<|> "city"    :>  Capture "name" Text :> "autocomplete" :> QueryParam "limit" Int :> Get [City]

  :<|> "addcity" :> ReqBody City :> Post Text

  :<|> "refresh" :> Get Text

  :<|> "near" :> Capture "lat" Double :> Capture "lng" Double :> "cities" :> QueryParam "limit" Int :> Get [City]

  :<|> "near" :> Capture "lat" Double :> Capture "lng" Double :> "city" :> Get [City]

  :<|> "search" :> Capture "name" Text :> "city" :> Get (Maybe City)
 
  



