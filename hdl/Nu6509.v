/*
   Nu6509 - Adapter to use 6502 in 6509-based system
   Original Design: Copyright (c) 2017-2019 Jim Brain dba RETRO Innovations
	
	Copyright (c) 2024 Vossi - v.2a - USE v.2 code for P500 !!!
	[fixed, modified, 6512 support, no '816 support]
	www.mos6509.com
	
   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.

   This Verilog attempts to implement the circuit by Dr. Jefyll in this post:
   http://forum.6502.org/viewtopic.php?p=17597&sid=0966e1fa047d491a969a4693b5fed5fd#p17597

   Nu6509.v: Routines to support mapping the 6509-specific bank
   functionality onto the 6502.
    
	fixed:
		databus not dependent from RDY (ready is ignored at writes, wdc allows halt in write cycles)
		databus read and write with 30ns hold time after PHI2 falling edge
		hardwired SYNC (important for timing in P500)
	modified:
		removed 65816 support
		added jtag connector
		only 0805 parts
		hardwired _SO
		solderpad is pre-connected for NMOS/CMOS 6502 -> cut for WDC W65C02S
		added 6512 support with solderpad for PH1 in from 6509 socket
		
The NU6509 does not support AEC! No known CBMII-machine uses it - AEC is always pulled up on all CBMII-boards.
*/
module Nu6509(	input [15:0]address_6502,
				inout [7:0]data_6502,
				inout [7:0]data_6509,
				output [3:0]address_bank,
				input r_w, input phi2, input sync, input rdy, input _reset
				); // input AEC not used - hardwired to WDC BE pin 36 - disables AB, DB, R_W

reg [7:0]data_out;
reg [7:0]data_6502_out;
wire delay1, delay2, delay3, delay4, delay5, delay6;	// holdtime delay wires
wire [3:0]data_0000;
wire [3:0]data_0001;
reg mmu_opcode, adr_bit0_old;
wire next_cycle, cycle2, cycle3, cycle4;	// cycle wires
reg io_select_latched, write1, mmu_shift, mmu0;
wire io_select, oe_data_in, oe_io_data, oe_d;
wire rd_0x00, rd_0x01, wr_0x00, wr_0x01;
wire phi1, phi2_th;

assign phi1 = !phi2;
assign data_6502 =	data_6502_out;			// data read output to 6502
assign data_6509 =	data_out;				// data write output to board

always @(negedge phi1)			// latch signals at phi1 falling edge
begin
	write1 <= !r_w;						// latched W/_R
	io_select_latched <= io_select;		// latch io_select
end

always @(negedge phi2)			// latch signals at phi2 falling edge
begin
	mmu_shift <= (rdy | write1);		// enables mmu shifting
	mmu_opcode <= sync & data_6502[7] & !data_6502[6] & (data_6502[4:0] == 5'b10001);	// detect opcode
	adr_bit0_old <= address_6502[0];	// remember cycle1 address bit #0 to detect next cycle
end

// phi2 delay for databus hold time ( about 30ns - each inverter needs 5ns )
(*S = "TRUE"*) inverter inv1(phi2, delay1);
(*S = "TRUE"*) inverter inv2(delay1, delay2);
(*S = "TRUE"*) inverter inv3(delay2, delay3);
(*S = "TRUE"*) inverter inv4(delay3, delay4);
(*S = "TRUE"*) inverter inv5(delay4, delay5);
(*S = "TRUE"*) inverter inv6(delay5, delay6);
assign phi2_th = phi2 | delay6;		// phi2 high 30ns extended (typical TH time mos 6510 datasheet)

assign oe_data_in =	!io_select_latched & phi2_th; 				// data in enable
assign oe_io_data = io_select_latched & phi2_th; 				// io in enable
assign oe_d = 		write1 & !io_select_latched & phi2_th;		// data out enable
assign io_select =	address_6502[15:1] == 0;					// port $0000 or $0001 selected
assign rd_0x00 	= !write1 & io_select & phi2_th & !address_6502[0];	// read ddr register 0x00
assign rd_0x01 	= !write1 & io_select & phi2_th & address_6502[0];	// read data register 0x01
assign wr_0x00 	= write1 & io_select & phi2 & !address_6502[0];		// write ddr register 0x00
assign wr_0x01 	= write1 & io_select & phi2 & address_6502[0];		// write data register 0x01

register #(.WIDTH(4), .RESET(4'b1111)) reg_0000(wr_0x00, !_reset, 1'b1, data_6502[3:0], data_0000);	// write execution bank
register #(.WIDTH(4), .RESET(4'b1111)) reg_0001(wr_0x01, !_reset, 1'b1, data_6502[3:0], data_0001);	// write indirect bank

assign next_cycle = (adr_bit0_old ^ address_6502[0]);		// detect next cyle, if address bit #0 has changed
// 3 bit MMU shift register
register #(.WIDTH(1)) reg_clock2(phi2, !_reset, mmu_shift, mmu_opcode & next_cycle, cycle2);	// shift 1
register #(.WIDTH(1)) reg_clock3(phi2, !_reset, mmu_shift, cycle2, cycle3);						// shift 2
register #(.WIDTH(1)) reg_clock4(phi2, !_reset, mmu_shift, cycle3, cycle4);						// shift 3

always @(*)		// MMU RS-FlipFlop
begin
	if(cycle4)			// set flip flop in cycle 4
		mmu0 <= 1;
	if(sync | !_reset)	// reset flip flop at sync (opcode finished)
		mmu0 <= 0;
end

assign address_bank =	(mmu0 ? data_0001 : data_0000);	// select bank

always @(*)		// databus read/write
begin
	if(oe_d) begin	
		data_6502_out = 8'bz;			// outputs to CPU hiz
		data_out = data_6502;					// data out to board (only if not bank-register write)
		end
	else begin
		data_out = 8'bz;				// outputs to board hiz
		if(rd_0x00 & oe_io_data)				// read bank reg $0000
			data_6502_out = data_0000;
		else if(rd_0x01 & oe_io_data)			// read bank reg $0001
			data_6502_out = data_0001;
		else if(oe_data_in)						// read data
			data_6502_out = data_6509;
		else 
		data_6502_out = 8'bz;			// outputs to CPU hiz
		end
end
endmodule