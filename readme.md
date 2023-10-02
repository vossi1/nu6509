# Nu6509 - Adapter to use 6502 in 6509-based system

**Original Design: Copyright (c) 2017-2019 Jim Brain dba RETRO Innovations**

**Copyright (c) 2023 Vossi - v.1**
[fixed, modified, no '816 support!]

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

**[Schematic](https://github.com/vossi1/nu6509/blob/master/Nu6509_vossi_v1.png)**

![NU6509 photo](https://github.com/vossi1/nu6509/blob/master/nu6509_vossi_v1_pcb.png)
    
**Fixed:**

	databus read out always active if no WRITE (not only at PHI2=high, not dependent from RDY)
	databus not dependent from RDY (ready is ignored at writes, wdc allows halt in write cycles)
	databus writes not dependent from AEC (original 6509 doesn't disable DB with AEC)
	hardwired sync (important for timing in P500)

**Modified:**

	removed 65816 support
	added jtag connector
	only 0805 parts
	hardwired so
	solderpad is pre-connected for NMOS/CMOS 6502 -> cut for WDC W65C02S

**Tested successful in cbm620 with:**
Tests: Diagnostic-Cart, Burnin-Test, Michal's Testsuite, Superscript

	mos6502A
	mos6502B (3MHz)
	R6502AP
	UM6502A
	UMC6502CE (4MHz, nmos)
	CMD G65SC02-2
	gte G65SC02-2
	WDC W65C02S-8 (8MHz)
  (all cmos chips have TOD error in cbm burnin test???)

**Tested successful in P500 with:**
Tests: PacMan, Wizard of War, cbm RAM-Test (improved by Vossi), David Viner's Hires-Demo

	mos6502A
	mos6502B (3MHz)
	R6502
	R6502AP
	SY6502
	UM6502A
	UMC6502CE (4MHz)
	CMD G65SC02-2
	gte G65SC02-2
	WDC W65C02S-8 (8MHz)