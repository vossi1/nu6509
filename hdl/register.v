`timescale 1ns / 1ps
// Register module with variable size
// Copyright (c) 2024 Vossi, www.mos6509.com, part of NU6509

`ifndef _register
`define _register
module register(clock, reset, enable, d, q);

parameter WIDTH = 8 ;
parameter RESET = 0 ;

input clock;
input reset;
input enable;
input [WIDTH-1:0] d;
output reg [WIDTH-1:0] q;
initial q = RESET;

always @(negedge clock, posedge reset)
begin
	if(reset)
		q <= RESET;
	else if(enable)
		q <= d;
end
endmodule
`endif
