# Fixing confusing lookups and table
looking at [[utf8.png]] we see that it can be trivial to implement a system,
which understands æøå using the fact that æøa uses 2 code points :)
That way each character is two bytes and every word in the dictionary is a
string of 2 code points. Might be some wasted space, but easy lookup and
probably decently fast :).

[ ] - make a parser of the file based on code points in WordList, using a
Character class
[ ] - make LinguaFight use Character class exclusively

The design will be

To leave the dansk.txt asis
To create a big array of arrays of Characters
so when looking up a word in the game, I can just use the row or column directly
instead of converting anything

Alternatively, 
go full data-oriented design, a letter is just a number, use numbers everywhere
except when displaying 🤔🤔🤔🤔
