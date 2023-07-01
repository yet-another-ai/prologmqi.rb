:- dynamic likes/2.

friends(X, Y) :- likes(X, Y), likes(Y, X).
