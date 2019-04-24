////////////////////////////////////////////////////////////////////////////////////
// Time averager module for 2x2 block of pixels
// Jeff Yates, Tom Gowing, Kerran Flanagan
// ECE 5760 Final Project - Cartoonifier
// 
// ---------------------------------------------------------------------------------
// Description:
// ---------------------------------------------------------------------------------
// This module finds the average of pixel data to reduce flicker between frames
// and due to simplication of color. It uses SRAM to store previous pixel data history
// To calculate the average, averager.v module is instantiated. With this module,
// the top module will also handle communication with the SRAM.
// 
// SUB-MODULE: averager.v
// 
// Revision History :
// ---------------------------------------------------------------------------------
//   Ver  :| Author(s)                               :| Mod. Date  :| Changes Made:
//   V1.0 :| Jeff Yates, Tom Gowing, Kerran Flanagan :|            :| Initial Code
//   V1.1 :| Reiner Dizon                            :| 08/14/2017 :| Added Comments
// ---------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////////

module TimeAverager (
	// VGA side
	iCLK, 
	iVGA_BLANK,
	iVGA_X, iVGA_Y,

	// Host side
	iRed, iGreen, iBlue,
	oRed, oGreen, oBlue,

	// SRAM side
	oSRAM_WE_N,
	oSRAM_ADDR,
	SRAM_DQ
);

//=======================================================
//  PORT declarations
//=======================================================

// VGA side
input 		iCLK;							// clock signal
input		iVGA_BLANK;						// VGA Blank signal 
input [9:0]	iVGA_X, iVGA_Y;					// Coordinates requested by VGA Ctrl

// Host side
input [4:0] iRed, iGreen, iBlue;			// upper bits of pixel's RGB values
output reg [4:0]	oRed, oGreen, oBlue;	// averaged RGB values

// SRAM side
output 	 			oSRAM_WE_N;				// SRAM Write Enable
output 	  [17:0] 	oSRAM_ADDR;				// SRAM Address
inout [15:0]		SRAM_DQ;				// SRAM Data Input/Output

//=======================================================
//  REG/Wire declarations
//=======================================================
wire [15:0] avg_in, avg_out;	// averaged values
reg [15:0] temp;				// temporary register

//=======================================================
//  Structural coding
//=======================================================

// To make 2x2 blocking, discard LSB and address for 320x240
assign oSRAM_ADDR = {iVGA_Y[9:1],iVGA_X[9:1]};

// Read during first cycle, write during second
assign SRAM_DQ = iVGA_X[0] ? avg_out : 16'hzzzz;

// Time averager module
averager avg0 (iRed, iGreen, iBlue, avg_in, avg_out);

// Take input from SRAM during first cycle
assign avg_in = iVGA_X[0] ?  temp : SRAM_DQ;

// Only write during first cycle if not a VGA blank
assign oSRAM_WE_N = (iVGA_X[0] && iVGA_BLANK) ? 1'b0 : 1'b1;

// update output with calculated average
always @(posedge iCLK) begin
	oRed <= avg_out[14:10];
	oGreen <= avg_out[9:5];
	oBlue <= avg_out[4:0];
	temp <= avg_out;
end

endmodule
	
	