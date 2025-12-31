module ending(CLOCK_50, X,Y, Y1, Y2,  miss1, miss2, Resetn);
//parameter num = 3; // number of objects
input[7:0]  X;
input[6:0]  Y, Y1, Y2;
input Resetn; 

input CLOCK_50;
output reg miss1, miss2;

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
	 hit = 0; 
	 miss1 = 0; miss2 = 0;
	 end
	 else 
	 begin
	 hit = 0; 
	 miss1 = 0; miss2 = 0;
		if (X == 8'd0 ) 
		begin hit = 1; miss1 = 1; end  		
		else if  ( X ==  XSCREEN) 
		begin hit = 1; miss2 = 1; end 

	end
end
			
endmodule