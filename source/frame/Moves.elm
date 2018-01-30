module Frame.Moves exposing (..)

import Matrix exposing (..)
import Debug exposing (..)

import Data.Main exposing (..)
import Data.Game as Game exposing (..)
import Frame.Movement exposing (..)
import Settings exposing (..)
import Toolkit exposing (..)

getPossible : Square -> Board -> List Square
getPossible square board = 
    case square.piece of
        Just pc -> List.map (flip moveSquare square) (pieceMoves square board)
        Nothing -> []

moveSquare : (Position -> Position) -> Square -> Square
moveSquare move sq = Square (move sq.position) sq.piece True

pieceMoves : Square -> Board -> List (Position -> Position)
pieceMoves square board = 
    let ps = square.position
        getCardinals p = cardinals board p
        getDiagonals p = diagonals board p
        moves p =
            case p of
                Pawn    -> pawnMoves square board
                Bishop  -> getDiagonals ps
                Rook    -> getCardinals ps 
                Queen   -> List.append (getDiagonals ps) (getCardinals ps)                
                Knight -> 
                    [ up 2 >> right 1
                    , up 2 >> left 1
                    , down 2  >> left 1
                    , down 2  >> right 1
                    , left 2  >> up 1
                    , left 2  >> down 1
                    , right 2 >> up 1
                    , right 2 >> down 1
                    ]
                King ->
                    [ up 1
                    , down 1
                    , left 1
                    , right 1
                    , up 1 >> left 1
                    , up 1 >> right 1
                    , down 1 >> left 1
                    , down 1 >> right 1
                    ]
                _ -> []
    in case square.piece of
        Just pc ->
            case pc of 
                White p -> moves p
                Black p -> moves p
        Nothing -> []