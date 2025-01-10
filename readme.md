# Nu6509 - Adapter to use 6502 in 6509-based system

**Original Design: Copyright (c) 2017-2019 Jim Brain dba RETRO Innovations**

**Copyright (c) 2023 Vossi - v.2** [fixed, modified, 6512 support, no '816 support]

**www.mos6509.com**

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

**Nu6509.v: Routines to support mapping the 6509-specific bank functionality onto the 6502.**

**[Schematic](https://github.com/vossi1/nu6509/blob/master/schematics_v2.png)**

**[Parts](https://github.com/vossi1/nu6509/blob/master/parts.txt)**

**CPLD-Firmware:** The .JED file can be uploaded with a JTAG-SMT2 Xilinx programmer (China) and [XC3SPROG](https://xc3sprog.sourceforge.net/)


**USE v.2 HDL-code in Folder HDL-P500 for the P500 - for the 6xx, 7xx v.2 and v.2a are ok**

![NU6509 real_v2](https://github.com/vossi1/nu6509/blob/master/nu6509v2.jpg)

**Fixed:**

	databus not dependent from RDY (ready is ignored at writes, wdc allows halt in write cycles)
	databus read and write with 30ns hold time after PHI2 falling edge
	hardwired SYNC (important for timing in P500)

**Modified:**

	removed 65816 support
	added jtag connector
	only 0805 parts
	hardwired _SO
	solderpad is pre-connected for NMOS/CMOS 6502 -> cut for WDC W65C02S
	added 6512 support with solderpad for PHI1 in from 6509 socket

![NU6509 pcb_front](https://github.com/vossi1/nu6509/blob/master/pcb_v2_1.png)
![NU6509 pcb_back](https://github.com/vossi1/nu6509/blob/master/pcb_v2_2.png)

:x: **BEWARE: XC9572 from China are mostly FAKES - many of them work - but you don't know what you get!**

Notes:
In low profile machines there is not enough space in the height to insert the adapter with socket. There is even less space in devices with a bottom-mounted power supply unit. The only solution is to first test the NU6509 in an open device and then solder it directly into the board.
The NU6509 does not support AEC! No known CBMII-machine uses it - AEC is always pulled up on all CBMII-boards.
If you encounter problems with a specific 6502 CPU, try another one - best choice is mostly an old mos 6502A.

**Tested successful in cbm2 with:** Diagnostic, Burnin-Test, Testsuite, Superscript, Monitor D.Viner, Supermon, Diskview

Test-boards: 610 Rev.E, 620 Rev.F, 710 Rev.B, 710 Rev.C, 720 Rev. B

	mos6502A
	mos6502AD
	mos6502B (3MHz)
	R6502AP
	UM6502A
	UM6502B (3MHz, nmos)
	UM6502CE (4MHz, nmos)
	R65C02P2 (cmos)
	R65C02-J4 (4MHz, cmos, in PLCC Adapter)
	gteµ G65SC02P-2 (cmos)
	CMD G65SC02PI-2 (cmos)
	CMD G65SC02PE-4 (4MHz, cmos, in PLCC Adapter)
	WDC W65C02S8PL-10 (10MHz, cmos, in PLCC Adapter)

	R6512AP (with Solderpad 6512 for PHI1 - needs the two-phase clock!)
	GTEµ G65SC12P-2 (2MHz, cmos) (with Solderpad 6512 for PHI1 - needs the two-phase clock!)

Note cmos: (all cmos chips have TOD error in the cbm2 burnin test - localized at indirect read from CIA registers - so they are probably unusable?)

**Tested successful in P500 EU with:** pm500, wiz500, amind500 (all converted by vossi), P500-Test (finished & improved by Vossi), David Viner's Hires-Demo

	mos6502
	mos6502AD
	mos6502A
	mos6502B (3MHz)
	R6502
	R6502AP
	SY6502
	UM6502
	UM6502A
	UM6502B (3MHz, nmos)
	UM6502CE (4MHz, nmos)
	R65C02P2 (cmos)
	R65C02-J4 (4MHz, cmos, in PLCC Adapter)
	gteµ G65SC02P-2 (cmos)
	CMD G65SC02PI-2 (cmos)
	CMD G65SC02PE-4 (4MHz, cmos, in PLCC Adapter)
	WDC W65C02S8PL-10 (10MHz, cmos, in PLCC Adapter)

	R6512AP (with Solderpad 6512 for PHI1 - needs the two-phase clock!)
	GTEµ G65SC12P-2 (with Solderpad 6512 for PHI1 - needs the two-phase clock!)

Note cmos: (amind 500 uses illegal opcodes and doesn't run on cmos CPU's)
Note cmos: (all cmos chips have also TOD error in my new P500-test v. 1.4 - so they are probably unusable?)
