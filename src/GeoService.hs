{-# LANGUAGE ViewPatterns #-}

module GeoService(getAllCities,autocomplete,autocompleteWithLimit) where

import           Control.Monad.Trans.Either
import           Servant.Client
import           System.Environment
import           Servant
import 			     Data.Text (Text)
import           GeoService.Model.City 

import           Api

getAllCities :: IO (Either String [GeoService.Model.City.City])
getAllCities = do
  url <- getEnv "GEO_ENDPOINT"

  let Right base = parseBaseUrl url

  a <- runEitherT (getAllCites' base)
  return a


autocomplete :: Text -> IO (Either String [GeoService.Model.City.City])
autocomplete work  = do
  url <- getEnv "GEO_ENDPOINT"

  let Right base = parseBaseUrl url

  a <- runEitherT (cityAutocomplete' work Nothing base)
  return a

autocompleteWithLimit :: Text -> Int -> IO (Either String [GeoService.Model.City.City])
autocompleteWithLimit work limit  = do
  url <- getEnv "GEO_ENDPOINT"

  let Right base = parseBaseUrl url

  a <- runEitherT (cityAutocomplete' work (Just limit) base)
  return a

( searchCountry' :<|> serachCountryShort :<|> getAllCites'  :<|> cityAutocomplete'  :<|> addCity :<|> refresh) = client api