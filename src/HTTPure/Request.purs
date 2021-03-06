module HTTPure.Request
  ( Request
  , fromHTTPRequest
  , fullPath
  ) where

import Prelude

import Control.Monad.Aff as Aff
import Data.String as String
import Data.StrMap as StrMap
import Node.HTTP as HTTP

import HTTPure.Body as Body
import HTTPure.Headers as Headers
import HTTPure.HTTPureEffects as HTTPureEffects
import HTTPure.Method as Method
import HTTPure.Path as Path
import HTTPure.Query as Query

-- | The `Request` type is a `Record` type that includes fields for accessing
-- | the different parts of the HTTP request.
type Request =
  { method :: Method.Method
  , path :: Path.Path
  , query :: Query.Query
  , headers :: Headers.Headers
  , body :: Body.Body
  }

-- | Return the full resolved path, including query parameters. This may not
-- | match the requested path--for instance, if there are empty path segments in
-- | the request--but it is equivalent.
fullPath :: Request -> String
fullPath request = "/" <> path <> questionMark <> queryParams
  where
    path = String.joinWith "/" request.path
    questionMark = if StrMap.isEmpty request.query then "" else "?"
    queryParams = String.joinWith "&" queryParamsArr
    queryParamsArr = StrMap.toArrayWithKey stringifyQueryParam request.query
    stringifyQueryParam key value = key <> "=" <> value

-- | Given an HTTP `Request` object, this method will convert it to an HTTPure
-- | `Request` object.
fromHTTPRequest :: forall e.
                   HTTP.Request ->
                   Aff.Aff (HTTPureEffects.HTTPureEffects e) Request
fromHTTPRequest request = do
  body <- Body.read request
  pure $
    { method: Method.read request
    , path: Path.read request
    , query: Query.read request
    , headers: Headers.read request
    , body
    }
