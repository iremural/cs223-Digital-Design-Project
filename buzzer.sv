
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

// this module is used to generate an high signal when the player loses the game
// it takes an input from a switch to stop the sound(the buzz signal is low in this case) 
module buzzer(
input logic clk,gameOver,stop,
output logic buzz
    );
    
    always@(posedge clk)
    begin
    if(stop)
    buzz = 1'b0;
    else if(gameOver)
    buzz = 1'b1;
    else 
     buzz = 1'b0;
    end
endmodule
