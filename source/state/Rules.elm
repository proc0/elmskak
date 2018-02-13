module State.Rules exposing (..)

import Array exposing (..)
import Matrix exposing (..)
import Debug exposing (..)

import Data.Type exposing (..)
import Data.Tool exposing (..)

pieceMoves : Move -> Board -> List (Location -> Location)
pieceMoves move board = 
    let lc = move.start
        getParallels = parallels board
        getDiagonals = diagonals board
        moves role =
            case role of
                Pawn    -> pawnMoves move board
                Bishop  -> getDiagonals lc
                Rook    -> getParallels lc 
                Queen   -> List.append (getDiagonals lc) (getParallels lc)                
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
    in case move.piece.color of 
        White -> moves move.piece.role
        Black -> moves move.piece.role

pawnMoves : Move -> Board -> List (Location -> Location)
pawnMoves move board = 
    let pawnMove =
            case move.piece.color of
                White -> [ up 1 ]
                Black -> [ down 1 ]
        -- pawn potential moves:
        -- forward move (two if first move),
        -- capture moves if a piece is there              
        totalMoves = 
            Maybe.map (\mv -> 
                (pawnFirstMove mv) 
                ++ (pawnCaptures mv board) 
                ++ pawnMove
            ) (Just move)
    in Maybe.withDefault [] totalMoves

pawnFirstMove : Move -> List (Location -> Location)
pawnFirstMove mv =
    -- check rank and add two steps
    let whiteMove (y,x) =
            if y == 6
            then Just (up 2)
            else Nothing
        blackMove (y,x) =
            if y == 1
            then Just (down 2)
            else Nothing
    -- wrap and perform respective check
    in List.concatMap (\pc ->
                List.filterMap (\{ piece, start } -> 
                    case piece.color of
                        White -> whiteMove start
                        Black -> blackMove start
                    ) [pc]
        ) [mv]

pawnCaptures : Move -> Board -> List (Location -> Location)
pawnCaptures mv bd =
        let position = mv.start
            eats color = 
                case color of
                    White ->
                        [ up 1 >> left 1
                        , up 1 >> right 1
                        ]
                    Black ->
                        [ down 1 >> left 1
                        , down 1 >> right 1
                        ]
            checkSquare moves =
                let target = Matrix.get (moves position) bd
                    posons = Maybe.map (\t -> Maybe.map (\_ -> moves) t.piece) target
                in Maybe.withDefault (Just idle) posons
        in List.filterMap checkSquare (eats mv.piece.color)
                   
-- pedantic
idle : Location -> Location
idle l = l

up : Int -> Location -> Location
up n (y,x) = loc (y - n) x


down : Int -> Location -> Location
down n (y,x) = loc (y + n) x

left : Int -> Location -> Location
left n (y,x) = loc y (x - n)


right   : Int -> Location -> Location
right n (y,x) = loc y (x + n)


--idle : Position -> Position
--idle p = p

--up : Int -> Position -> Position
--up n p = 
--    { x = p.x
--    , y = p.y - n
--    }

--down : Int -> Position -> Position
--down n p = 
--    { x = p.x
--    , y = p.y + n
--    }

--left : Int -> Position -> Position
--left n p = 
--    { x = p.x - n
--    , y = p.y 
--    }

--right   : Int -> Position -> Position
--right n p = 
--    { x = p.x + n
--    , y = p.y
--    }


diagonals : Board -> Location -> List (Location -> Location)
diagonals board point = 
    let directions = 
            [ (up, left)
            , (down, left)
            , (up, right)
            , (down, right)
            ]
        stepRange = List.map ((+) 1) boardside
        curPiece = 
            let sq = findSquare point board
            in Maybe.withDefault nullPiece sq.piece

        step = List.foldl 
            (\(d1,d2) (m, c) -> 
                List.foldl (\i (memo, cont) -> 
                    let nextStep = (d1 i) >> (d2 i)
                    -- stop processing if piece found
                    in if cont
                        then 
                            let blocking = findSquare (nextStep point) board
                            in case blocking.piece of
                                Just {color} -> 
                                    if color /= curPiece.color
                                    then (nextStep::memo, False)
                                    else (memo, False)
                                Nothing -> (nextStep::memo, True)
                        else (memo, False)
                    ) (m, True) stepRange) ([],True)
    in fst <| step directions

parallels : Board -> Location -> List (Location -> Location)
parallels board point =
    let directions = 
            [ up
            , right
            , down
            , left
            ]
        stepRange = List.map ((+) 1) boardside
        curPiece = 
            let sq = findSquare point board
            in Maybe.withDefault nullPiece sq.piece

        step = List.foldl 
            (\d (m, c) -> 
                List.foldl (\i (memo, cont) -> 
                        if cont
                        then 
                            let blocking = findSquare (d i point) board
                            in case blocking.piece of
                                Just {color} ->
                                    if color /= curPiece.color
                                    then ((d i)::memo, False)
                                    else (memo, False)
                                Nothing -> ((d i)::memo, True)                            
                        else (memo, False)
                        ) (m, True) stepRange) ([],True)
    in fst <| step directions

findSquare : Location -> Board -> Square
findSquare pos board = 
    let sq = Matrix.get pos board
    in case sq of
            Just s -> s
            Nothing -> emptySquare

