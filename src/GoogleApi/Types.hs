{-# LANGUAGE OverloadedStrings #-}

module GoogleApi.Types where
import Data.Text (Text)
import Data.Default
import Control.Applicative
import Control.Monad
import Data.Aeson hiding (Result)
type Components = [(Component,String)]

data Status = Ok -- ^ indicates that no errors occurred; the address was successfully parsed and at least one geocode was returned.
            | ZeroResults -- ^ indicates that the geocode was successful but returned no results. This may occur if the geocoder was passed a non-existent address.
            | OverQueryLimit -- ^ indicates that you are over your quota.
            | RequestDenied -- ^ indicates that your request was denied.
            | InvalidRequest -- ^ generally indicates that the query (address, components or latlng) is missing.
            | UnknownError -- ^ indicates that the request could not be processed due to a server error. The request may succeed if you try again.
 deriving (Show)

-- | https://developers.google.com/maps/documentation/geocoding/#ComponentFiltering
--   
data Component = Route -- ^ matches long or short name of a route. 
               | Locality -- ^ matches against both locality and sublocality types. 
               | AdministrativeArea -- ^ matches all the administrative_area levels. 
               | PostalCode -- ^ matches postal_code and postal_code_prefix.
               | Country -- ^ matches a country name or a two letter ISO 3166-1 country code.
 deriving (Show)


 -- | https://developers.google.com/maps/documentation/geocoding/#ReverseGeocoding
--
data Options = Options { --bounds :: Maybe Text -- ^ Your application's API key, obtained from the Google Developers Console.
                         key :: Maybe Text -- ^ Your application's API key, obtained from the Google Developers Console.
                       , language :: Maybe Text -- ^ The language in which to return results. https://developers.google.com/maps/faq#languagesupport
                       , region :: Maybe Text -- ^ The region code, specified as a ccTLD ("top-level domain") two-character value. 
                       , components :: Components -- ^ https://developers.google.com/maps/documentation/geocoding/#ComponentFiltering
                       , secure :: Bool
  } deriving (Show)

data Response = Response { results :: [Result]
                         , status :: Status
} deriving (Show)

data AddressComponent = AddressComponent { longName  :: String
                                         , shortName :: String 
                                         , types     :: [Text]
} deriving (Show)

data Location = Location { lat :: Double
                         , lng :: Double
} deriving (Show)

data Geometry = Geometry { location :: Location 
} deriving (Show)

data Result = Result { addressComponents :: [AddressComponent] 
                     , formattedAddress  :: String
                     , geometry          :: Geometry
                     , placeId           :: Text
                     , addressTypes      :: [Text]
  } deriving (Show)

instance Default Options where
    def = Options { key = Nothing
                  , language = Nothing
                  , region = Nothing
                  , components = []
                  , secure = True
    }  

instance FromJSON AddressComponent where
  parseJSON (Object v) =
    AddressComponent <$> v .: "long_name"
                     <*> v .: "short_name"
                     <*> v .: "types"

instance FromJSON Location where
  parseJSON (Object v) =
    Location <$> v .: "lat"
             <*> v .: "lng"

instance FromJSON Geometry where
  parseJSON (Object v) =
    Geometry <$> v .: "location"

instance FromJSON Result where
  parseJSON (Object v) =
    Result <$> v .: "address_components"
           <*> v .: "formatted_address"
           <*> v .: "geometry"
           <*> v .: "place_id"
           <*> v .: "types"


instance FromJSON Status where
    parseJSON (String v) = return (stringToStatus v)
        where 
          stringToStatus "ZERO_RESULTS"     =  ZeroResults
          stringToStatus "OVER_QUERY_LIMIT" =  OverQueryLimit
          stringToStatus "REQUEST_DENIED"   =  RequestDenied
          stringToStatus "INVALID_REQUEST"  =  InvalidRequest
          stringToStatus "UNKNOWN_ERROR"    =  UnknownError
          stringToStatus "OK"               =  Ok
    parseJSON _ = mzero

instance FromJSON Response where
 parseJSON (Object v) =
    Response <$> v .: "results"
             <*> v .: "status"
 parseJSON _ = mzero