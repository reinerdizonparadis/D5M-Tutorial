////////////////////////////////////////////////////////////////////////////////////
// Image Initialization Module
//
// ---------------------------------------------------------------------------------
// Description:
// ---------------------------------------------------------------------------------
// This module initializes memory to the provided image file to be displayed
// to the screen via VGA.
// 
// Revision History :
// ---------------------------------------------------------------------------------
//   Ver  :| Author(s)     :| Mod. Date  :| Changes Made:
//   V1.0 :| Reiner Dizon  :| 08/28/2017 :| Initial Code
// ---------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////////

module image_init_unit(rClk, re, ra, rd, iX, iY);

//=======================================================
//  PORT declarations
//=======================================================
input rClk, re;
input [10:0] iX, iY;
input [ADDR_WIDTH-1:0] ra;
output reg [DATA_WIDTH-1:0] rd;

//=======================================================
//  REG/Wire declarations
//=======================================================
reg [ADDR_WIDTH-1 : 0] mem [0 : RAM_DEPTH-1];	// INTERNAL MEMORY

//=======================================================
//  PARAMETER declarations
//=======================================================
parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 14;
parameter RAM_DEPTH = (1 << ADDR_WIDTH);

//=======================================================
//  Structural coding
//=======================================================

// Memory Initialization Code - change the file name & size parameters for different images
initial $readmemh ("memfile2.dat", mem);
parameter WIDTH = 128;
parameter HEIGHT = 128;

// CODE - Read & Write
always @ (posedge rClk) begin
	if(re) begin
		if(iY >= 0 && iY < HEIGHT && iX >= 0 && iX < WIDTH)
			rd <= mem[iX * WIDTH + iY];
		else
			rd <= 0;
	end
end

endmodule
