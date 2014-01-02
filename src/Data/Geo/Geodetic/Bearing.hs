-- | A bearing in degrees between 0 and 360.
module Data.Geo.Geodetic.Bearing(
  Bearing
, HasBearing(..)
, modBearing
, degreeBearing
, radianBearing
) where

import Prelude(Double, Bool(..), Eq, Show(..), Num(..), Fractional(..), Ord(..), id, (&&), (++), (.), showString, showParen, pi)
import Data.Maybe(Maybe(..))
import Control.Lens(Prism', Lens', prism', iso)
import Text.Printf(printf)
import Data.Fixed(mod')

-- $setup
-- >>> import Control.Lens((#), (^?))
-- >>> import Data.Foldable(all)
-- >>> import Prelude(Eq(..))

newtype Bearing =
  Bearing Double
  deriving (Eq, Ord)

-- | A show instance that prints to 4 decimal places.
-- This is to take floating-point rounding errors into account.
instance Show Bearing where
  showsPrec n (Bearing d) =
    showParen (n > 10) (showString ("Bearing " ++ printf "%0.4f" d))

-- | Construct a bearing such that if the given value is out of bounds,
-- a modulus is taken to keep it within 0 inclusive and 360 exclusive.
--
-- >>> modBearing 7
-- Bearing 7.0000
--
-- >>> modBearing 0
-- Bearing 0.0000
--
-- >>> modBearing (-0.0001)
-- Bearing 359.9999
--
-- >>> modBearing 360
-- Bearing 0.0000
--
-- >>> modBearing 359.99999
-- Bearing 360.0000
--
-- >>> modBearing 359.999
-- Bearing 359.9990
modBearing ::
  Double
  -> Bearing
modBearing x =
  Bearing (x `mod'` 360)

-- | A prism on bearing to a double between 0 inclusive and 360 exclusive.
--
-- >>> 7 ^? degreeBearing
-- Just (Bearing 7.0000)
--
-- >>> 0 ^? degreeBearing
-- Just (Bearing 0.0000)
--
-- >>> 359 ^? degreeBearing
-- Just (Bearing 359.0000)
--
-- >>> 359.997 ^? degreeBearing
-- Just (Bearing 359.9970)
--
-- >>> 360 ^? degreeBearing
-- Nothing
--
-- prop> all (\m -> degreeBearing # m == n) (n ^? degreeBearing)
degreeBearing ::
  Prism' Double Bearing
degreeBearing =
  prism'
    (\(Bearing i) -> i)
    (\i -> case i >= 0 && i < 360 of
             True -> Just (Bearing i)
             False -> Nothing)

-- | A prism on bearing to a double between 0 and π exclusive.
--
-- >>> (2 * pi - 0.0000000001) ^? radianBearing
-- Just (Bearing 360.0000)
--
-- >>> 0 ^? radianBearing
-- Just (Bearing 0.0000)
--
-- >>> 0.001 ^? radianBearing
-- Just (Bearing 0.0573)
--
-- >>> 1.78391 ^? radianBearing
-- Just (Bearing 102.2105)
--
-- >>> pi ^? radianBearing
-- Just (Bearing 180.0000)
--
-- >>> (2 * pi) ^? radianBearing
-- Nothing
--
-- >>> (-0.001) ^? radianBearing
-- Nothing
radianBearing ::
  Prism' Double Bearing
radianBearing =
  iso (\n -> n * 180 / pi) (\n -> n * pi / 180) . degreeBearing

class HasBearing t where
  bearing ::
    Lens' t Bearing

instance HasBearing Bearing where
  bearing =
    id