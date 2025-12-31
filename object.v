module paddle(CLOCK_50, Resetn, draw, go ,VGA_X, VGA_Y, plot, VGA_COLOR, enable, row, X, Y, Dir);

    parameter A = 4'b0000, B = 4'b0001, C = 4'b0010, D = 4'b0011; 
    parameter E = 4'b0100, F = 4'b0101, G = 4'b0110, H = 4'b0111; 
	 parameter I = 4'b1000, J = 4'b1001, K = 4'b1010, L = 4'b1011; 
    parameter M = 4'b1100, N = 4'b1101, O = 4'b1110, P = 4'b1111;
    parameter  XSCREEN = 160,  YSCREEN = 120;
    //parameter   XDIM =  XSCREEN>>1,   YDIM = 1;// original
    parameter ALT = 3'b000; // alternate object color
    parameter W = 20; // animation speed: use 20 for hardware, 2 for ModelSim
	 parameter CLR = 3'b111; // colour of the objects
	 

	input CLOCK_50;	
	//input [7:0] SW; //used to do colour
	//input [3:0] KEY;
	input Resetn, draw, go; //replacing key
	input enable;
	input [1:0] Dir; // If 00 dont move, 01 up, 10 down, 11 dont care
	
	//input sync;
	output [7:0]VGA_X;
	output [6:0]VGA_Y;
	output [7:0] X;
	output [6:0] Y;
	output reg plot;
	output reg [2:0] VGA_COLOR;
	output reg row;
	
//	output VGA_HS;
//	output VGA_VS;
//	output VGA_BLANK_N;
//	output VGA_SYNC_N;
//	output VGA_CLK;
//	output HEX0,HEX1, HEX2,HEX3,HEX4, HEX5;

	
	//paddle 
	parameter   XDIM = 2,   YDIM = 50;// changed
   parameter   X0 = 8'd2,   Y0 = 7'd59;
	parameter 	Xbounce =1'b0 , Ybounce = 1'b1;
	parameter   XBorder = 8'd0, YBorder = 7'd0; 
	
	

	
	wire [2:0] colour;
	wire [7:0]  Z;
//	wire [7:0]  X; 
//	wire [6:0]  Y;
   wire [7:0]   XC;
   wire [6:0]   YC;

	wire  sync;
	wire [W-1:0] slow;
   
   reg 
	Ey, Ex, 
	Lxc, Lyc, 
	Exc, Eyc;
   wire   Ydir, Xdir;
	reg bottom, top;
   reg yTdir, xTdir;
   reg [3:0]  y_Q,   Y_D;
	//paddle 
	assign colour = CLR;
	//assign clock = CLOCK_50 && enable;
		
		
	// these decide it the object is moving (increasing/decreasing in X or Y direction)
   UpDn_count U1 ( Y0, CLOCK_50, Resetn, Ey, draw, Ydir, Y);
        defparam U1.n = 7;

	UpDn_count U2 ( X0, CLOCK_50, Resetn, Ex, draw, Xdir, X);
        defparam U2.n = 8;

	// these go through the size of the object 
    UpDn_count U3 (8'd0, CLOCK_50, Resetn, Exc, Lxc , 1'b1,   XC);
        defparam U3.n = 8;
    UpDn_count U4 (7'd0, CLOCK_50, Resetn, Eyc, Lyc , 1'b1,   YC);
        defparam U4.n = 7;
		  
	// creates a sync based on frame rate
	 UpDn_count U5 ({W{1'b0}}, CLOCK_50, Resetn, 1'b1, 1'b0, 1'b1, slow);
    defparam U5.n = W;
    assign sync = (slow == 0);

    DFlipFlop U6 ( Dir[0],  top, bottom, Resetn, CLOCK_50,  Ydir);
	 
	 ToggleFF  U7 ( xTdir ,  Resetn, CLOCK_50,  Xdir);
	 

	 


 // FSM state table
    always @ (*)
        case ( y_Q)
//ball FSM state function
            A:  if (!go || !sync)   Y_D = A;
                else   Y_D = B;
            B:  if ( XC !=  XDIM-1)   Y_D = B;    // draw
                else   Y_D = C;
            C:  if (  YC !=   YDIM-1)   Y_D = B;
                else   Y_D = D;
            D:  if (!sync)   Y_D = D;
                else   Y_D = E;
            E:  if (  XC !=   XDIM-1)   Y_D = E;    // erase
                else   Y_D = F;
            F:  if (  YC !=   YDIM-1)   Y_D = E;
                else   Y_D = G;
            G:  Y_D = H;
            H:  Y_D = B;
        endcase

    // FSM outputs
    always @ (*)
    begin
        // default assignments
		  bottom =1'b0; top = 1'b0;
         Lxc = 1'b0; Lyc = 1'b0; 
			Exc = 1'b0; Eyc = 1'b0; 
		   VGA_COLOR = colour; plot = 1'b0;
			
         Ey = 1'b0; Ex = 1'b0;
			yTdir = 1'b0;xTdir = 1'b0;
			row = 1'b0;
		if (enable)	
        case ( y_Q)
            A:  begin Lxc = 1'b1; Lyc = 1'b1; end
            B:  begin Exc = 1'b1; plot = 1'b1; end   // color a pixel
            C:  begin Lxc = 1'b1; Eyc = 1'b1; end
            D:  begin Lyc = 1'b1; row = 1'b1; end 
            E:  begin Exc = 1'b1; VGA_COLOR = ALT; plot = 1'b1; end   // color a pixel
            F:  begin Lxc = 1'b1; Eyc = 1'b1; VGA_COLOR = ALT; end
				G: begin Lyc = 1'b1; //row = 1'b1;
					top = (Y == 7'd0);
					bottom =	( Y ==  YSCREEN-YDIM) /*|| ( Y == 7'd0 + YBorder) || ( Y == YSCREEN-YDIM-YBorder)*/; 
					xTdir = ( X == 8'd0 ) || ( X ==  XSCREEN-XDIM-1) || ( X == 8'd0 ) /*|| ( X == 8'd0 + XBorder) || ( X == XSCREEN-XDIM-YBorder)*/; end
				H:	begin Ey = Dir[0] || Dir[1]; Ex = Xbounce; //row = 1'b1; 
				end 
        endcase
    end

    always @(posedge CLOCK_50)
        if (!Resetn)
             y_Q <= 1'b0;
        else
             y_Q <=   Y_D;
				 
// making sure the paddles dont escape
//always @(posedge CLOCK_50)
//begin
//        if (Y ==  YSCREEN-YDIM + 1)
//             Y = YSCREEN-YDIM;
//		  if (Y ==  YSCREEN-YDIM + 2)
//             Y = YSCREEN-YDIM;
//        if (Y ==  YSCREEN-YDIM + 3)
//             Y = YSCREEN-YDIM;
//		  if (Y ==  YSCREEN-YDIM + 4)
//             Y = YSCREEN-YDIM;
//end
        
    assign VGA_X =   X +   XC;
    assign VGA_Y =   Y +   YC;
	 
endmodule

module ball(CLOCK_50, Resetn, draw, go ,VGA_X, VGA_Y, plot, VGA_COLOR, 
enable, row, Xcol, Ycol, X,Y, left, right);

    parameter A = 4'b0000, B = 4'b0001, C = 4'b0010, D = 4'b0011; 
    parameter E = 4'b0100, F = 4'b0101, G = 4'b0110, H = 4'b0111; 
	 parameter I = 4'b1000, J = 4'b1001, K = 4'b1010, L = 4'b1011; 
    parameter M = 4'b1100, N = 4'b1101, O = 4'b1110, P = 4'b1111; 
    parameter  XSCREEN = 160,  YSCREEN = 120;
    parameter ALT = 3'b000; // alternate object color
    parameter W = 20; // animation speed: use 20 for hardware, 2 for ModelSim
	 parameter CLR = 3'b111; // colour of the objects

	input CLOCK_50;	
	//input [7:0] SW; //used to do colour
	//input [3:0] KEY;
	input Resetn, draw, go; //replacing KEY
	
	input enable, Xcol, Ycol;
	input left, right; 
	
	//input sync;
	output [7:0]VGA_X;
	output [6:0]VGA_Y;
	output [7:0] X;
	output [6:0] Y;

	output reg plot;
	output reg [2:0] VGA_COLOR;
	output reg row;
	
	//paddle 
	parameter   XDIM = 2,   YDIM = 50;// changed
   parameter   X0 = 8'd2,   Y0 = 7'd20;
	parameter 	Xbounce =1'b0 , Ybounce = 1'b1;
	parameter   XBorder = 8'd0, YBorder = 7'd0; 
	
	wire [2:0] colour;
	wire [7:0]  Z;
   wire [7:0]  XC;
   wire [6:0]  YC;
	wire  sync;
	wire [W-1:0] slow;
   wire go;
   reg 
	Ey, Ex, 
	Lxc, Lyc, 
	Exc, Eyc;
   wire   Ydir, Xdir;
   reg yTdir, xTdir;
	reg Lcol, Rcol;
	//reg left, right;
   reg [3:0]  y_Q,   Y_D;
	//paddle 
	assign colour = CLR;

   UpDn_count U1 ( 7'd20, CLOCK_50, Resetn, Ey, draw, Ydir, Y);
        defparam U1.n = 7;

	UpDn_count U2 ( X0, CLOCK_50, Resetn, Ex, draw, Xdir, X);
        defparam U2.n = 8;


    UpDn_count U3 (8'd0,CLOCK_50, Resetn, Exc, Lxc , 1'b1,   XC);
        defparam U3.n = 8;
    UpDn_count U4 (7'd0, CLOCK_50, Resetn, Eyc, Lyc , 1'b1, YC);
        defparam U4.n = 7;

	 UpDn_count U5 ({W{1'b0}}, CLOCK_50, Resetn, 1'b1, 1'b0, 1'b1, slow);
    defparam U5.n = W;
    assign sync = (slow == 0);

    ToggleFF U6 (yTdir|| Ycol, Resetn, CLOCK_50,  Ydir);
	BallFlipFlop U7 ( 1'b0, Lcol , Rcol, Resetn, CLOCK_50,  Xdir);

	 


    // FSM state table
    always @ (*)
		//if (enable)	
        case ( y_Q)
            A:  if (!go || !sync)   Y_D = A;
                else   Y_D = B;
            B:  if ( XC !=  XDIM-1)   Y_D = B;    // draw
                else   Y_D = C;
            C:  if (  YC !=   YDIM-1)   Y_D = B;
                else   Y_D = D;
            D:  if (!sync)   Y_D = D;
                else   Y_D = E;
            E:  if (  XC !=   XDIM-1)   Y_D = E;    // erase
                else   Y_D = F;
            F:  if (  YC !=   YDIM-1)   Y_D = E;
                else   Y_D = G;
            G:  Y_D = H;
            H:   Y_D = I;
				I: if (!sync)   Y_D = I; 
               else   Y_D = B;
        endcase

    // FSM outputs
    always @ (*)
    begin
        // default assignments
			Lcol =1'b0; Rcol = 1'b0;
         Lxc = 1'b0; Lyc = 1'b0; 
			Exc = 1'b0; Eyc = 1'b0; 
		   VGA_COLOR = colour; plot = 1'b0;
			
         Ey = 1'b0; Ex = 1'b0;
			yTdir = 1'b0;xTdir = 1'b0;
			row = 1'b0;
		if (enable)	
        case ( y_Q)
				A:  begin Lxc = 1'b1; Lyc = 1'b1; end
            B:  begin Exc = 1'b1; plot = 1'b1; end   // color a pixel
            C:  begin Lxc = 1'b1; Eyc = 1'b1; end
            D:  begin Lyc = 1'b1; row = 1'b1; end 
            E:  begin Exc = 1'b1; VGA_COLOR = ALT; plot = 1'b1; end   // color a pixel
            F:  begin Lxc = 1'b1; Eyc = 1'b1; end
            G:  begin Lyc = 1'b1; //row = 1'b1; // this needs to be fixed 
					yTdir = (Y == 7'd0 ) || (Y ==  YSCREEN-YDIM); /*|| ( Y == 7'd0 + YBorder) || ( Y == YSCREEN-YDIM-YBorder)*/ 
					Lcol = ((X == 8'd0) || left);
					Rcol = ((X ==  XSCREEN-XDIM) || right);  /*|| ( X == 8'd0 + XBorder) || ( X == XSCREEN-XDIM-YBorder)*/ 
					end
            H: begin Ey = Ybounce; Ex = Xbounce; //row = 1'b1;
				end
				default: Lcol = 1'b0;
				 
        endcase
    end

    always @(posedge CLOCK_50)
        if (!Resetn)
             y_Q <= 1'b0;
        else
             y_Q <=   Y_D;


    assign VGA_X =   X +   XC;
    assign VGA_Y =   Y +   YC;
	 
	 
endmodule
