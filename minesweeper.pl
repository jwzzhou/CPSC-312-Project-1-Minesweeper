% MINESWEEPER

%this is the main function. Run it to start the game.
main :- 
	write("Welcome to minesweeper!"), nl,
	get_info(Nrow,Ncol,Nmines,Nlives),		
	validate_inputs(Nrow,Ncol,Nmines,Nlives).
	

%get_info(Nrow,Ncol,Nmines,Nlives) reads user input and is true if each of the above are valid inputs.
get_info(Nrow,Ncol,Nmines,Nlives) :-
	write("Number of rows:    (max 100) "), read(Nrow), 
	write("Number of columns: (max 30)  "), read(Ncol), 
	write("Number of mines:             "), read(Nmines),
	write("Number of lives:             "), read(Nlives),nl.

%validate_inputs is true if Nrow,Ncol,Nmines, and Nlives, are valid. If they are the game process is continued. If not, the game process is terminated.
validate_inputs(Nrow,Ncol,Nmines,Nlives) :- 
	check_inputs(Nrow,Ncol,Nmines,Nlives),
	print_info(Nrow,Ncol,Nmines), nl,
	generate_game_board(Nrow,Ncol,Nmines,GameBoard),
	print_game_board(Nrow,Ncol,GameBoard).	
validate_inputs(Nrow,Ncol,Nmines,Nlives) :-
	\+ check_inputs(Nrow,Ncol,Nmines,Nlives),
	write("Bad inputs! Terminating game"), nl.

%check_inputs(Nrow,Ncol,Nmines,Nlives) is true if each of the above parameters are okay for game creation.
check_inputs(Nrow,Ncol,Nmines,Nlives) :-
	number(Nrow),number(Ncol),number(Nmines),number(Nlives),
	Nrow > 0, Nrow < 101, Ncol > 0, Ncol < 31, Nmines > 0, Nmines < Nrow*Ncol, Nlives > 0.

	
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

%printGameBoard is called after initialization and each player move. It prints out row and column numbers, along with the 
%current state of the board.
print_game_board(Nrow,Ncol,GameBoard):-
	print_header(Ncol),
	print_separator(Ncol),
	print_field(Nrow,Ncol,GameBoard),
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

%print_field(Nrow,Ncol,mines,revealed) prints out the game board, with row numbers labelled on the side.
print_field(Nrow,Ncol,GameBoard) :- 
	print_field_helper(Nrow,Ncol,GameBoard,1).
print_field_helper(Nrow,_,_,CurRow) :- CurRow > Nrow.
print_field_helper(Nrow,Ncol,GameBoard,CurRow) :- 
	print_number(CurRow), write("|"), 
	list_ref(CurRow,GameBoard,GameBoardRow),
	print_game_board_row(GameBoardRow), 
	write("|"), write("  "), write(CurRow),nl,
	NextRow is CurRow + 1, print_field_helper(Nrow,Ncol,GameBoard,NextRow).

%print_game_board_row(GameBoardRow) print the row of the gameboard.
print_game_board_row([]).
print_game_board_row([H|T]) :-
	write(" "), write(H), write(" "),
	print_game_board_row(T).
	
%---------------------------------------------SECTION B: HELPFUL LIST OPERATIONS-------------------------
	
%build-list(N,R) is true when R is a list of numbers 1 to N, inclusive.
build_list(N,R) :- build_list(N,1,R).
build_list(N,Cur,[Cur]) :- Cur is N.
build_list(N,Cur,[Cur|R]) :- Cur < N, NextNo is Cur+1, build_list(N,NextNo,R).

% repeat_list(E,N,R) is true when R is a list of length N with Sym repeated N times.
repeat_list(E,0,[]).
repeat_list(E,N,[E|R]) :- N>0, Next is N-1, repeat_list(E,Next,R).
	
%randselect(N,L,R) is true when list R consists of N elements removed from list L randomly.
randselect(N,L,R) :- randselect(N,0,L,R).
randselect(N,N,L,[]).
randselect(N,Cur,L,[RandEl|R]) :- 
	Cur < N, length(L,Length), Upbound is Length+1, random(1,Upbound,RandInd),
	list_ref(RandInd,L,RandEl),
	select(RandEl,L,Sublist),NextNo is Cur+1,
	randselect(N,NextNo,Sublist,R).

%list_ref_2d(Row,Col,L,R) is true when R corresponds to the element (Row,Col) in the 2d list L.
list_ref_2d(Row,Col,L,R) :-
	list_ref(Row,L,RowList), list_ref(Col,RowList,R).
	
%list_ref(N,L,R) is true when R is the Nth element of L. 1-based indexing.
%why the hell did I use an accumulator
list_ref(N,L,R) :- length(L,Length), Length+1 > N, list_ref(N,1,L,R).
list_ref(N,N,[R|T],R).
list_ref(N,Cur,[_|T],R) :- Cur < N, Next is Cur+1, list_ref(N,Next,T,R).

%list_set(N,E,L,R) is true when R is L with the Nth element changed to E.
list_set(N,E,L,L) :- N < 1.
list_set(N,E,L,R) :- list_set(N,1,E,L,R).
list_set(N,N,E,[_|T],[E|T]).
list_set(N,Cur,E,[H|T],[H|R]) :- Cur < N, Next is Cur + 1, list_set(N,Next,E,T,R).

%list_set_2d(Row,Col,E,L,R) is true when R corresponds to the 2d list L with (Row,Col) changed to E.
list_set_2d(Row,Col,E,L,L) :- Row < 1.
list_set_2d(Row,Col,E,L,R) :-
	list_ref(Row,L,RowList), list_set(Col,E,RowList,NewRowList),
	list_set(Row,NewRowList,L,R).	
	
%---------------------------------------------SECTION C: INITIALIZATION---------------------------------

%generateMines Nrow,Ncol,Nmines,GameBoard is true when GameBoard is a 2D list containing mines and adjacency numbers.
%This list contains Nrow elements, each element is a list of Ncol. 
%There will be no duplicates.
generate_game_board(Nrow,Ncol,Nmines,GameBoard) :-
	Ncells is Nrow*Ncol, build_list(Ncells,CellList),
	randselect(Nmines,CellList,MineCells),
	empty_game_board(Nrow,Ncol,EGB),
	slot_mines(EGB,MineCells,MinesGameBoard),
	count_adjacent(Ncells,Nrow,Ncol,MinesGameBoard,GameBoard).

%empty_game_bard is true when EGB is an empty 2D list of dimensions Nrow x Ncol (placeholder is symbol z).
empty_game_board(Nrow,Ncol,EGB) :- 
	repeat_list(z,Ncol,Res),
	repeat_list(Res,Nrow,EGB).

%slot_mines(Board,MineCells,NextBoard) is true when MinesGameBoard is Board with each postition given by MineCells containing a mine - represented by x.
slot_mines(Board,[],Board).
slot_mines(Board,[Position|R],MinesGameBoard) :-
	list_ref(1,Board,SampleList), length(SampleList,Ncol),
	is(Row,ceil(Position/Ncol)),
	is(Col,mod(Position-1,Ncol)+1),
	list_set_2d(Row,Col,x,Board,NextBoard),
	slot_mines(NextBoard,R,MinesGameBoard).

%-count_adjacent(Ncells,MinesGameBoard,GameBoard) is true when GameBoard is MinesGameBoard(which has Ncells cells) with all 'z' symbols updated
% to count the number of 'x' in adjacent squares.
count_adjacent(Ncells,Nrow,Ncol,MinesGameBoard,GameBoard) :- count_adjacent(Ncells,Nrow,Ncol,1,MinesGameBoard,GameBoard).
count_adjacent(Ncells,Nrow,Ncol,Ncells,GameBoard,GameBoard).
count_adjacent(Ncells,Nrow,Ncol,Current,GameBoard,FinalGameBoard) :-
	Current<Ncells+1,
	is(Row,ceil(Current/Ncol)),
	is(Col,mod(Current-1,Ncol)+1),
	update_cell_adjacency(Nrow,Ncol,Row,Col,GameBoard,NextGameBoard),
	Next is Current+1,
	count_adjacent(Ncells,Nrow,Ncol,Next,NextGameBoard,FinalGameBoard).

%update_cell_adjacency(Nrow,Ncol,Row,Col,GameBoard,NextGameBoard) is true if NextGameBoard is GameBoard but the cell at (Row,Col) is udpated to count surrounding mines,
%or is left untouched if it is a mine.
update_cell_adjacency(_,_,Row,Col,GameBoard,GameBoard) :- list_ref_2d(Row,Col,GameBoard,x).
update_cell_adjacency(Nrow,Ncol,Row,Col,GameBoard,NextGameBoard) :- list_ref_2d(Row,Col,GameBoard,Cell), dif(x,Cell),
	count_mines(Nrow,Ncol,Row,Col,GameBoard,Nmines),list_set_2d(Row,Col,Nmines,GameBoard,NextGameBoard).

%count_mines is true if Nmines is the number of mines adjacent to (Row,Col) on GameBoard.
count_mines(Nrow,Ncol,Row,Col,GameBoard,Nmines) :-
	URow is Row-1,DRow is Row+1,LCol is Col-1,RCol is Col+1,
	mine_at_cell(Nrow,Ncol,URow,LCol,GameBoard,MineUL),
	mine_at_cell(Nrow,Ncol,URow,Col,GameBoard,MineUC),
	mine_at_cell(Nrow,Ncol,URow,RCol,GameBoard,MineUR),
	mine_at_cell(Nrow,Ncol,Row,LCol,GameBoard,MineCL),
	mine_at_cell(Nrow,Ncol,Row,RCol,GameBoard,MineCR),
	mine_at_cell(Nrow,Ncol,DRow,LCol,GameBoard,MineLL),
	mine_at_cell(Nrow,Ncol,DRow,Col,GameBoard,MineLC),
	mine_at_cell(Nrow,Ncol,DRow,RCol,GameBoard,MineLR),
	Nmines is MineUL + MineUC + MineUR + MineCL + MineCR + MineLL + MineLC + MineLR.

%mine_at_cell(Nrow,Ncol,Row,Col,Gameboard,Val) is true if Gameboard[Row,Col] is a mine and Val is 1, or
%Gameboard[Row,Col] is out of bounds and Val is 0, or Gameboard{Row,Col} is not a mine and Val is 0.
% some cases may seem redundant, but this is to eliminate duplicate answers (at corners esp.)
mine_at_cell(Nrow,Ncol,Row,Col,_,0) :- \+ in_bounds(Nrow,Ncol,Row,Col).
mine_at_cell(Nrow,Ncol,Row,Col,GameBoard,1) :- in_bounds(Nrow,Ncol,Row,Col), list_ref_2d(Row,Col,GameBoard,x).
mine_at_cell(Nrow,Ncol,Row,Col,GameBoard,0) :- in_bounds(Nrow,Ncol,Row,Col), list_ref_2d(Row,Col,GameBoard,Cell), dif(x,Cell).

%in_bounds(Nrow,Ncol,Row,Col) determines if (Row,Col) are in a matrix with Nrow rows and Ncol cols.
in_bounds(Nrow,Ncol,Row,Col) :- Row>0,Row<Nrow+1,Col>0,Col<Ncol+1.
