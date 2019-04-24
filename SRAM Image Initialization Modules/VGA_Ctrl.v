////////////////////////////////////////////////////////////////////////////////////
// VGA Controller Module
// Jeff Yates, Tom Gowing, Kerran Flanagan
// ECE 5760 Final Project - Cartoonifier
// 
// ---------------------------------------------------------------------------------
// Description:
// ---------------------------------------------------------------------------------
// This module sends the given pixel info and appropriate control signals based
// on the information about that pixel. 
// 
// Revision History :
// ---------------------------------------------------------------------------------
//   Ver  :| Author(s)                               :| Mod. Date  :| Changes Made:
//   V1.0 :| Jeff Yates, Tom Gowing, Kerran Flanagan :|            :| Initial Code
//   V1.1 :| Reiner Dizon                            :| 08/10/2017 :| Added Comments
//   V1.2 :| Reiner Dizon                            :| 08/14/2017 :| Added 800*600 Functionality
// ---------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////////

module	VGA_Ctrl (	
	// Host Side
	iRed,
	iGreen,
	iBlue,
	oCurrent_X,
	oCurrent_Y,
	oAddress,
	oRequest,
	oShift_Flag,
	
	// VGA Side
	oVGA_R,
	oVGA_G,
	oVGA_B,
	oVGA_HS,
	oVGA_VS,
	oVGA_SYNC,
	oVGA_BLANK,
	oVGA_CLOCK,
	
	// Control Signal
	iCLK,
	iRST_N
);

//=======================================================
//  PORT declarations
//=======================================================
//	Host Side
input		[9:0]	iRed;			// incoming red pixel
input		[9:0]	iGreen;			// incoming green pixel
input		[9:0]	iBlue;			// incoming blue pixel
output		[21:0]	oAddress;		// address to be accessed
output		[10:0]	oCurrent_X;		// current x-coordinate
output		[10:0]	oCurrent_Y;		// current y-coordinate
output				oRequest;		// request signal (1 if ready to grab new pixels)
output				oShift_Flag;	// shift flag (1 if ready to shift buffers)
//	VGA Side
output		[9:0]	oVGA_R;			// VGA red pixel
output		[9:0]	oVGA_G;			// VGA blue pixel
output		[9:0]	oVGA_B;			// VGA green pixel
output	reg			oVGA_HS;		// horizontal sync signal
output	reg			oVGA_VS;		// vertical sync signal
output				oVGA_SYNC;		// VGA sync signal
output				oVGA_BLANK;		// blank signal
output				oVGA_CLOCK;		// VGA clock
//	Control Signal
input				iCLK;			// input clock signal
input				iRST_N;			// reset signal

//=======================================================
//  REG/Wire declarations
//=======================================================
//	Internal Registers
reg			[10:0]	H_Cont;		// line counter (# of rows read)
reg			[10:0]	V_Cont;		// pixel counter (# of columns read within a row)


//=======================================================
//  PARAMETER declarations
//=======================================================
`ifdef VGA_640x480p60
//	Horizontal	Parameter
parameter	H_FRONT	=	16;		// Horizontal Front Porch
parameter	H_SYNC	=	96;		// Horizontal Sync Pulse
parameter	H_BACK	=	48;		// Horizontal Back Porch
parameter	H_ACT	=	640;	// Actual Width

//	Vertical Parameter
parameter	V_FRONT	=	11;		// Vertical Front Porch
parameter	V_SYNC	=	2;		// Vertical Sync Pulse
parameter	V_BACK	=	31;		// Vertical Back Porch
parameter	V_ACT	=	480;	// Actual Height

`else // SVGA_800x600p60
//	Horizontal	Parameter
parameter	H_FRONT	=	40;		// Horizontal Front Porch
parameter	H_SYNC	=	128;	// Horizontal Sync Pulse
parameter	H_BACK	=	88;		// Horizontal Back Porch
parameter	H_ACT	=	800;	// Actual Width

//	Vertical Parameter
parameter	V_FRONT	=	2;		// Vertical Front Porch
parameter	V_SYNC	=	4;		// Vertical Sync Pulse
parameter	V_BACK	=	21;		// Vertical Back Porch
parameter	V_ACT	=	600;	// Actual Height
`endif

parameter	H_BLANK	=	H_FRONT+H_SYNC+H_BACK;			// Horizontal Blank Porch
parameter	H_TOTAL	=	H_FRONT+H_SYNC+H_BACK+H_ACT;	// Total = Sum of above
parameter	H_DLY	=	0; 								// number of pixels to delay due to buffering (default = 2)

parameter	V_BLANK	=	V_FRONT+V_SYNC+V_BACK;			// Vertical Blank Porch
parameter	V_TOTAL	=	V_FRONT+V_SYNC+V_BACK+V_ACT;	// Total = Sum of Above
parameter	V_DLY	=	0; 								// number of lines to delay due to buffering (default = 2)

//=======================================================
//  Structural coding
//=======================================================
assign	oVGA_SYNC	=	1'b1;			//	This pin is unused.
assign	oVGA_BLANK	=	~((H_Cont<H_BLANK)||(V_Cont<V_BLANK));
assign	oShift_Flag	=	~((H_Cont<(H_BLANK-H_DLY))||(V_Cont<(V_BLANK-V_DLY)));
assign	oVGA_CLOCK	=	~iCLK;
assign	oVGA_R		=	iRed;
assign	oVGA_G		=	iGreen;
assign	oVGA_B		=	iBlue;
assign	oAddress	=	oCurrent_Y * H_ACT + oCurrent_X;
assign	oRequest	=	((H_Cont>=H_BLANK-H_DLY && H_Cont<H_TOTAL-H_DLY)	&&
						 (V_Cont>=V_BLANK-V_DLY && V_Cont<V_TOTAL-V_DLY));
assign	oCurrent_X	=	(H_Cont>=(H_BLANK-H_DLY) && H_Cont<H_TOTAL)	?	H_Cont-(H_BLANK-H_DLY)	:	11'h0;
assign	oCurrent_Y	=	(V_Cont>=(V_BLANK-V_DLY) && V_Cont<V_TOTAL)	?	V_Cont-(V_BLANK-V_DLY)	:	11'h0;

//	Horizontal Generator: Refer to the pixel clock
always @ (posedge iCLK or negedge iRST_N) begin
	if(!iRST_N) begin
		H_Cont		<=	0;	// reset horizontal counter
		oVGA_HS		<=	1;	// set horizontal sync HIGH
	end
	
	else begin
		if(H_Cont < H_TOTAL)	
			H_Cont	<=	H_Cont+1'b1; // increment horizontal counter
		else					
			H_Cont	<=	0;	// reset horizontal counter
		
		//	Horizontal Sync
		if(H_Cont == H_FRONT-1)			//	Front porch end
			oVGA_HS	<=	1'b0;
		if(H_Cont == H_FRONT+H_SYNC-1)	//	Sync pulse end
			oVGA_HS	<=	1'b1;
	end
end

//	Vertical Generator: Refer to the horizontal sync
always @ (posedge oVGA_HS or negedge iRST_N) begin
	if(!iRST_N) begin
		V_Cont		<=	0;	// reset vertical counter
		oVGA_VS		<=	1;	// set vertical sync HIGH
	end
	else begin
		if(V_Cont < V_TOTAL)
			V_Cont	<=	V_Cont+1'b1;
		else
			V_Cont	<=	0;
		
		//	Vertical Sync
		if(V_Cont == V_FRONT-1)			//	Front porch end
			oVGA_VS	<=	1'b0;
		if(V_Cont == V_FRONT+V_SYNC-1)	//	Sync pulse end
			oVGA_VS	<=	1'b1;
	end
end

endmodule