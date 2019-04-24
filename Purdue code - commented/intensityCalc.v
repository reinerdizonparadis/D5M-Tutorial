////////////////////////////////////////////////////////////////////////////////////
// Intensity Calculator Module
// Jeff Yates, Tom Gowing, Kerran Flanagan
// ECE 5760 Final Project - Cartoonifier
// 
// ---------------------------------------------------------------------------------
// Description:
// ---------------------------------------------------------------------------------
// This module calculates a pixel's intensity based on our sensitivity to green.
// The chosen weights for this module are: 25% red, 50% green, and 25% blue.
// With these weight being powers of 2, shift operations are used for division.
//
// Revision History :
// ---------------------------------------------------------------------------------
//   Ver  :| Author(s)                               :| Mod. Date  :| Changes Made:
//   V1.0 :| Jeff Yates, Tom Gowing, Kerran Flanagan :|            :| Initial Code
//   V1.1 :| Reiner Dizon                            :| 08/14/2017 :| Added Comments
// ---------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////////

module intensityCalc (iCLK, iR, iG, iB, oIntensity);

//=======================================================
//  PORT declarations
//=======================================================
input iCLK;						// VGA clock
input [9:0]	iR, iG, iB;			// RGB input

output reg [9:0] oIntensity;	// Intensity output

//=======================================================
//  Structural coding
//=======================================================

// Intensity Formula: I = R/4  + G/2  + B/4
always @(posedge iCLK)
	oIntensity <= (iR >> 2) + (iG >> 1) + (iB >> 2);
	
endmodule
