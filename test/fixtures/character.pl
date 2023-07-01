% axioms
% member(E, L) should be true if E is a member of L
member(E, [E|_]).
member(E, [_|L]) :- member(E, L).

% range(L, U, R) should be true if R is a list of integers from L to U-1
range(L, U, []) :- L >= U.
range(L, U, [L|T]) :- L < U, L1 is L+1, range(L1, U, T).

% range(L, U, S, R) should be true if R is a list of integers from L to U-1, with step size S
range(L, U, _, []) :- L >= U.
range(L, U, S, [L|T]) :- L < U, L1 is L+S, range(L1, U, S, T).

% game axioms
hour(S) :- range(0, 24, L), member(S, L).
:- dynamic current_hour/1.
with_hour(H) :- current_hour(H), hour(H).

:- dynamic character/1.
:- dynamic item/1.
:- dynamic food/1.

:- dynamic likes/2.
:- dynamic finds/2.
:- dynamic has/2.

state(idling). state(eating). state(sleeping).
:- dynamic character_state/2.
with_state(C, S) :- character(C), state(S), character_state(C, S).

hungriness(S) :- range(0, 100, L), member(S, L).
:- dynamic character_hungriness/2.
with_hungriness(C, H) :- character_hungriness(C, H), hungriness(H).

tiredness(S) :- range(0, 100, L), member(S, L).
:- dynamic character_tiredness/2.
with_tiredness(C, T) :- character_tiredness(C, T), tiredness(T).

% rules
can_sleep(C) :-
    with_hour(H),
    with_state(C, S), with_tiredness(C, T),
    \+ S=sleeping,
    (H >= 22 ; H < 8 ; (H >= 12, H < 14); T @> 80).

can_wakeup(C) :-
    with_hour(H),
    with_state(C, S),
    S=sleeping,
    (H = 8 ; H = 14).

can_pick(C, I) :-
    with_state(C, S),
    \+ S=sleeping,
    item(I),
    finds(C, I),
    likes(C, I).

can_eat(C, I) :-
    with_state(C, S),
    with_hungriness(C, H),
    \+ S=sleeping,
    H @< 20,
    item(I), food(I),
    (has(C, I); finds(C, I)).

% make decisions
make_decision(Character, Action, Item) :-
    can_sleep(Character), Action = sleep, Item = nil;
    can_wakeup(Character), Action = wakeup, Item = nil;
    can_pick(Character, Item), Action = pick;
    can_eat(Character, Item), Action = eat.
