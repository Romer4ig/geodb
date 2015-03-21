{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module GoogleApi where
import Data.Default
import Data.Monoid
import Data.Aeson
import GHC.Generics
import Control.Lens
import Control.Applicative
import Control.Monad
import qualified Network.Wreq as W
import Data.Text (Text)
import qualified Data.Text as T
import GoogleApi.Types
import Network.HTTP.Types (urlEncode)
import qualified Data.Text.Encoding as T


geocodeUrl = "maps.googleapis.com/maps/api/geocode/json"

getByAddress :: Text -> IO ( Response )
getByAddress x = getByAddressWith def x

getByAddressWith :: Options -> Text -> IO (Response)
getByAddressWith o x = do 
    let protocol = if secure o then "https://" else "http://"
    let opts = W.defaults & W.param "address" .~ [ x ]
    r <- W.asJSON =<< W.getWith opts (T.unpack (protocol <> geocodeUrl ))
    return (r ^. W.responseBody)


