/*
   Nu6509 - Adapter to use 6502 in 6509-based system
   Original Design: Copyright (c) 2017-2019 Jim Brain dba RETRO Innovations
	
	Copyright (c) 2023 Vossi - v.1
	[fixed, modified, no '816 support!]
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

   Nu6509.v: Routines to support mapping the 6509-specific bank
   functionality onto the 6502.
    
	fixed:
		databus read out always active if no WRITE (not only at PHI2=high, not dependent from RDY)
		databus not dependent from RDY (ready is ignored at writes, wdc allows halt in write cycles)
		databus writes not dependent from AEC (original 6509 doesn't disable DB with AEC)
		hardwired sync (important for timing in P500)
	modified:
		removed 65816 support
		added jtag connector
		only 0805 parts
		hardwired _so
		solderpad is pre-connected for NMOS/CMOS 6502 -> cut for WDC W65C02S
*/

// 816 part removed and modified by vossi 2023
// sync needs a wire from 6509 socket pin 3 to 6502 pin 7
// _so needs a wire from 6509 28 to 6502 38

module Nu6509(input _reset,
              input phi2_6509,
              input r_w,
              input [15:0]address_6502,
              inout [7:0]data_6502,
              inout [7:0]data_6509,
              input rdy,
              input aec, // hardwired to WDC BE pin 36 - disables AB, DB, _RW (original 6509 AEC disables only AB)
              input sync,
              output [3:0]address_bank
             );

reg [7:0]data_6502_out;
reg [7:0]data_6509_out;
wire [3:0]data_0000;
wire [3:0]data_0001;
wire [3:0]data_bank;
wire flag_opcode;
wire data_cycle1;
wire data_cycle2;
wire data_cycle3;
wire data_cycle4;
wire data_cycle5;wire sel_bank;
wire ce_bank;
wire we_bank;

/* This Verilog attempts to implement the circuit by Dr. Jefyll in this post:
   http://forum.6502.org/viewtopic.php?p=17597&sid=0966e1fa047d491a969a4693b5fed5fd#p17597
*/

assign ce_bank =                          address_6502[15:1] == 0;
assign we_bank =                          ce_bank & !r_w;
assign data_6509 =                        data_6509_out;
assign data_6502 =                        data_6502_out;

// Normal bank register (called Execution bank in MOS documentation)
register #(.WIDTH(4), .RESET(4'b1111))    reg_0000(phi2_6509, !_reset, we_bank & !address_6502[0], data_6502[3:0], data_0000);
// Indirect bank register (used for LDA Indirect, Y and STA Indirect, Y)
register #(.WIDTH(4), .RESET(4'b1111))    reg_0001(phi2_6509, !_reset, we_bank & address_6502[0], data_6502[3:0], data_0001);
// is this cycle an opcode?
register #(.WIDTH(1))                     reg_opcode(phi2_6509, !_reset, rdy, sync & data_6502[7] & !data_6502[6] & (data_6502[4:0] == 5'b10001), flag_opcode);
register #(.WIDTH(1))                     reg_clock1(phi2_6509, !_reset, rdy, address_6502[0], data_cycle1);
// compute the outcome of our combinatorial decision and store
register #(.WIDTH(1))                     reg_clock2(phi2_6509, !_reset, rdy, flag_opcode & (data_cycle1 ^ address_6502[0]), data_cycle2);
// shift
register #(.WIDTH(1))                     reg_clock3(phi2_6509, !_reset, rdy, data_cycle2, data_cycle3);
// shift
register #(.WIDTH(1))                     reg_clock4(phi2_6509, !_reset, rdy, data_cycle3, data_cycle4);
// shift
register #(.WIDTH(1))                     reg_clock5(phi2_6509, !_reset, rdy, data_cycle4, data_cycle5);// bank selection
assign sel_bank =                         (data_cycle5 & !sync) | data_cycle4;
assign address_bank =                     ( sel_bank ? data_0001 : data_0000);
// read bank registers in any bank.
assign data_bank = (address_6502[0] ? data_0001 : data_0000);

always @(*)
begin							 // & rdy is not nessasary at read
   if(r_w & ce_bank)
      data_6502_out = {4'b0000, data_bank};	// read bank reg
   else if(r_w & !ce_bank)
      data_6502_out = data_6509;					// read data
   else
      data_6502_out = 8'bz; 						// no read -> write
end

always @(*)
begin							// no & AEC here - original 6509 doesn't disable DB with AEC
								// no & rdy here - ready is ignored at writes, wdc allows halt in write cycles
   if(!r_w & phi2_6509) 
		data_6509_out = data_6502;					// write only at phi2=high
   else
      data_6509_out = 8'bz;						// no write
end
endmodule