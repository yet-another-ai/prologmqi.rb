country(britain). country(sweden). country(denmark). country(germany). country(norway).
drink(tea). drink(coffee). drink(milk). drink(beer). drink(water).
sport(polo). sport(baseball). sport(hockey). sport(billiards). sport(soccer).
pet(dog). pet(bird). pet(cat). pet(horse). pet(fish).
colour(red). colour(green). colour(white). colour(yellow). colour(blue).
next_to(A, B, Ls) :- append(_, [A,B|_], Ls).
next_to(A, B, Ls) :- append(_, [B,A|_], Ls).
h(A, B, C, D, E) :- country(A), drink(B), sport(C), pet(D), colour(E).

houses(H):-
	% each house in the list H of houses is represented as:
  %      h(Country, Drink, Sport, Pet, Colour)
  length(H, 5),
  member(h(britain, _, _, _, red), H), % The Brit lives in a red house
  member(h(sweden, _, _, dog, _), H), % The Swede keeps dogs
  member(h(denmark, tea, _, _, _), H), % The Dane drinks tea
  next_to(h(_,_,_,_,green), h(_,_,_,_,white), H),  % The green house is on the left of the white house
  member(h(_, coffee, _, _, green), H), % The green house owner drinks coffee
  member(h(_, _, polo, bird, _), H), % The person who plays polo rears birds
  member(h(_, _, hockey, _, yellow), H), % The owner of the yellow house plays hockey
  H = [_,_,h(_, milk, _, _, _),_,_], %  The man living in the house right in the center drinks milk
  H = [h(norway,_,_,_,_)|_], % The Norwegian lives in the first house
  next_to(h(_, _, baseball, _, _), h(_, _, _, cat, _), H), % The man who plays baseball lives next to the man who keeps cats
  next_to(h(_, _, _, horse, _), h(_, _, hockey, _, _), H),  % The man who keeps horses lives next to the one who plays hockey
  member(h(_, beer, billiards, _, _), H), % The man who plays billiards drinks beer
  member(h(germany, _, soccer, _, _), H), % The German plays soccer
  next_to(h(norway, _, _, _, _), h(_, _, _, _, blue), H), % The Norwegian lives next to the blue house.
  next_to(h(_, _, baseball, _, _), h(_, water, _, _, _), H),  % The man who plays baseball has a neighbor who drinks water
  member(h(_, _, _, fish, _), H). % someone owns fish

fish(X) :- houses(H), member(h(X, _, _, fish, _), H).
