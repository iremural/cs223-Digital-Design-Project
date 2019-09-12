`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//@author irem ural 
// id 21502278
//@author emre dikenelli
//id 21501975 
// Create Date: 12/24/2016 01:36:02 PM
// Module Name: buttonSynchronizer
// Project Name: Puyo Pop
// Target Devices: Bays3 
// 
//////////////////////////////////////////////////////////////////////////////////

//this module is used to produce single cycle pulse when the input goes high 
// it is used from http://web.mit.edu/6.111/www/f2012/handouts/L05.pdf
module buttonSynchronizer(
input clk, a,
output out
);
logic s0,s1,s2;

always @(posedge clk)
begin
s0 <= a;
s1 <= s0;
s2 <= s1; 
end
assign out = ~s2 & s1;

endmodule
