module Data.Main exposing (..)

import Mouse exposing (..)
import Data.Game exposing (..)

type alias Model =
    { game : GameModel
    , position : Mouse.Position
    , drag : Maybe Drag
    }

type alias Drag =
    { start : Mouse.Position
    , current : Mouse.Position
    }

type Msg = 
    SquareClick Mouse.Position
    | PieceMove Move
    | DragStart Mouse.Position
    | DragAt Mouse.Position
    | DragEnd Mouse.Position