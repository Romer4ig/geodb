module GoogleApi where
import Data.Text (Text)
import qualified Data.Text as T
geocodeUrl = "maps.googleapis.com/maps/api/geocode/json"


-- | https://developers.google.com/maps/documentation/geocoding/#ComponentFiltering
--   
data Component = Route -- ^ matches long or short name of a route. 
			   | Locality -- ^ matches against both locality and sublocality types. 
			   | AdministrativeArea -- ^ matches all the administrative_area levels. 
			   | PostalCode -- ^ matches postal_code and postal_code_prefix.
			   | Country -- ^ matches a country name or a two letter ISO 3166-1 country code.

-- | https://developers.google.com/maps/documentation/geocoding/#ReverseGeocoding
--
data Options = Options { key :: Maybe Text -- ^ Your application's API key, obtained from the Google Developers Console.
 					   --, bounds :: 
 					   , language :: Text -- ^ The language in which to return results. https://developers.google.com/maps/faq#languagesupport
 					   , resultType :: Text 
 					   , components :: [(Component,String)]
}


[(Route,"TX"), (Country,"US")]

getByAddress...