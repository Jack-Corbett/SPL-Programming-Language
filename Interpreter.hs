module Interpreter where
import           Grammar
import           Tokens

-- Data types used for type checking
data Type = IntType
          | BoolType
          deriving (Show, Eq)

-- Environment is a binding from a variable to a terminated value
type Environment = [(String, Exp)]

-- CE Machine that evaluates ExpList given to it. Kontinuation is encapsulated through where statements
ceMachine :: ExpList -> [Int] -> Environment -> (ExpList, Environment)
-- I/O
ceMachine (ExpSingle (Output xs)) f e 
    | typeChecker (Output xs) == IntType = (ExpSingle (OutputExp cs), e)
    | otherwise = error "Type error"
    where es = parseOutputList xs
          cs = map (\(ExpSingle y) -> y) [fst $ ceMachine (ExpSingle x) f e | x <- es]

ceMachine (ExpSingle (Input x)) f e
    | typeCheck && x' < length f = (ExpSingle (Integer (f !! x')), e)
    | typeCheck = error "Index larger than number of streams"
    | otherwise = error "Type error"
    where typeCheck = typeChecker (Input x) == IntType
          ExpSingle (Integer x') = fst $ ceMachine (ExpSingle x) f e

-- Numerical functions
ceMachine (ExpSingle (Add x y)) f e
    | typeChecker (Add x y) == IntType = (ExpSingle (Integer (x' + y')), e)
    | otherwise = error "Type error"
    where ExpSingle (Integer x') = fst $ ceMachine (ExpSingle x) f e
          ExpSingle (Integer y') = fst $ ceMachine (ExpSingle y) f e

ceMachine (ExpSingle (Minus x y)) f e
    | typeChecker (Minus x y) == IntType = (ExpSingle (Integer (x' - y')), e)
    | otherwise = error "Type error"
    where ExpSingle (Integer x') = fst $ ceMachine (ExpSingle x) f e
          ExpSingle (Integer y') = fst $ ceMachine (ExpSingle y) f e

ceMachine (ExpSingle (Multiply x y)) f e
    | typeChecker (Multiply x y) == IntType = (ExpSingle (Integer (x' * y')), e)
    | otherwise = error "Type error"
    where ExpSingle (Integer x') = fst $ ceMachine (ExpSingle x) f e
          ExpSingle (Integer y') = fst $ ceMachine (ExpSingle y) f e

ceMachine (ExpSingle (Divide x y)) f e
    | typeChecker (Divide x y) == IntType = (ExpSingle (Integer (x' `div` y')), e)
    | otherwise = error "Type error"
    where ExpSingle (Integer x') = fst $ ceMachine (ExpSingle x) f e
          ExpSingle (Integer y') = fst $ ceMachine (ExpSingle y) f e

ceMachine (ExpSingle (Modulo x y)) f e
    | typeChecker (Modulo x y) == IntType = (ExpSingle (Integer (x' `mod` y')), e)
    | otherwise = error "Type error"
    where ExpSingle (Integer x') = fst $ ceMachine (ExpSingle x) f e
          ExpSingle (Integer y') = fst $ ceMachine (ExpSingle y) f e

ceMachine (ExpSingle (Negate x)) f e
    | typeChecker (Negate x) == IntType = (ExpSingle (Integer (-1 * x')), e)
    | otherwise = error "Type error"
    where ExpSingle (Integer x') = fst $ ceMachine (ExpSingle x) f e

-- Comparisons
ceMachine (ExpSingle (Eq x y)) f e
    | typeCheck && x' == y' = (ExpSingle BoolTrue, e)
    | typeCheck = (ExpSingle BoolFalse, e)
    | otherwise = error "Type error"
    where typeCheck = typeChecker (Eq x y) == BoolType
          ExpSingle (Integer x') = fst $ ceMachine (ExpSingle x) f e
          ExpSingle (Integer y') = fst $ ceMachine (ExpSingle y) f e

ceMachine (ExpSingle (LessThanEqual x y)) f e
    | typeCheck && x' <= y' = (ExpSingle BoolTrue, e)
    | typeCheck = (ExpSingle BoolFalse, e)
    | otherwise = error "Type error"
    where typeCheck = typeChecker (LessThanEqual x y) == BoolType
          ExpSingle (Integer x') = fst $ ceMachine (ExpSingle x) f e
          ExpSingle (Integer y') = fst $ ceMachine (ExpSingle y) f e

ceMachine (ExpSingle (GreaterThanEqual x y)) f e
    | typeCheck && x' >= y' = (ExpSingle BoolTrue, e)
    | typeCheck = (ExpSingle BoolFalse, e)
    | otherwise = error "Type error"
    where typeCheck = typeChecker (GreaterThanEqual x y) == BoolType
          ExpSingle (Integer x') = fst $ ceMachine (ExpSingle x) f e
          ExpSingle (Integer y') = fst $ ceMachine (ExpSingle y) f e

ceMachine (ExpSingle (LessThan x y)) f e
    | typeCheck && x' < y' = (ExpSingle BoolTrue, e)
    | typeCheck = (ExpSingle BoolFalse, e)
    | otherwise = error "Type error"
    where typeCheck = typeChecker (LessThan x y) == BoolType
          ExpSingle (Integer x') = fst $ ceMachine (ExpSingle x) f e
          ExpSingle (Integer y') = fst $ ceMachine (ExpSingle y) f e

ceMachine (ExpSingle (GreaterThan x y)) f e
    | typeCheck && x' > y' = (ExpSingle BoolTrue, e)
    | typeCheck = (ExpSingle BoolFalse, e)
    | otherwise = error "Type error"
    where typeCheck = typeChecker (GreaterThan x y) == BoolType
          ExpSingle (Integer x') = fst $ ceMachine (ExpSingle x) f e
          ExpSingle (Integer y') = fst $ ceMachine (ExpSingle y) f e

ceMachine (ExpSingle (NotEqual x y)) f e
    | typeCheck && x' /= y' = (ExpSingle BoolTrue, e)
    | typeCheck = (ExpSingle BoolFalse, e)
    | otherwise = error "Type error"
    where typeCheck = typeChecker (NotEqual x y) == BoolType
          ExpSingle (Integer x') = fst $ ceMachine (ExpSingle x) f e
          ExpSingle (Integer y') = fst $ ceMachine (ExpSingle y) f e

-- Setting a variable
ceMachine (ExpSingle (Decl s w)) f e
    | typeCheck && null xs = (ExpSingle w', (s, w') : e)
    | typeCheck = (ExpSingle w', (s, w') : xs')
    | otherwise = error "Type error"
    where typeCheck = typeChecker (Decl s w) == IntType
          xs = [x | x <- e, fst x == s]
          xs' = [x | x <- e, fst x /= s]
          (ExpSingle w') = fst $ ceMachine (ExpSingle w) f e

-- Substitute a variable
ceMachine (ExpSingle (Var x)) _ e
    | length w == 1 = (ExpSingle (head w), e)
    | otherwise = error "Variable not defined"
    where w = [ z | (y, z) <- e, x == y]

-- If statement
ceMachine (ExpSingle (If b x y)) f e
    | typeCheck && b' == BoolTrue = (x, e)
    | typeCheck = (y, e)
    | otherwise = error "Type error"
    where typeCheck = typeChecker b == BoolType
          (ExpSingle b') = fst $ ceMachine (ExpSingle b) f e

-- Generic case
ceMachine x _ e = (x, e)

-- Type Checker
typeChecker :: Exp -> Type

-- Numerical functions
typeChecker e@(Add x y)
    | typeChecker x == IntType && typeChecker y == IntType = IntType
    | otherwise = error ("Type error in add function " ++ show e)

typeChecker e@(Minus x y)
    | typeChecker x == IntType && typeChecker y == IntType = IntType
    | otherwise = error ("Type error in subtraction function " ++ show e)

typeChecker e@(Multiply x y)
    | typeChecker x == IntType && typeChecker y == IntType = IntType
    | otherwise = error ("Type error in multiply function " ++ show e)

typeChecker e@(Divide x y)
    | typeChecker x == IntType && typeChecker y == IntType = IntType
    | otherwise = error ("Type error in divide function " ++ show e)

typeChecker e@(Modulo x y)
    | typeChecker x == IntType && typeChecker y == IntType = IntType
    | otherwise = error ("Type error in modulo function " ++ show e)

typeChecker e@(Negate x)
    | typeChecker x == IntType = IntType
    | otherwise = error ("Type error in negate function " ++ show e)

-- Comparator Operators
typeChecker e@(Eq x y)
    | typeChecker x == IntType && typeChecker y == IntType = BoolType
    | otherwise = error ("Type error in equals operator " ++ show e)

typeChecker e@(LessThanEqual x y)
    | typeChecker x == IntType && typeChecker y == IntType = BoolType
    | otherwise = error ("Type error in less-than equals operator " ++ show e)

typeChecker e@(GreaterThanEqual x y)
    | typeChecker x == IntType && typeChecker y == IntType = BoolType
    | otherwise = error ("Type error in greater-than equals operator " ++ show e)

typeChecker e@(LessThan x y)
    | typeChecker x == IntType && typeChecker y == IntType = BoolType
    | otherwise = error ("Type error in less-than operator " ++ show e)

typeChecker e@(GreaterThan x y)
    | typeChecker x == IntType && typeChecker y == IntType = BoolType
    | otherwise = error ("Type error in greater-than operator " ++ show e)

typeChecker e@(NotEqual x y)
    | typeChecker x == IntType && typeChecker y == IntType = BoolType
    | otherwise = error ("Type error in not equal operator " ++ show e)

-- Vars and I/O
typeChecker e@(Decl _ x)
    | typeChecker x == IntType = IntType
    | otherwise = error ("Type error in declaration " ++ show e)

typeChecker e@(Input x)
    | typeChecker x == IntType = IntType
    | otherwise = error ("Type error in input call " ++ show e)

typeChecker e@(Output xs)
    | and (map (\x -> typeChecker x == IntType) (parseOutputList xs)) = IntType
    | otherwise = error ("Type error in output " ++ show e)

-- Base case
typeChecker (Integer _) = IntType
typeChecker (Var _) = IntType
typeChecker BoolTrue = BoolType
typeChecker BoolFalse = BoolType

-- Get an 'output list' and convert to a list of expressions
parseOutputList :: OutputList -> [Exp]
parseOutputList (OutputMulti e f) = parseOutputList e ++ parseOutputList f
parseOutputList (OutputSingle x)  = [x]

-- Tuples
fstThree :: (a, b, c) -> a
fstThree (x, _, _) = x

sndThree :: (a, b, c) -> b
sndThree (_, y, _) = y

thdThree :: (a, b, c) -> c
thdThree (_, _, z) = z

fstFour :: (a, b, c, d) -> a
fstFour (x, _, _, _) = x

sndFour :: (a, b, c, d) -> b
sndFour (_, y, _, _) = y

thdFour :: (a, b, c, d) -> c
thdFour (_, _, z, _) = z

fourFour :: (a, b, c, d) -> d
fourFour (_, _, _, w) = w