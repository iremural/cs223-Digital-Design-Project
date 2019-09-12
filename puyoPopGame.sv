`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//@author irem ural 
// id 21502278
//@author emre dikenelli
//id 21501975 
// Create Date: 12/24/2016 01:36:02 PM
// Module Name: puyoPopGame
// Project Name: Puyo Pop
// Target Devices: Bays3 
// 
//////////////////////////////////////////////////////////////////////////////////


module puyoPopGame(
input logic clk,reset,start,leftButton,rightButton,downButton,rotateButton,stop,
output logic MR, OE, shiftclk, storeclk, DS, [7:0]rowselect, 
output m, n, o, p, r, s, t, dp, [3:0] an,
output buzz   
 );


logic [23:0] serialdata = {24{1'b0}};
logic [7:0] counter = {8{1'b0}};
reg [1:0] matrix [0:7][0:7];
typedef enum logic [2:0] {INITIALIZE,GENERATE_PAIR,MOVEMENT,CLEAR,REARRANGE,GAME_OVER} statetype;
statetype state;
integer loc1i = 0;
integer loc1j = 0;
integer loc2i = 0;
integer loc2j = 0;
logic orientation;
logic found_vertical;
logic found_horizontal;
logic found_square;

integer k;
integer l;

integer i = 0;
integer a = 0;
logic e_clk = 0;
logic f_clk = 0;
integer ii, jj, j;
 
 integer col;
 integer row;
 integer kk;
 
 //sycnhronize buttons
 logic left,right,down,rotate;
 buttonSynchronizer b0(f_clk,leftButton,left);
 buttonSynchronizer b1(f_clk,rightButton,right);
 buttonSynchronizer b2(f_clk,downButton,down);
 buttonSynchronizer b3(f_clk,rotateButton,rotate);

//display the score in seven segment display
integer score = 0;
logic[3:0] in0,in1,in2,in3;
SevSeg_4digit sevSeg(clk, in0, in1, in2, in3, m, n, o, p, r, s, t, dp, an);

//instantiate buzzer module to generate a low or high signal according to gameOver signal
logic gameOver = 0;
buzzer b(clk,gameOver,stop,buzz);

logic [3:0] colorCounter = 4'b0000;

// generate a serialdata for each row of the 8x8 led matrix 
//according to the color of the matrix in the program which is stored as 2 bit values
//00 shows that the led is empty 
//01 shows that blue color will be generated to display
//10 shows that pink color will be generated to display
//11 shows that red color will be generated to display 
 always_comb //(posedge clk)
    begin // a'th row serial data
          for (j = 0; j < 8; j = j + 1)
             begin
 
             case ( matrix [j][a] )    
             
             2'b00: begin //Empty  
                      serialdata[j] <= 1'b0;
                      serialdata[j+8] <= 1'b0;
                      serialdata[j+16] <= 1'b0;                
                    end
                    
             2'b01: begin  // Blue color
                      serialdata[j] <= 1'b1;
                      serialdata[j+8] <= 1'b0;
                      serialdata[j+16] <= 1'b0;
                    end                 
                      
              2'b10: begin  // Pink color
                       serialdata[j] <= 1'b1;
                       serialdata[j+8] <= 1'b0;
                       serialdata[j+16] <= 1'b1;                 
                      end                 
        
               2'b11: begin  // Red Color
                        serialdata[j] <= 1'b0;
                        serialdata[j+8] <= 1'b0;
                        serialdata[j+16] <= 1'b1;                 
                      end                 
                        
             endcase
             end 
     end
 //*********************************************************
 //DISPLAY
 // selection of row , row on the 8x8 led is denoted by a in this case  
 always@(posedge clk)
 begin 
   if(a == 0)
    rowselect <= 8'b00000001;
   else if(a == 1)
      rowselect <= 8'b00000010;
   else if(a == 2)
      rowselect <= 8'b00000100;
   else if(a == 3)
      rowselect <= 8'b00001000;
   else if(a == 4)
      rowselect <= 8'b00010000;
   else if(a == 5)
      rowselect <= 8'b00100000;
   else if(a == 6)  
      rowselect <= 8'b01000000;
   else if(a == 7)  
      rowselect <= 8'b10000000;     
 end  
   
   
 
 always@ (posedge clk)  
  begin 
    counter = counter+1;  
  end  

always @(posedge clk)
  begin   
    f_clk <= counter[7]; // f_clk is used for shifter clock
    e_clk <= ~f_clk;  // e_clk is used for store clock
  end
  
always@(posedge clk)
    begin       
    if (i < 3) // until 3 system is resetted
       MR <= 1'b0;
    else
       MR <= 1'b1;
          
    if ( ( i > 2) && (i < 27))  // data is sent
      DS <= serialdata[i-3];
    else 
       DS <= 1'b0;    
    
    if (i < 27) // 24 data is ready to use, clock is stopped until the new data is sent
       begin
         shiftclk <= f_clk;
         storeclk  <= e_clk;
       end
    else
       begin
         shiftclk <= 1'b0;
         storeclk <= 1'b1;
       end
 
  end  
 
   always@ (posedge e_clk)  
    begin     
       i <= i + 1; // after each clock pulse i is increased to get the serialdata
       if ( i >= 409)
          i <= 0;
    end                   

 always@ (posedge f_clk)  // OE is the output enable signal, when clock stops it is set to 0  
  begin     
    if ((i > 27) && (i < 408 ))
       OE <= 1'b0;
    else
       OE <= 1'b1;   
  end 
   
always@ (posedge f_clk)  // a is increased to select the latter row until 8th row
    begin     
      if ( i == 409)
         begin
           a = a +1;  
           if (a == 8)
               a <= 0;
         end      
    end                      
 //*********************************************************
 
 // generate signals for sev_seg4digit module each in0,in1... has 4 digit values 
 //which is calculated according the score of the player
 always @ (score)
 begin
 in0 <= score % 10;
 in1 <= (score/10) % 10;
 in2 <= (score /100) % 10;
 in3 <= (score/1000);
 end
 
 // f_clk is the clock signal which slowed down to display, and an ascynchronuos reset signal is used 
 always @ (posedge f_clk, posedge reset)
 begin
    //reset the matrix with reset signal, set score and gameover signal to zero
    if(reset)
    begin     
          
        if(score != 0)
        begin   
          score = 0;
        end
        if(gameOver != 0)
        begin
            gameOver = 0;
        end
         ii = 0;
         while (ii <= 7)
         begin
               jj = 0;
                  while(jj <=7)
                  begin
                    matrix[ii][jj] = 2'b00;
                    jj= jj + 1;
                   end
               ii = ii + 1;
          end
          state <= INITIALIZE;
     end  
     else
     begin   
        case(state)
        // initial state all matrix is empty, wait for start switch to go high in order to start the game
        //else wait in this state
        INITIALIZE:
                    begin

                    if(start)
                        state <= GENERATE_PAIR;
                    else 
                        state <= INITIALIZE;
                    
                    end
                    //generate a pair at the middle top of the 8x8 led
                    // the color of the pair is changed by using a counter 
          GENERATE_PAIR:
                        begin
                            if(matrix[7][3] != 2'b00 || matrix[7][4] != 2'b00)
                                state <= GAME_OVER;
                            else
                            begin
                                loc1i = 7;
                                loc1j = 3;
                                loc2i = 7;
                                loc2j = 4;
                               
                                case(colorCounter)
                                  4'b0000: begin
                                            matrix[loc1i][loc1j] = 2'b11;
                                            matrix[loc2i][loc2j] = 2'b01;  
                                            end
                                  4'b0001: begin
                                           matrix[loc1i][loc1j] = 2'b01;
                                           matrix[loc2i][loc2j] = 2'b10;  
                                           end
                                  4'b0010: begin
                                           matrix[loc1i][loc1j] = 2'b11;
                                           matrix[loc2i][loc2j] = 2'b10;  
                                           end
                                  4'b0011: begin
                                           matrix[loc1i][loc1j] = 2'b11;
                                           matrix[loc2i][loc2j] = 2'b11;  
                                           end
                                  4'b0100: begin
                                           matrix[loc1i][loc1j] = 2'b01;
                                           matrix[loc2i][loc2j] = 2'b11;  
                                           end
                                  4'b0101: begin
                                           matrix[loc1i][loc1j] = 2'b10;
                                           matrix[loc2i][loc2j] = 2'b10;  
                                          end
                                  4'b0110: begin
                                           matrix[loc1i][loc1j] = 2'b10;
                                           matrix[loc2i][loc2j] = 2'b11; 
                                           end
                                  4'b0111: begin
                                           matrix[loc1i][loc1j] = 2'b01;
                                           matrix[loc2i][loc2j] = 2'b01;
                                           end
                                  4'b1000: begin
                                           matrix[loc1i][loc1j] = 2'b10;
                                           matrix[loc2i][loc2j] = 2'b01;
                                           end
                               
                                endcase
                                colorCounter = colorCounter + 1;
                                if(colorCounter >= 4'b1001 )
                                begin
                                    colorCounter = 4'b0000;
                                end 
                                orientation = 1'b0;
                                state <= MOVEMENT;
                            end   
                                                               
                        end
            // according to button signals the upcoming ball moves right, left, or down
            // orientation 1'b0 the pair is oriented horizontally
            // orientation 1'b1 the pair is oriented vertically
            // left and right movement is allowed if it reaches to boundaries or there is no balls
            //down movement occur until there is a ball or it reaches to the bottom of the matrix            
            MOVEMENT:
                    begin
                    if(orientation == 1'b0)
                    begin
                        if(left)
                        begin
                            if(loc1j - 1 >= 0 )
                                if( matrix[loc1i][loc1j - 1] == 2'b00)
                                begin
                                    matrix[loc1i][loc1j - 1] = matrix[loc1i][loc1j];
                                    matrix[loc1i][loc1j] = matrix[loc2i][loc2j];
                                    matrix[loc2i][loc2j] = 2'b00;
                                    loc1i = loc1i;
                                    loc1j = loc1j -1;
                                    loc2i = loc2i;
                                    loc2j = loc2j -1;
                                end 
                               
                        end
                        else if(right)
                        begin 
                            if(loc2j + 1 <= 7 )
                                if(matrix[loc2i][loc2j + 1] == 2'b00)
                                begin
                                    matrix[loc2i][loc2j + 1] = matrix[loc2i][loc2j];
                                    matrix[loc2i][loc2j] = matrix[loc1i][loc1j];
                                    matrix[loc1i][loc1j] = 2'b00;
                                    loc1i = loc1i;
                                    loc1j = loc1j +1;
                                    loc2i = loc2i;
                                    loc2j = loc2j +1;
                                end   
                        end
                        else if(down)
                        begin 
                            if(loc2i - 1 >= 0 )
                                if(matrix[loc2i - 1][loc2j] == 2'b00 && matrix[loc1i - 1][loc1j] == 2'b00)
                                begin
                                    matrix[loc1i - 1][loc1j] = matrix[loc1i][loc1j];
                                    matrix[loc1i][loc1j] = 2'b00;
                                    matrix[loc2i - 1][loc2j] = matrix[loc2i][loc2j];
                                    matrix[loc2i][loc2j] = 2'b00;
                                    loc1i = loc1i - 1;
                                    loc1j = loc1j ;
                                    loc2i = loc2i - 1;
                                    loc2j = loc2j;
                                end   
                        end
                        else if(rotate)
                        begin
                            if(loc1i -1 >= 0)
                                if(matrix[loc1i -1][loc1j] == 2'b00 && matrix[loc2i -1][loc2j] == 2'b00 )
                                begin
                                    matrix[loc1i -1][loc1j] = matrix[loc2i][loc2j];
                                    matrix[loc2i][loc2j] = 2'b00;
                                    loc2i = loc1i-1;
                                    loc2j = loc1j;
                                    orientation = 1'b1;
                                end
                        end
                    end
                    else // orientation = 1'b1
                    begin
                        if(left)
                        begin
                            if(loc1j -1 >= 0 && loc2j -1 >= 0)
                                if(matrix[loc1i][loc1j-1] == 2'b00 && matrix[loc2i][loc2j-1] == 2'b00)
                                begin
                                    matrix[loc1i][loc1j-1] = matrix[loc1i][loc1j];
                                    matrix[loc2i][loc2j-1] = matrix[loc2i][loc2j];
                                    matrix[loc1i][loc1j] = 2'b00;
                                    matrix[loc2i][loc2j] = 2'b00;
                                    loc1j = loc1j -1;
                                    loc2j = loc2j -1;
                                end
                        end
                        else if(right)
                        begin
                             if(loc1j + 1 <= 7 && loc2j +1 <= 7)
                                if(matrix[loc1i][loc1j+1] == 2'b00 && matrix[loc2i][loc2j+1] == 2'b00)
                                begin
                                    matrix[loc1i][loc1j+1] = matrix[loc1i][loc1j];
                                    matrix[loc2i][loc2j+1] = matrix[loc2i][loc2j];
                                    matrix[loc1i][loc1j] = 2'b00;
                                    matrix[loc2i][loc2j] = 2'b00;
                                    loc1j = loc1j +1;
                                    loc2j = loc2j +1;
                                end
                        end
                        else if(down)
                        begin
                            if(loc2i -1 >= 0)
                                if(matrix[loc2i - 1][loc2j] == 2'b00)
                                begin
                                    matrix[loc2i - 1][loc2j]= matrix[loc2i][loc2j];
                                    matrix[loc2i][loc2j] = matrix[loc1i][loc1j];
                                    matrix[loc1i][loc1j] = 2'b00;
                                    loc1i = loc2i;
                                    loc2i = loc2i -1;
                                end
                        end
                        else if(rotate)
                        begin
                            if(loc1j - 1 >= 0)
                                if(matrix[loc1i][loc1j -1] == 2'b00 && matrix[loc2i][loc2j-1] == 2'b00)
                                begin
                                    matrix[loc1i][loc1j -1]= matrix[loc2i][loc2j];
                                    matrix[loc2i][loc2j] = 2'b00;
                                    loc1i = loc1i;
                                    loc2i = loc1i;
                                    loc2j = loc1j;
                                    loc1j = loc1j - 1;
                                    orientation = 1'b0;
                                end
                        end
                        
                    end
                    //when the pair is located check whether there is 4 adjacent colors to delete 
                    //else stay in the movement state
                    if(orientation == 1'b0)
                        if(loc2i == 0 || matrix[loc2i - 1][loc2j] != 2'b00 || matrix[loc1i - 1][loc1j] != 2'b00 )
                              state <= CLEAR;
                        else
                           state <= MOVEMENT;
                    else
                        if(loc2i == 0 || matrix[loc2i - 1][loc2j] != 2'b00 )
                             state <= CLEAR;
                        else
                            state <= MOVEMENT;
                    end
            //4 neighbor same colors on the matrix is deleted, 
            // they are deleted in 3 cases if they generate a square, 
            //4 balls with the same color are adjacent to each other horizontally or vertically 
            // each the score is incremented by 1.       
            CLEAR:   
                  begin
                    found_vertical = 1'b0;
                    found_horizontal = 1'b0;
                    found_square = 1'b0;
                    k = 0;
                    while( k < 8 && found_vertical == 1'b0 && found_horizontal == 1'b0 && found_square == 1'b0 )
                    begin
                        l = 0;
                        while(l < 8 && found_vertical == 1'b0 && found_horizontal == 1'b0 && found_square == 1'b0 )
                        begin
                                if(l <= 4)
                                begin
                                   if(matrix[k][l] != 2'b00 && matrix[k][l+1] == matrix[k][l] && matrix[k][l+2] == matrix[k][l] && matrix[k][l+3] == matrix[k][l])
                                   begin
                                      matrix[k][l] = 2'b00;
                                      matrix[k][l+1] = 2'b00;
                                      matrix[k][l+2] = 2'b00;
                                      matrix[k][l+3] = 2'b00;
                                      score = score + 1;
                                      found_horizontal = 1'b1;
                                   end
                                end
                                if(k <= 6 &&  l < 7)
                                begin 
                                    if(matrix[k][l] != 2'b00 && matrix[k+1][l] == matrix[k][l] && matrix[k][l+1] == matrix[k][l] && matrix[k+1][l+1] == matrix[k][l])
                                    begin
                                       matrix[k][l] = 2'b00;
                                       matrix[k][l+1] = 2'b00;
                                       matrix[k+1][l] = 2'b00;
                                       matrix[k+1][l+1] = 2'b00;
                                       score = score + 1;
                                       found_square = 1'b1;
                                    end
                                end
                                if( k <=4 )
                                begin
                                    if(matrix[k][l] != 2'b00 && matrix[k+1][l] == matrix[k][l] && matrix[k+2][l] == matrix[k][l] && matrix[k+3][l] == matrix[k][l])
                                    begin
                                         matrix[k][l] = 2'b00;
                                         matrix[k+1][l] = 2'b00;
                                         matrix[k+2][l] = 2'b00;
                                         matrix[k+3][l] = 2'b00;
                                         score = score + 1;
                                         found_vertical = 1'b1;
                                     end
                                end
                            l = l +1;
                        end
                        k = k + 1;
                    end
                    if(k > 7)
                         state <= GENERATE_PAIR;
                     else if (found_vertical == 1'b1 || found_horizontal == 1'b1 || found_square == 1'b1 ) 
                         state <= REARRANGE;
                     else
                          state <= GENERATE_PAIR;
                     
                 end
            // if the balls are deleted from the matrix it passes to rearrange state 
            // the balls on the top are moved down until there is a ball at the bottom or it reaches to boundary case(1st row on the 8x8 led matrix) 
            REARRANGE:
                    begin
                     for(col = 0; col < 8; col = col +1)
                     begin 
                     kk = -1;
                        for(row = 0; row < 8; row = row+1)
                        begin
                            if(matrix[row][col] == 2'b00 && kk == -1)
                            begin
                                kk = row;
                            end
                            if(matrix[row][col] != 2'b00)
                            begin
                                if(kk != -1)
                                begin
                                    matrix[kk][col] = matrix[row][col];
                                    matrix[row][col] = 2'b00;
                                    kk = kk + 1;
                                end
                            end
                        end  
                     end

                    state <= CLEAR;
                   end
           
           //player loses the game if the 7th row(the top first row in the 8x8 led matrix) 
           //and the 3rd and 4th columns are filled with colors(the 4th and 5th columns in the 8x8 led matrix if we start to count from 0)
            GAME_OVER:
                        begin
                        gameOver = 1'b1;
                        end
            default: state <= INITIALIZE;
        endcase
        end
 end
endmodule
