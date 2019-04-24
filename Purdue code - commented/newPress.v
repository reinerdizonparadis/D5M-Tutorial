////////////////////////////////////////////////////////////////////////////////////
// Key Press Debouncer Module
// Jeff Yates, Tom Gowing, Kerran Flanagan
// ECE 5760 Final Project - Cartoonifier
// 
// ---------------------------------------------------------------------------------
// Description:
// ---------------------------------------------------------------------------------
// This module determines when user presses a button but not held. This is done
// through debouncing the key press. The output is high for only 1 cycle after each
// key presses. 
// 
// Revision History :
// ---------------------------------------------------------------------------------
//   Ver  :| Author(s)                               :| Mod. Date  :| Changes Made:
//   V1.0 :| Jeff Yates, Tom Gowing, Kerran Flanagan :|            :| Initial Code
//   V1.1 :| Reiner Dizon                            :| 08/14/2017 :| Added Comments
// ---------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////////

module newPress (iCLK, iKey, oNewPress);

//=======================================================
//  PORT declarations
//=======================================================
input iCLK;			// clock signal
input iKey;			// Active high button input

output oNewPress;	// key press signal

//=======================================================
//  REG/Wire declarations
//=======================================================
reg [1:0] press;	// Key history buffer

//=======================================================
//  Structural coding
//=======================================================
always @(posedge iCLK)
	press <= {press[0], iKey}; // update buffer like a shift register

// Only a new press after a rising edge of button
assign oNewPress = ~press[1] & press[0];

endmodule
