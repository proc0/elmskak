module Data.Query exposing (..)

import Maybe.Extra exposing (isJust)
import List exposing (head, any)

import Data.Type exposing (..)
import Data.Cast exposing (..)

-- general queries
--================--

isClick : Event -> Bool
isClick event = 
    case event of
        Click _ -> True
        _ -> False


isColor : Color -> Piece -> Bool
isColor color piece = 
    piece.color == color

opponent : Color -> Color
opponent col =
    case col of
        White -> Black
        Black -> White
        
passanting : Piece -> Bool
passanting pawn =
    let (y,x) =
        pawn.point
    in 
    case pawn.color of
        White -> y == 3
        Black -> y == 4

isPinner : Piece -> Bool
isPinner piece =
    case piece.role of
        Bishop -> True
        Rook -> True
        Queen -> True
        _ -> False

stationary : Piece -> Bool
stationary piece = 
    piece.tick == 0

withPiece : (Piece -> Bool) -> Square -> Bool
withPiece fn square =
    case square.piece of
        Just piece -> fn piece
        _ -> False

isOccupied : Square -> Bool
isOccupied square = isJust square.piece

isVacant : Square -> Bool
isVacant = not << isOccupied

isKing : Piece -> Bool
isKing piece =
    case piece.role of
        King -> True
        _ -> False

isKingSquare : Square -> Bool
isKingSquare sq =
    case sq.piece of
        Just pc ->
            isKing pc
        _ -> False


isNewRook : Square -> Bool
isNewRook square =
    case square.piece of
        Just pc ->
            case pc.role of
                Rook -> 
                    pc.tick == 0
                _ -> False
        _ -> False

isUntouched : Square -> Bool
isUntouched square =
    case square.piece of
        Just piece -> piece.tick == 1
        _ -> False

hasPawn : Square -> Bool
hasPawn square =
    case square.piece of
        Just piece ->
            case piece.role of
                Pawn -> True
                _ -> False
        _ -> False

friendlyOccupied : Color -> Square -> Bool
friendlyOccupied color square =
    withPiece (isColor color) square
