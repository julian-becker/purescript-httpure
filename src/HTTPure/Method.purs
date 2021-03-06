module HTTPure.Method
  ( Method(..)
  , read
  ) where

import Data.Eq as Eq
import Data.Generic as Generic
import Node.HTTP as HTTP
import Data.Show as Show

-- | These are the HTTP methods that HTTPure understands.
data Method
  = Get
  | Post
  | Put
  | Delete
  | Head
  | Connect
  | Options
  | Trace
  | Patch

-- | If two `Methods` are the same constructor, they are equal.
derive instance generic :: Generic.Generic Method
instance eq :: Eq.Eq Method where
  eq = Generic.gEq

-- | Convert a constructor to a `String`.
instance show :: Show.Show Method where
  show Get = "Get"
  show Post = "Post"
  show Put = "Put"
  show Delete = "Delete"
  show Head = "Head"
  show Connect = "Connect"
  show Options = "Options"
  show Trace = "Trace"
  show Patch = "Patch"

-- | Take an HTTP `Request` and extract the `Method` for that request.
read :: HTTP.Request -> Method
read request = case HTTP.requestMethod request of
  "POST"    -> Post
  "PUT"     -> Put
  "DELETE"  -> Delete
  "HEAD"    -> Head
  "CONNECT" -> Connect
  "OPTIONS" -> Options
  "TRACE"   -> Trace
  "PATCH"   -> Patch
  _         -> Get
