% MINESWEEPER

%this is the main function. Run it to start the game.
main :- 
	write("Welcome to minesweeper!"), nl,
	choose_board(Nrow,Ncol,Nmines,Nlives),	
	initialize_game(Nrow,Ncol,Nmines,Nlives).
	

%choose_board(Nrow,Ncol,Nmines,Nlives) allows user to select from 3 classic boards (9x9, 16x16, 16x30) or input their own
choose_board(Nrow,Ncol,Nmines,Nlives) :-
	write("Choose your board by inputting the corresponding number."), nl,
	write("All classic games start with 1 life."), nl,
	write("1. Classic Beginner (9x9)"), nl,
	write("2. Classic Intermediate (16x16)"), nl,
	write("3. Classic Expert (16x30)"), nl,
	write("4. Make my own!"), nl,
	write("Input choice: "), read(Choice),
	correct_game(Nrow,Ncol,Nmines,Nlives,Choice).

%validate_inputs is true if Nrow,Ncol,Nmines, and Nlives, are valid. If they are the game process is continued. If not, the game process is terminated.
initialize_game(Nrow,Ncol,Nmines,Nlives) :- 
	print_info(Nrow,Ncol,Nmines), nl,
	generate_game_board(Nrow,Ncol,Nmines,Gameboard),
	empty_game_board(Nrow,Ncol,Revealed),
	print_game_board(Nrow,Ncol,Gameboard,Revealed),
	start_game(Nrow,Ncol,Nlives,Nmines,Gameboard,Revealed).	

	
%correct_game(Nrow,Ncol,Nmines,Nlives,Choice) returns true if Nrow,Ncol,Nmines,and Nlives correctly corresponds to user's choice of start board.
correct_game(9,9,10,1,1).
correct_game(16,16,40,1,2).
correct_game(16,30,99,1,3).
correct_game(Nrow,Ncol,Nmines,Nlives,4) :- 
	get_info(Nrow,Ncol,Nmines,Nlives),
	valid_inputs(Nrow,Ncol,Nmines,Nlives).
correct_game(Nrow,Ncol,Nmines,Nlives,Choice) :- 
	\+ valid_board_choice(Choice),
	write("Bad input. Please choose again."), nl, nl,
	choose_board(Nrow,Ncol,Nmines,Nlives).

%get_info(Nrow,Ncol,Nmines,Nlives) reads user input and is true if each of the above are valid inputs.
get_info(Nrow,Ncol,Nmines,Nlives) :-
	write("Number of rows:    (max 99)  "), read(Nrow), 
	write("Number of columns: (max 50)  "), read(Ncol), 
	write("Number of mines:             "), read(Nmines),
	write("Number of lives:             "), read(Nlives),nl.

%valid_inputs is true if Nrow, Ncol, Nmines, and Nlives are valid. If they are, will make a board with those characteristics. If not, game process is restarted. 
valid_inputs(Nrow,Ncol,Nmines,Nlives) :- 
	check_inputs(Nrow,Ncol,Nmines,Nlives).	
valid_inputs(Nrow,Ncol,Nmines,Nlives) :-
	\+ check_inputs(Nrow,Ncol,Nmines,Nlives),
	write("Bad input(s). Restarting game."), nl, nl,
	main.	

%check_inputs(Nrow,Ncol,Nmines,Nlives) is true if each of the above parameters are okay for game creation.
check_inputs(Nrow,Ncol,Nmines,Nlives) :-
	number(Nrow),number(Ncol),number(Nmines),number(Nlives),
	Nrow > 0, Nrow < 100, Ncol > 0, Ncol < 51, Nmines > 0, Nmines < Nrow*Ncol, Nlives > 0.
	
%valid_board_choice(Choice) returns true if choice of board is valid
valid_board_choice(1).
valid_board_choice(2).
valid_board_choice(3).
valid_board_choice(4).	



	
%----------------------------------------SECTION A: BOARD PRINTING PREDICATES/FUNCIONS-----------------------------------------

%Print_info(Nrow,Ncol,Nmines) prints out the information fo the initial game board.
print_info(Nrow,Ncol,Nmines) :-
	write("You have initialized a game board with: "), nl,
	write(Nrow), write(" rows and "), write(Ncol), write(" columns, totalling"), nl,
	Ncells is Ncol*Nrow,
	write(Ncells), write(" cells with " ), write(Nmines), write(" mines"), nl.

%print_number(Num) prints Num with either one trailing space or bordered spaces depending on the number.
print_number(Num) :- Num < 10, write(" "),write(Num),write(" ").
print_number(Num) :- Num > 9, write(Num), write(" ").

%printGameboard is called after initialization and each player move. It prints out row and column numbers, along with the 
%current state of the board.
print_game_board(Nrow,Ncol,Gameboard, Revealed):-
	print_header(Ncol),
	print_separator(Ncol),
	print_field(Nrow,Ncol,Gameboard, Revealed),
	print_separator(Ncol),
	print_header(Ncol).

%Repeat(Str,Ntimes) will write Str out Ntimes, all concatenated to each other.
repeat(_,0).
repeat(Str,Ntimes) :- 
		Ntimes>0,
		write(Str),NextNo is Ntimes-1, repeat(Str,NextNo).

%print_header(Ncol) Writes the header (and footer) of the game board, labelling the columns
print_header(Ncol) :- 
	write("   |"), print_header_helper(Ncol,1), write("|   "),nl.
print_header_helper(0,_).
print_header_helper(CurCol,CurNo) :-
	CurCol > 0, 
	print_number(CurNo),
	NextCol is CurCol-1,
	NextNo is CurNo+1, print_header_helper(NextCol, NextNo).


%print_separator(Ncol) prints the separating lines from the header/footer and gameboard; length based on Ncol.
print_separator(Ncol) :-
	write("---+"), repeat("---",Ncol), write("+---"), nl.

%print_field(Nrow,Ncol,Gameboard,revealed) prints out the game board, with row numbers labelled on the side.
print_field(Nrow,Ncol,Gameboard, Revealed) :- 
	print_field_helper(Nrow,Ncol,Gameboard,1, Revealed).
print_field_helper(Nrow,_,_,CurRow, _) :- CurRow > Nrow.
print_field_helper(Nrow,Ncol,Gameboard,CurRow, Revealed) :- 
	print_number(CurRow), write("|"), 
	list_ref(CurRow,Gameboard,GameboardRow),
	print_game_board_row(GameboardRow,CurRow,1,Revealed), 
	write("|"), write("  "), write(CurRow),nl,
	NextRow is CurRow + 1, print_field_helper(Nrow,Ncol,Gameboard,NextRow,Revealed).

%print_game_board_row(GameboardRow) print the row of the gameboard.
%If revealed[CurRow,CurCol] is 1, then the character is printed; otherwise a "." is printed.
print_game_board_row([],_,_,_).
print_game_board_row([H|T],CurRow, CurCol, Revealed) :-
	list_ref_2d(CurRow,CurCol,Revealed,RE),
	get_symbol(H,RE,R),
	write(" "), write(R), write(" "),
	Next is CurCol+1,
	print_game_board_row(T,CurRow, Next, Revealed).

%get_symbol is true when game board element is R and RE is 1 (element is revealed), or
%R is . and RE is z (element has not been revealed).
get_symbol(_,z,".").
get_symbol(R,1,R).
	
%---------------------------------------------SECTION B: HELPFUL LIST OPERATIONS-------------------------
	
%build-list(N,R) is true when R is a list of numbers 1 to N, inclusive.
build_list(N,R) :- build_list(N,1,R).
build_list(N,Cur,[Cur]) :- Cur is N.
build_list(N,Cur,[Cur|R]) :- Cur < N, NextNo is Cur+1, build_list(N,NextNo,R).

% repeat_list(E,N,R) is true when R is a list of length N with Sym repeated N times.
repeat_list(_,0,[]).
repeat_list(E,N,[E|R]) :- N>0, Next is N-1, repeat_list(E,Next,R).
	
%randselect(N,L,R) is true when list R consists of N elements removed from list L randomly.
randselect(N,L,R) :- randselect(N,0,L,R).
randselect(N,N,_,[]).
randselect(N,Cur,L,[RandEl|R]) :- 
	Cur < N, length(L,Length), Upbound is Length+1, random(1,Upbound,RandInd),
	list_ref(RandInd,L,RandEl),
	select(RandEl,L,Sublist),NextNo is Cur+1,
	randselect(N,NextNo,Sublist,R).

%list_ref_2d(Row,Col,L,R) is true when R corresponds to the element (Row,Col) in the 2d list L.
list_ref_2d(Row,Col,L,R) :-
	list_ref(Row,L,RowList), list_ref(Col,RowList,R).
	
%list_ref(N,L,R) is true when R is the Nth element of L. 1-based indexing.
list_ref(N,L,R) :- length(L,Length), Length+1 > N, list_ref(N,1,L,R).
list_ref(N,N,[R|_],R).
list_ref(N,Cur,[_|T],R) :- Cur < N, Next is Cur+1, list_ref(N,Next,T,R).

%list_set(N,E,L,R) is true when R is L with the Nth element changed to E.
list_set(N,_,L,L) :- N < 1.
list_set(N,E,L,R) :- list_set(N,1,E,L,R).
list_set(N,N,E,[_|T],[E|T]).
list_set(N,Cur,E,[H|T],[H|R]) :- Cur < N, Next is Cur + 1, list_set(N,Next,E,T,R).

%list_set_2d(Row,Col,E,L,R) is true when R corresponds to the 2d list L with (Row,Col) changed to E.
list_set_2d(Row,_,_,L,L) :- Row < 1.
list_set_2d(Row,Col,E,L,R) :-
	list_ref(Row,L,RowList), list_set(Col,E,RowList,NewRowList),
	list_set(Row,NewRowList,L,R).	

%---reveal nearby empty blocks-----

check_rl(R,1) :- R < 1.
check_rl(R,R) :- R >= 1.
check_cl(C,1) :- C < 1.
check_cl(C,C) :- C >=1.
check_row(Nrow,R1,Nrow) :- R1 >= Nrow.
check_row(Nrow,R1,R1) :- R1 < Nrow.
check_col(Ncol,C1,Ncol) :- C1 >= Ncol.
check_col(Ncol,C1,C1) :- C1 < Ncol.

reveal_more(Row,Col,D,G,D) :-
	list_ref_2d(Row,Col,G,x).

reveal_more(Row,Col,Disp,Gb,New) :-
	list_ref_2d(Row,Col,Gb,T),
	number(T),
	list_set_2d(Row,Col,1,Disp,New).

list_update_2d(Nrow,Ncol,Row,Col,D,G,V,N) :- 
	list_ref_2d(Row,Col,G,V),
	V is 0,
	C is Col-1, R is Row-1, C1 is Col+1, R1 is Row+1,
	check_rl(R,R0), check_cl(C,C0),
	check_row(Nrow,R1,R2), check_col(Ncol,C1,C2),
	reveal_more(Row,C0,D,G,N0), reveal_more(Row,C2,N0,G,N1),
	reveal_more(R0,C0,N1,G,N2), reveal_more(R0,Col,N2,G,N3), reveal_more(R0,C2,N3,G,N4),
	reveal_more(R2,C0,N4,G,N5), reveal_more(R2,Col,N5,G,N6), reveal_more(R2,C2,N6,G,N).

list_update_2d(Nrow,Ncol,Row,Col,D,G,V,D) :-
	list_ref_2d(Row,Col,G,V),
	dif(V,0).

%---------------------------------------------SECTION C: INITIALIZATION---------------------------------

%generate_game_board Nrow,Ncol,Nmines,Gameboard is true when Gameboard is a 2D list containing mines and adjacency numbers.
%This list contains Nrow elements, each element is a list of Ncol. 
%There will be no duplicates.
generate_game_board(Nrow,Ncol,Nmines,Gameboard) :-
	Ncells is Nrow*Ncol, build_list(Ncells,CellList),
	randselect(Nmines,CellList,MineCells),
	empty_game_board(Nrow,Ncol,EGB),
	slot_mines(EGB,MineCells,MinesGameboard),
	count_adjacent(Ncells,Nrow,Ncol,MinesGameboard,Gameboard).
	
%generate_matrix is true if M is a matrix of Nrow x Ncol filled with Filler.
generate_matrix(Nrow,Ncol,Filler,M) :-
	repeat_list(Filler,Ncol,Res),
	repeat_list(Res,Nrow,M).

%empty_game_bard is true when EGB is an empty 2D list of dimensions Nrow x Ncol (placeholder is symbol z).
empty_game_board(Nrow,Ncol,EGB) :- 
	generate_matrix(Nrow,Ncol,z,EGB).

%slot_mines(Board,MineCells,NextBoard) is true when MinesGameboard is Board with each postition given by MineCells containing a mine - represented by x.
slot_mines(Board,[],Board).
slot_mines(Board,[Position|R],MinesGameboard) :-
	list_ref(1,Board,SampleList), length(SampleList,Ncol),
	is(Row,ceil(Position/Ncol)),
	is(Col,mod(Position-1,Ncol)+1),
	list_set_2d(Row,Col,x,Board,NextBoard),
	slot_mines(NextBoard,R,MinesGameboard).

%-count_adjacent(Ncells,MinesGameboard,Gameboard) is true when Gameboard is MinesGameboard(which has Ncells cells) with all 'z' symbols updated
% to count the number of 'x' in adjacent squares.
count_adjacent(Ncells,Nrow,Ncol,MinesGameboard,Gameboard) :- count_adjacent(Ncells,Nrow,Ncol,1,MinesGameboard,Gameboard).
count_adjacent(Ncells,_,_,N,Gameboard,Gameboard) :- N > Ncells.
count_adjacent(Ncells,Nrow,Ncol,Current,Gameboard,FinalGameboard) :-
	Current<Ncells+1,
	is(Row,ceil(Current/Ncol)),
	is(Col,mod(Current-1,Ncol)+1),
	update_cell_adjacency(Nrow,Ncol,Row,Col,Gameboard,NextGameboard),
	Next is Current+1,
	count_adjacent(Ncells,Nrow,Ncol,Next,NextGameboard,FinalGameboard).

%update_cell_adjacency(Nrow,Ncol,Row,Col,Gameboard,NextGameboard) is true if NextGameboard is Gameboard but the cell at (Row,Col) is udpated to count surrounding mines,
%or is left untouched if it is a mine.
update_cell_adjacency(_,_,Row,Col,Gameboard,Gameboard) :- list_ref_2d(Row,Col,Gameboard,x).
update_cell_adjacency(Nrow,Ncol,Row,Col,Gameboard,NextGameboard) :- list_ref_2d(Row,Col,Gameboard,Cell), dif(x,Cell),
	count_mines(Nrow,Ncol,Row,Col,Gameboard,Nmines),list_set_2d(Row,Col,Nmines,Gameboard,NextGameboard).

%count_mines is true if Nmines is the number of mines adjacent to (Row,Col) on Gameboard.
count_mines(Nrow,Ncol,Row,Col,Gameboard,Nmines) :-
	URow is Row-1,DRow is Row+1,LCol is Col-1,RCol is Col+1,
	mine_at_cell(Nrow,Ncol,URow,LCol,Gameboard,MineUL),
	mine_at_cell(Nrow,Ncol,URow,Col,Gameboard,MineUC),
	mine_at_cell(Nrow,Ncol,URow,RCol,Gameboard,MineUR),
	mine_at_cell(Nrow,Ncol,Row,LCol,Gameboard,MineCL),
	mine_at_cell(Nrow,Ncol,Row,RCol,Gameboard,MineCR),
	mine_at_cell(Nrow,Ncol,DRow,LCol,Gameboard,MineLL),
	mine_at_cell(Nrow,Ncol,DRow,Col,Gameboard,MineLC),
	mine_at_cell(Nrow,Ncol,DRow,RCol,Gameboard,MineLR),
	Nmines is MineUL + MineUC + MineUR + MineCL + MineCR + MineLL + MineLC + MineLR.

%mine_at_cell(Nrow,Ncol,Row,Col,Gameboard,Val) is true if Gameboard[Row,Col] is a mine and Val is 1, or
%Gameboard[Row,Col] is out of bounds and Val is 0, or Gameboard{Row,Col} is not a mine and Val is 0.
% some cases may seem redundant, but this is to eliminate duplicate answers (at corners esp.)
mine_at_cell(Nrow,Ncol,Row,Col,_,0) :- \+ in_bounds(Nrow,Ncol,Row,Col).
mine_at_cell(Nrow,Ncol,Row,Col,Gameboard,1) :- in_bounds(Nrow,Ncol,Row,Col), list_ref_2d(Row,Col,Gameboard,x).
mine_at_cell(Nrow,Ncol,Row,Col,Gameboard,0) :- in_bounds(Nrow,Ncol,Row,Col), list_ref_2d(Row,Col,Gameboard,Cell), dif(x,Cell).

%in_bounds(Nrow,Ncol,Row,Col) determines if (Row,Col) are in a matrix with Nrow rows and Ncol cols.
in_bounds(Nrow,Ncol,Row,Col) :- number(Row), number(Col),Row>0,Row<Nrow+1,Col>0,Col<Ncol+1.

%num_to_row_col(N,Nrow,Ncol,Row,Col) is true if Row,Col correspond to the Nth cell on the board
%i.e. on a 3x3 board, N=1 corresponds to Row=1, Col=1, and
%N=4 corresponds to Row=2,Col=1.
num_to_row_col(N,_,Ncol,Row,Col) :- is(Row,ceil(N/Ncol)), is(Col,mod(N-1,Ncol)+1).

%-------------------------------------------SECTION D: USER INPUT AND GAME STATE UPDATES-------------------------------
% start_game(Nrow,Ncol,Nlives,Nmines,Gameboard,Revealed) is true if a Row and Column to reveal is succesfully requested from the user,
% and the next steps are taken.
start_game(Nrow,Ncol,Nlives,Nmines,Gameboard,Revealed) :-
	write("-------------------------------------------"), nl,
	write("Lives remaining: *"), write(Nlives), write("*"), nl,
	write("Make your next move!"), nl,
	
	%nl, write("This is the backend gameboard, for testing/debugging purposes"), nl,
	%write(Gameboard), nl, nl,
	
	request_row_col(Nrow,Ncol,Row,Col),
	list_set_2d(Row,Col,1,Revealed,UpdatedRevealed),	
	list_ref_2d(Row,Col,Gameboard,LastRevealedElement),
	list_update_2d(Nrow,Ncol,Row,Col,UpdatedRevealed,Gameboard,Element,UpdatedRevealedNew),
	print_game_board(Nrow,Ncol,Gameboard,UpdatedRevealedNew),
	next_steps(Nrow,Ncol,Nlives,Nmines,Gameboard,Revealed,UpdatedRevealedNew,LastRevealedElement).

request_row_col(Nrow,Ncol,Row,Col) :-
	write("Row    of cell to reveal:  "), read(ReadR),
	write("Column of cell to reveal:  "), read(ReadC),
	check_row_col(Nrow,Ncol,ReadR,ReadC,Row,Col).

%check_row_col is true if ReadR, ReadC, are user-specified inputs, and Row, Col, are valid inbound inputs based on Nrow, Ncol, ReadR, ReadC.
%if ReadR and ReadC are not valid inputs, then Row, Col, are requested again.
check_row_col(Nrow,Ncol,Row,Col,Row,Col) :- in_bounds(Nrow,Ncol,Row,Col).
check_row_col(Nrow,Ncol,ReadR,ReadC,Row,Col) :-
	\+ in_bounds(Nrow,Ncol,ReadR,ReadC),
	write("Bad input. Please enter again."), nl,
	request_row_col(Nrow,Ncol,Row,Col).

%next_steps(Nrow,Ncol,Nlives,Gameboard,Revealed,UpdatedRevealed,LastRevealedElement)
%is true if the game is updated properly based on the current state of gameboard, revealed, and
%what the last revealed element was.
next_steps(_,_,1,_,_,_,_,x) :- 
	%Revealed a mine, and lives is 1: Game Over.
	write("You have revealed a mine! Lost a life."), nl,
	write("Game over! You have run out of lives.").
	
next_steps(Nrow,Ncol,Nlives,Nmines,_,Revealed,_,x) :-
	%Revealed a mine, and more than one life left: shuffle all remaining unrevealed tiles and 
	%update already revealed tiles.
	Nlives > 1, 
	all_unrevealed(Nrow,Ncol,Revealed,Unrevealed),
	randselect(Nmines,Unrevealed,MineCells),
	empty_game_board(Nrow,Ncol,EGB),
	slot_mines(EGB,MineCells,MinesGameboard),
	Ncells is Nrow*Ncol,
	count_adjacent(Ncells,Nrow,Ncol,MinesGameboard,NewGameboard),
	
	write("You have revealed a mine! Lost a life!"), nl,
	write("All mines shuffled and tiles updated"), nl,
	print_game_board(Nrow,Ncol,NewGameboard,Revealed),
	
	NLifeLost is Nlives - 1,
	start_game(Nrow,Ncol,NLifeLost,Nmines,NewGameboard,Revealed).
	
next_steps(Nrow,Ncol,Nlives,Nmines,Gameboard,_,UpdatedRevealed,E) :- 
	%Revealed a non-mine
	\+ all_found(Nrow,Ncol,Gameboard,UpdatedRevealed),
	dif(E,x),
	nl,
	start_game(Nrow,Ncol,Nlives,Nmines,Gameboard,UpdatedRevealed).
next_steps(Nrow,Ncol,_,_,Gameboard,_,UpdatedRevealed,_) :-
	%winning case
	all_found(Nrow,Ncol,Gameboard,UpdatedRevealed),
	nl,
	write("###########################################"), nl,
	generate_matrix(Nrow,Ncol,1,AllRevealed),
	print_game_board(Nrow,Ncol,Gameboard,AllRevealed),
	write("You have found all mines!"), nl,
	write("You win!!!").
	
%all_unrevealed is true if Unrevealed is list of positions of all unrevealed items
all_unrevealed(Nrow,Ncol,Revealed,Unrevealed) :-
	Max is Nrow*Ncol,
	all_unrevealed(Max,1,Nrow,Ncol,Revealed,Unrevealed).
all_unrevealed(Max,Current,_,_,_,[]) :- 
	Current > Max.
all_unrevealed(Max,Current,Nrow,Ncol,Revealed,[Current|Unrevealed]) :-
	Current < Max + 1,
	num_to_row_col(Current,Nrow,Ncol,Row,Col),
	list_ref_2d(Row,Col,Revealed,z),
	Next is Current+1,
	all_unrevealed(Max,Next,Nrow,Ncol,Revealed,Unrevealed).
all_unrevealed(Max,Current,Nrow,Ncol,Revealed,Unrevealed) :-
	Current < Max + 1,
	num_to_row_col(Current,Nrow,Ncol,Row,Col),
	list_ref_2d(Row,Col,Revealed,1),
	Next is Current+1,
	all_unrevealed(Max,Next,Nrow,Ncol,Revealed,Unrevealed).	
	
%all_found(Gameboard,Revealed) is true if all non-mine squares in revealed have been revealed,
%based on comparison between Gameboard and Revealed, which are each Ncol * Nrow matrices.
all_found(Nrow,Ncol,Gameboard,Revealed) :-
	Max is Nrow*Ncol,
	all_found(Max,1,Nrow,Ncol,Gameboard,Revealed).
all_found(Max,Current,_,_,_,_) :- Current > Max.
all_found(Max,Current,Nrow,Ncol,Gameboard,Revealed) :- 
	Current < Max + 1,
	num_to_row_col(Current,Nrow,Ncol,Row,Col),
	list_ref_2d(Row,Col,Gameboard,x),
	Next is Current+1,
	all_found(Max,Next,Nrow,Ncol,Gameboard,Revealed).
all_found(Max,Current,Nrow,Ncol,Gameboard,Revealed) :- 
	Current < Max + 1,
	num_to_row_col(Current,Nrow,Ncol,Row,Col),
	list_ref_2d(Row,Col,Gameboard,E),
	dif(E,x),
	list_ref_2d(Row,Col,Revealed,1),
	Next is Current+1,
	all_found(Max,Next,Nrow,Ncol,Gameboard,Revealed).
	

	

