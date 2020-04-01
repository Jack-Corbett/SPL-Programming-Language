module Main where
import           Grammar
import           Interpreter
import           System.Environment
import           System.IO
import           Tokens

-- Main function, that gets file name, lexes and parses it and then interprets it
main :: IO ()
main = do
    args <- getArgs
    contents <- readFile (head args)
    let expr = parseSPL $ alexScanTokens contents
    interpretExpr expr [] []
    return ()

-- Interprets an expression list
interpretExpr :: ExpList -> [Int] -> Environment -> IO ((ExpList, Environment), [Int])
interpretExpr (ExpMulti x y) f e = do
    -- Evaluate the first part of the ExpMulti, storing the environment and input list
    ((_, e1), xs) <- interpretExpr x f e
    interpretExpr y xs e1

-- If Output encountered, get result and output it
interpretExpr x@(ExpSingle (Output xs)) f e = do
    let y@(ExpSingle (OutputExp cs), _) = ceMachine x f e
    outputValues (OutputExp cs)
    return (y, f)

-- If WhileInput encountered, check if EOF
interpretExpr x@(ExpSingle (WhileInput es)) f e = do
    end <- isEOF
    -- if EOF, return given expression and continue
    if end then
        return ((x, e), f)
    -- else, get next line, set as the new input list, and interpret inner explist
    else do
        line <- getLine
        let xs = map (\x -> read x :: Int) (words line)
        ((_, e1), _) <- interpretExpr es xs e
        interpretExpr x xs e1

interpretExpr z@(ExpSingle (If b x y)) f e = do
    let (c, e1) = ceMachine z f e
    interpretExpr c f e1

-- Base case - interpret as normal
interpretExpr x f e = do
    let (es, e1) = ceMachine x f e
    return ((es, e1), f)

outputValues :: Exp -> IO ()
outputValues (OutputExp es) = do
    let headValues = map (\(Integer x) -> x) es
    let stringValue = init (tail $ show headValues)
    putStrLn (map (\x -> if x==',' then ' ' else x) stringValue)