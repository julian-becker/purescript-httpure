module HTTPure.Body
  ( Body
  , read
  , write
  ) where

import Prelude

import Control.Monad.Aff as Aff
import Control.Monad.Eff as Eff
import Control.Monad.ST as ST
import Node.Encoding as Encoding
import Node.HTTP as HTTP
import Node.Stream as Stream

import HTTPure.HTTPureEffects as HTTPureEffects

-- | The `Body` type is just sugar for a `String`, that will be sent or received
-- | in the HTTP body.
type Body = String

-- | Extract the contents of the body of the HTTP `Request`.
read :: forall e. HTTP.Request -> Aff.Aff (HTTPureEffects.HTTPureEffects e) Body
read request = Aff.makeAff \_ success -> do
  let stream = HTTP.requestAsStream request
  buf <- ST.newSTRef ""
  Stream.onDataString stream Encoding.UTF8 \str ->
    void $ ST.modifySTRef buf ((<>) str)
  Stream.onEnd stream $ ST.readSTRef buf >>= success

-- | Write a `Body` to the given HTTP `Response` and close it.
write :: forall e. HTTP.Response -> Body -> Eff.Eff (http :: HTTP.HTTP | e) Unit
write response body = void do
  _ <- Stream.writeString stream Encoding.UTF8 body $ pure unit
  Stream.end stream $ pure unit
  where
    stream = HTTP.responseAsStream response
