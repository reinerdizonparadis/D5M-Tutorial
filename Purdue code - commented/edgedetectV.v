////////////////////////////////////////////////////////////////////////////////////
// 3x3 Convolution for Vertical Edge Detection Module
// Jeff Yates, Tom Gowing, Kerran Flanagan
// ECE 5760 Final Project - Cartoonifier
// 
// ---------------------------------------------------------------------------------
// Description:
// ---------------------------------------------------------------------------------
// This module uses the Sobel Filter for vertical edges. A 3x3 pixel grid of
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

module edgedetectV (clock, iGrid, iThreshold, oPixel);

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
wire [9:0] left, right, sum1, sum2;	// sobel calculations
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

/* Sobel filter for vertical edge:
	----------------
	| -1 |  0 | +1 |
	----------------
	| -2 |  0 | +2 |
	----------------
	| -1 |  0 | +1 |
	----------------
	
	This filter is applied to the intensity grid like so:
	-------------------------
	| 1*[8] | 0*[7] | 1*[6] |
	-------------------------
	| 2*[5] | 0*[4] | 2*[3] |
	-------------------------
	| 1*[2] | 0*[1] | 1*[0] |
	-------------------------
	 ^ left            ^ right
	 
	where [n] is the position in the 3x3 grid array
*/

assign right = intensity[6]+(intensity[3]<<1)+intensity[0];	// sum of 1st column of filter calculation = [8] + 2*[5] + [2]
assign left = intensity[8]+(intensity[5]<<1)+intensity[2];	// sum of 3rd column of filter calculation = [6] + 2*[3] + [0]

// Since the filter has negative signs, it will be applied to left or right seperately
// and calculate sums based on this in order to find the greater positive value.
assign sum1 = right-left;
assign sum2 = left-right;

// if (sum1 > edge threshold) or (sum2 > edge threshold) => THERE IS AN EDGE
always @ (posedge clock) begin
	if ((sum1[9]==0 && (sum1 > iThreshold)) || (sum2[9]==0 && (sum2 > iThreshold)))
		oPixel <= 1'b1;
	else
		oPixel <= 1'b0;
end

endmodule
