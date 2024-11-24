`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    05:23:46 11/01/2023 
// Design Name: 
// Module Name:    inverter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`ifndef _inverter
`define _inverter
module inverter(in, out);

input in;
output out;

	not n1 (out, in);

endmodule

`endif
