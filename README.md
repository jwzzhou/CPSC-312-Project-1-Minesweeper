# CPSC-312-Project-1-Minesweeper

## MINESWEEPER

By: Imelda Suen, Rachel Wong, and Joshua Zhou

CPSC312 2017W1 Project 1.

This is an implementation of minesweeper in prolog.

# Instructions:

All code is in the minesweeper.pl file. Put it in the directory of your choice, then either:
1: In command line, type ./swipl mineweeper.pl
2: Open the file with SWI-PL, then type ```main.```

The game will then prompt you to input game parameters.

```
Welcome to minesweeper!
Number of rows:    (max 99) 10.
Number of columns: (max 50)  |: 10.
Number of mines:             |: 10.
Number of lives:             |: 
```

Afterwards, the game state and the board will be printed, and you will be asked to make a move, by inputting the row and column of the cell you want to reveal.

```
   | 1  2  3  4  5  6  7  8  9 10 |   
---+------------------------------+---
 1 | .  .  .  .  .  .  .  .  .  . |  1
 2 | .  .  .  .  .  .  .  .  .  . |  2
 3 | .  .  .  .  .  .  .  .  .  . |  3
 4 | .  .  .  .  .  .  .  .  .  . |  4
 5 | .  .  .  .  .  .  .  .  .  . |  5
 6 | .  .  .  .  .  .  .  .  .  . |  6
 7 | .  .  .  .  .  .  .  .  .  . |  7
 8 | .  .  .  .  .  .  .  .  .  . |  8
 9 | .  .  .  .  .  .  .  .  .  . |  9
10 | .  .  .  .  .  .  .  .  .  . |  10
---+------------------------------+---
   | 1  2  3  4  5  6  7  8  9 10 |   
-------------------------------------------
Make your next move!
Row    of cell to reveal:  |: 1.
Column of cell to reveal:  |: 
```

The game continues until either all non-mine squares have been revealed, or you have revealed a mine and are out of lives. At that point the game will terminate.
To play again, you must start over from the beginning of the instructions.

# Implementation Details:

Selecting cells to put mines in is done randomly using the ```randselect/3``` command - which randomly takes N elements from a list, removes them, and returns the removed elements. 
This is done so we ensure all mines are unique.

The gameboard and the revealed cells are each represented by a 2D matrix.
```list_set_2d/5``` and ```list_ref_2d/4``` are the accessors and mutators for these boards.
One can 'reveal' a cell by setting the 'revealed' board at (row,col) to be 1. 
When printing the board, the cell at (row,col) on the game board and the revealed board are both checked.
If the revealed board is 1, then the symbol on the game board is printed. If revealed is not 1, then a "." is printed.

Life system: When revealing a mine and a player has >1 life, all unrevealed squares are shuffled, and a life is lost
This is handled by the ```next_steps/7``` predicate.
The general algorithm is:
1. Revert the last move (by using the ```RevealedGameBoard``` parameter and not then ```UpdatedRevealedGameBoard``` parameter)
2. Enumerate all unrevealed cells. (I.e. give each cell a corresponding integer, i.e. a cell at position (Row,Col) on a NrowxNcol board will be represeted by the integer (Row*Ncol) + Col.
This can be done using the ```num_to_row_col/5``` predicate.
3. Randomly select ```Nmines``` cells from the above enumerated list.
4. Use ```empty_game_board/3```, ```slot_mines/4```, and ```count_adjacent/5``` to create the new gameboard with the new mine locations
5. Call ```start_game/7``` again, with lives-1.