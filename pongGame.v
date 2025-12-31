module regn(R, Resetn, E, Clock, Q);
    parameter n = 8;
    input [n-1:0] R;
    input Resetn, E, Clock;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (!Resetn)
            Q <= 0;
        else if (E)
            Q <= R;
endmodule

module ToggleFF(T, Resetn, Clock, Q);
    input T, Resetn, Clock;
    output reg Q;

    always @(posedge Clock)
        if (!Resetn)
            Q <= 0;
        else if (T)
            Q <= ~Q;
endmodule

module DFlipFlop(D, L, H, Resetn, Clock, Q);
    input D, L, H, Resetn, Clock;
    output reg Q;

    always @(posedge Clock)
        if (!Resetn)
            Q <= 0;
			else if (L)
            Q <= 1;
			else if (H)
            Q <= 0;
			else 
				Q <= D;
endmodule

module BallFlipFlop(D, L, H, Resetn, Clock, Q);
    input D, L, H, Resetn, Clock;
    output reg Q;

    always @(posedge Clock)
        if (!Resetn)
            Q <= 0;
			else if (L)
            Q <= 1;
			else if (H)
            Q <= 0;
//			else 
//				Q <= D;
endmodule

module UpDn_count (R, Clock, Resetn, E, L, UpDn, Q);
    parameter n = 8;
    input [n-1:0] R;
    input Clock, Resetn, E, L, UpDn;
    output reg [n-1:0] Q;

    always @ (posedge Clock)
        if (Resetn == 0)
            Q <= 0;
        else if (L == 1)
            Q <= R;
        else if (E)
            if (UpDn == 1)
                Q <= Q + 1;
            else
                Q <= Q - 1;
endmodule

module hex7seg (hex, display);
    input [3:0] hex;
    output [6:0] display;

    reg [6:0] display;

    /*
     *       0  
     *      ---  
     *     |   |
     *    5|   |1
     *     | 6 |
     *      ---  
     *     |   |
     *    4|   |2
     *     |   |
     *      ---  
     *       3  
     */
    always @ (hex)
        case (hex)
            4'h0: display = 7'b1000000;
            4'h1: display = 7'b1111001;
            4'h2: display = 7'b0100100;
            4'h3: display = 7'b0110000;
            4'h4: display = 7'b0011001;
            4'h5: display = 7'b0010010;
            4'h6: display = 7'b0000010;
            4'h7: display = 7'b1111000;
            4'h8: display = 7'b0000000;
            4'h9: display = 7'b0011000;
            4'hA: display = 7'b0001000;
            4'hB: display = 7'b0000011;
            4'hC: display = 7'b1000110;
            4'hD: display = 7'b0100001;
            4'hE: display = 7'b0000110;
            4'hF: display = 7'b0001110;
        endcase
endmodule

module timing (Clock, Reset, tick);
  input wire Clock, Reset;
  output reg tick;
  reg [27:0]Q;
  parameter stop = 28'd010;
  	 //if (Q == 28'd002)
	 //if (Q == 28'd25000000)
	 //if (Q == 28'd06250000)
	 //28'd12500000

  
  always @ (posedge Clock)
    begin
	 if (Q == stop)
		begin
		 Q = 28'd0;
		 tick = ~tick;
		 end
		if ((!Reset))
		begin
        Q = 28'd1;
		  tick = 1'b0;
		  end
		else begin
			Q <= Q + 1;	
		 end
    end
endmodule 

module colision(CLOCK_50, X,Y, Y1, Y2, Xcol, Ycol,  player1, player2, Resetn);
//parameter num = 3; // number of objects
input[7:0]  X;
input[6:0]  Y, Y1, Y2;
input Resetn; 

input CLOCK_50;
output reg  Xcol, Ycol;
output reg player1, player2;

reg hit;
	 
	 // game parameters
	 parameter num = 3; // number of objects
	 parameter length = 7'd25, width = 8'd2; // paddle length
	 parameter size = 8'd5; // ball size (width and lenght)
	 
	 parameter  XBorder = 8'd02; 
	 parameter  XSCREEN = 160,  YSCREEN = 120;
	 parameter  X0 = 8'd02; 
	 

integer i;

	
//FSM output		  
always @ (posedge CLOCK_50)
	 begin
	 if (!Resetn) 
	 begin
	 hit = 0; Xcol= 0; Ycol = 0;
	 player1 = 0; player2 = 0;
	 end
	 else 
	 begin
	 hit = 0; Xcol= 0; Ycol = 0;
	 player1 = 0; player2 = 0;
	 for (i = 0; i < length; i = i + 1) 
		begin
		if ((X == (X0 + width)) && ((Y) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end  								
		else if ((X == (X0 + width)) && ((Y + 1) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end 
		else if ((X == (X0 + width)) && ((Y + 2) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end 								
		else if ((X == (X0 + width)) && ((Y + 3) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end 
		else if ((X == (X0 + width)) && ((Y + 4) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end 
		else if ((X == (X0 + width)) && ((Y + 5) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end 
		
		else if ((X == (X0 + width -1)) && ((Y) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end  								
		else if ((X == (X0 + width -1)) && ((Y + 1) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end 
		else if ((X == (X0 + width -1)) && ((Y + 2) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end 								
		else if ((X == (X0 + width -1)) && ((Y + 3) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end 
		else if ((X == (X0 + width -1)) && ((Y + 4) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end 
		else if ((X == (X0 + width -1)) && ((Y + 5) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end 
		
		else if ((X == (X0 + width - 2)) && ((Y) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end  								
		else if ((X == (X0 + width - 2)) && ((Y + 1) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end 
		else if ((X == (X0 + width - 2)) && ((Y + 2) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end 								
		else if ((X == (X0 + width - 2)) && ((Y + 3) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end 
		else if ((X == (X0 + width - 2)) && ((Y + 4) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end 
		else if ((X == (X0 + width - 2)) && ((Y + 5) == (Y1 + i))) 
		begin Xcol = 1; hit = 1; player1 = 1;  end 

		
		else if (((X +size) == (XSCREEN- X0))  && ((Y) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		else if (((X +size) == (XSCREEN- X0))  && ((Y + 1) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		else if (((X +size) == (XSCREEN- X0))  && ((Y + 2) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		else if (((X +size) == (XSCREEN- X0))  && ((Y + 3) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		else if (((X +size) == (XSCREEN- X0))  && ((Y + 4) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		else if (((X +size) == (XSCREEN- X0))  && ((Y + 5) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		
		else if (((X +size) == (XSCREEN- X0+1))  && ((Y) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		else if (((X +size) == (XSCREEN- X0+1))  && ((Y + 1) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		else if (((X +size) == (XSCREEN- X0+1))  && ((Y + 2) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		else if (((X +size) == (XSCREEN- X0+1))  && ((Y + 3) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		else if (((X +size) == (XSCREEN- X0+1))  && ((Y + 4) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		else if (((X +size) == (XSCREEN- X0+1))  && ((Y + 5) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		
		else if (((X +size) == (XSCREEN- X0 +2))  && ((Y) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		else if (((X +size) == (XSCREEN- X0 +2))  && ((Y + 1) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		else if (((X +size) == (XSCREEN- X0 +2))  && ((Y + 2) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		else if (((X +size) == (XSCREEN- X0 +2))  && ((Y + 3) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		else if (((X +size) == (XSCREEN- X0 +2))  && ((Y + 4) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		else if (((X +size) == (XSCREEN- X0 +2))  && ((Y + 5) == (Y2 +i)))
		begin Xcol = 1; hit = 1; player2 = 1; end 
		end
	end
end
			
endmodule

module count (Clock, Resetn, E, Q);
    parameter n = 8;
    input Clock, Resetn, E;
    output reg [n-1:0] Q;

    always @ (posedge Clock)
        if (Resetn == 0)
            Q <= 0;
        else if (E)
                Q <= Q + 1;
endmodule
