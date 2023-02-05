# Powerful wordfeud engine 

## Tasks 
- [ ] make backend
 - [ ] make alphabet part of the dictionary
  - [ ] Læs build system: https://zig.news/xq/zig-build-explained-part-1-59lf
  - [ ] Lav test build der tester alle filer, undgå at køre testene på samme
    måde med zig test, men rettere zig build test
  - [ ] Lav libglyph en del af buildet
  - [ ] Make a danish [dictionary class](dictionary_class.md) with alphabet
  - [ ] make an array alphabet as a grapheme cluster
  - [ ] make every word be loaded into dictionary as a grapheme cluster
 - [ ] make something that can take a board in as a file and print it
 	- [X] split the string and make it into board
 	- [X] Take a board and turn it into a string (easier for testing)
 	- [ ] how to open and read a file in zig?
 	- [ ] Take the file in as a string
 - [ ] write tests for the different methods
 - [ ] combine the methods into a solver, so that it can solve 1 step (insert
   best word)
- [ ] Make TUI
	- [ ] Lav et design dokument
	- [ ] Lav en tile der kan tage imod en glyph
	- [ ] Lav det om til et board
	- [ ] Lav drag and drop af bogstaver der opdatere boardet
	- [ ] Lav



## TUI ideas 
So here we say that a simple tui loads and writes to a file, when the
opponent plays something we can simlpy edit the file manually

