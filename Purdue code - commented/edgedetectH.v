////////////////////////////////////////////////////////////////////////////////////
// 3x3 Convolution for Horizontal Edge Detection Module
// Jeff Yates, Tom Gowing, Kerran Flanagan
// ECE 5760 Final Project - Cartoonifier
// 
// ---------------------------------------------------------------------------------
// Description:
// ---------------------------------------------------------------------------------
// This module uses the Sobel Filter for horizontal edges. A 3x3 pixel grid of
// intensity values from the intensity calculation module is the main input 
// to this module. With this grid, they convolve with the filter. This means
// each corresponding pixel in the grid is each multiplied to the corresponding
// constants in the Sobel filter. See Structural Coding for more details.
// 
// Revision History :
// ---------------------------------------------------------------------------------
//   Ver  :| Author(s)                               :| Mod. Date  :| Changes Made:
//   V1.0 :| Jeff Yates, Tom Gowing, Kerran Flanagan :|            :| Initial Code
//   V1.1 :| Reiner Dizon                            :| 08/14/2017 :| Added Comments
// ---------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////////

module edgedetectH (clock, iGrid, iThreshold, oPixel);

//=======================================================
//  PORT declarations
//=======================================================
input wire			clock;			// clock signal
input wire [89:0] 	iGrid;			// 3x3 grid of intensity values from intensityCalc
input wire [9:0] 	iThreshold;		// edge threshold

output reg	 oPixel; 				// edge existence signal (0 if not edge, 1 if edge)

//=======================================================
//  REG/Wire declarations
//=======================================================
wire [9:0] top, bottom, sum1, sum2; // sobel calculations
wire [9:0] intensity [8:0];			// 3x3 intensity grid

//=======================================================
//  Structural coding
//=======================================================

/* grab each intensity values & place them into intensity values array:
	-------------------
	| [8] | [7] | [6] |
	-------------------
	| [5] | [4] | [3] |
	-------------------
	| [2] | [1] | [0] |
	-------------------
	where [n] is the position in the 3x3 grid array
*/

assign intensity[0] = iGrid[9:0];
assign intensity[1] = iGrid[19:10];
assign intensity[2] = iGrid[29:20];
assign intensity[3] = iGrid[39:30];
assign intensity[4] = iGrid[49:40];
assign intensity[5] = iGrid[59:50];
assign intensity[6] = iGrid[69:60];
assign intensity[7] = iGrid[79:70];
assign intensity[8] = iGrid[89:80];

/* Sobel filter for horizontal edge (signs are irrelevant here, below is typical implementation):
	----------------
	| -1 | -2 | -1 |
	----------------
	|  0 |  0 |  0 |
	----------------
	| +1 | +2 | +1 |
	----------------
	
	This filter is applied to the intensity grid like so:
	-------------------------
	| 1*[8] | 2*[7] | 1*[6] |   <-- top
	-------------------------
	| 0*[5] | 0*[4] | 0*[3] |
	-------------------------
	| 1*[2] | 2*[1] | 1*[0] |   <-- bottom
	-------------------------
	where [n] is the position in the 3x3 grid array
*/

assign top = intensity[8]+(intensity[7]<<1)+intensity[6];		// sum of 1st row of filter calculation = [8] + 2*[7] + [6]
assign bottom = intensity[2]+(intensity[1]<<1)+intensity[0];	// sum of 3rd row of filter calculation = [2] + 2*[1] + [0]

// calculate absolute difference between top and bottom = |top - bottom|
assign sum1 = top-bottom;
assign sum2 = bottom-top;

// if |top - bottom| > edge threshold => THERE IS AN EDGE
always @ (posedge clock) begin
	if ((sum1[9]==0 && (sum1 > iThreshold)) || (sum2[9]==0 && (sum2 > iThreshold)))
		oPixel <= 1'b1;
	else
		oPixel <= 1'b0;
end

endmodule
