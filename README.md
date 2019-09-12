# CS223 Digital Design Course Term Project
# Puyo Pop Game

Puyo Pop is a single player game, which resembles to well-known game Tetris though it has some slight differences. Player has a 8x8 matrix/board. As usual there are shapes coming randomly from the top-middle of the matrix, however in this game these shapes are fixed two unit balls. Although they have fixed size, they might differ in colors or they may have same color as well. The aim of this game is to vanish the incoming balls and prevent them to accumulate at the bottom of the matrix. In order to reach this goal, the user should orient the incoming shape in a way that same colors should neighbour each other at the bottom of the matrix. The user will use arrows for the orientation or the movement of the balls (to the left or to the right) and he/she can orient the shape such that it can be horizontally or vertically oriented, until it touches the bottom of the matrix or the balls which has already been located. If four or more balls with the same color are placed together, they pop, disappear from the led matrix. Furthermore, if the balls disappear, the balls above them slide down and fill in the space. Most importantly, if user tries to locate a ball outside of the matrix, or if there is no space for the incoming ball, the game will end and buzzer is enabled. User gains points from the amount of balls which are popped, and it is displayed on the seven segment display on Basys3. This game is implemented by using System Verilog. 

Equipment that is used:
- Basys3 
- Beti experiment board 
- 8x8 RGB Led Display Module (on the betiboard)
- Push buttons	
- Seven Segment Led Display 
- Buzzer

Final report of the project : [Puyo Pop Final Report](IremUral-EmreDikinelli_PuyoPop.docx)
