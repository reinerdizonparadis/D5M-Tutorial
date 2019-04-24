////////////////////////////////////////////////////////////////////////////////////
// 3 Line Buffer with taps module (for use in edge detection)
// Jeff Yates, Tom Gowing, Kerran Flanagan
// ECE 5760 Final Project - Cartoonifier
// 
// ---------------------------------------------------------------------------------
// Description:
// ---------------------------------------------------------------------------------
// This module uses 3 large shift registers that stores 3 rows of pixels: 
// (1) current row, (2-3) the two rows preceding it. Each of these shift  
// registers holds the same amount of pixels as the screen width (e.g. 640 for VGA)
// and 30-bits each pixel (10-bits for each RGB). The last pixel registers of 1st 2
// rows shifts into the 1st register of the next row. The last three registers of
// each row constitutes a 3x3 window needed for edge calculations. Also, the module
// will output the center (pixel) of that 3x3 grid as part for these calculations.
// See Structural Coding for more details.
// 
// Revision History :
// ---------------------------------------------------------------------------------
//   Ver  :| Author(s)                               :| Mod. Date  :| Changes Made:
//   V1.0 :| Jeff Yates, Tom Gowing, Kerran Flanagan :|            :| Initial Code
//   V1.1 :| Reiner Dizon                            :| 08/09/2017 :| Added Comments
//   V1.2 :| Reiner Dizon                            :| 08/14/2017 :| Added 800*600 Functionality
// ---------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////////

module buffer3 (clock, clken, shiftin, shiftout, oGrid);

//=======================================================
//  PORT declarations
//=======================================================
input wire			clock, clken;	// Clock & Clock Enable signals
input wire	[29:0]	shiftin;		// 30-bit RGB Pixel (10-bits each)

output	wire	[269:0]	oGrid;		// 3x3 block of neighboring pixels
output	reg		[29:0]	shiftout;	// center pixel of 3x3 grid

// Integer Declarations
integer i;	// loop variable for shifting in current RGB pixel


//=======================================================
//  PARAMETER declarations
//=======================================================
`ifdef VGA_640x480p60	parameter WIDTH = 640;	// screen's width (VGA)
`else					parameter WIDTH = 800;	// screen's width (Other)
`endif

//=======================================================
//  REG/Wire declarations
//=======================================================
reg	[29:0]	line1 	[WIDTH-1:0];	// current row of pixels
reg	[29:0]	line2	[WIDTH-1:0];	// previous row of pixels (before current)
reg	[29:0]	line3	[WIDTH-1:0];	// row of pixels before previous

//=======================================================
//  Structural coding
//=======================================================

/* 3-line buffer acts as one long shift register with 3 shift-outs for the grid
	
	Logical Structure (640*480 example):
	              -------------------------------------
	shiftin    -> | 000 | 001 | ... | 637 | 638 | 639 | (line1)
	              -------------------------------------
	line1[639] -> | 000 | 001 | ... | 637 | 638 | 639 | (line2)
			      -------------------------------------
	line2[639] -> | 000 | 001 | ... | 637 | 638 | 639 | (line3)
			      -------------------------------------
	
	The last 3 values of each line forms the 3x3 grid (640*480 example):
	        -------------------------------------------------
	(line1) | 637 (grid[8]) | 638 (grid[7]) | 639 (grid[6]) | 
	        -------------------------------------------------
	(line2) | 637 (grid[5]) | 638 (grid[4]) | 639 (grid[3]) |
	        -------------------------------------------------
	(line3) | 637 (grid[2]) | 638 (grid[1]) | 639 (grid[0]) |
	        -------------------------------------------------
	
	The center of the grid, grid[4] or line2[638], is also shifted out for edge calculations.
*/

always @ (posedge clock) begin
	// load data into buffer when enable is HIGH
	if(clken) begin
		line1[0] <= shiftin;
		line2[0] <= line1[WIDTH-1];
		line3[0] <= line2[WIDTH-1];
		for(i = 1; i < WIDTH; i = i + 1) begin
			line1[i] <= line1[i-1];
			line2[i] <= line2[i-1];
			line3[i] <= line3[i-1];
		end
		shiftout <= line2[WIDTH-2]; // center of grid
	end
	
	// keep data within buffer when enable is LOW
	else begin
		for(i = 0 ; i < WIDTH; i = i + 1) begin
			line1[i] <= line1[i];
			line2[i] <= line2[i];
			line3[i] <= line3[i];
		end
		shiftout <= shiftout;
	end
end

// grid output
assign oGrid = {line1[WIDTH-1],line1[WIDTH-2],line1[WIDTH-3],		// grid[8] grid[7] grid[6]
				line2[WIDTH-1],line2[WIDTH-2],line2[WIDTH-3],		// grid[5] grid[4] grid[3]
				line3[WIDTH-1],line3[WIDTH-2],line3[WIDTH-3]};		// grid[2] grid[1] grid[0]
endmodule
