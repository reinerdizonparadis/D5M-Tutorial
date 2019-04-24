////////////////////////////////////////////////////////////////////////////////////
// Weighted averager low-pass filter module
// Jeff Yates, Tom Gowing, Kerran Flanagan
// ECE 5760 Final Project - Cartoonifier
// 
// ---------------------------------------------------------------------------------
// Description:
// ---------------------------------------------------------------------------------
// This module calculates average of the previous some number of frames of pixel data.
// By default, the last 4 frames are used to calculate the average. With this parameter,
// the calculated average is 3/4 of the old pixel value plus 1/4 of new pixel value.
// The choice for this number of frames makes hardware division easier since 4 is a
// power of 2. See Structural Coding for more details.
// 
// TOP MODULE: TimeAverager.v
// 
// Revision History :
// ---------------------------------------------------------------------------------
//   Ver  :| Author(s)                               :| Mod. Date  :| Changes Made:
//   V1.0 :| Jeff Yates, Tom Gowing, Kerran Flanagan :|            :| Initial Code
//   V1.1 :| Reiner Dizon                            :| 08/14/2017 :| Added Comments
// ---------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////////

module averager (iRed, iGreen, iBlue, iOld, oNew);

//=======================================================
//  PORT declarations
//=======================================================
input [4:0] iRed, iGreen, iBlue;	// upper bits of pixel's RGB values
input [15:0] iOld;					// Saved sum: RGB = {x,5,5,5}

output [15:0] oNew;					// New sum: RGB = {x,5,5,5}

//=======================================================
//  PARAMETER declarations
//=======================================================
parameter n = 2;	// 2^n number of frames to average over
					// default parameter: n = 2 => 4 frames

//=======================================================
//  Structural coding
//=======================================================
// For n=2, the module will average the last 4 frames worth of pixel data.
// So, new average formula: newAvg = (3/4)*oldAvg + (1/4)*newColor

// To make it hardware calculation easy, the formula is rearranged as follows:
// newAvg = (1 - 1/4)*oldAvg + (newColor >> 2)
// newAvg = oldAvg - (1/4)*oldAvg + (newColor >> 2)
// newAvg = oldAvg - (oldAvg >> 2) + (newColor >> 2)

// The 5-bit RGB pixel data (old & new) is packed into a single 16-bit variable.
// So, the formula above will apply for all three colors separately & packed again.

assign oNew[14:10] = iOld[14:10] - (iOld[14:10]>>n) + (iRed>>n);
assign oNew[9:5]   = iOld[9:5]   - (iOld[9:5]>>n)   + (iGreen>>n);
assign oNew[4:0]   = iOld[4:0]   - (iOld[4:0]>>n)   + (iBlue>>n);
	
endmodule
