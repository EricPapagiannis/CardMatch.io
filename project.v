module project
        (
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [17:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	reg drawScreen = 1'b0;
	reg [5:0] xcounter = 6'b000000;
	reg [5:0] ycounter = 6'b100000;
	reg [7:0] xin;
	reg [6:0] yin;
	reg [7:0] xin_prev1;
	reg [6:0] yin_prev1;
	reg [7:0] xin_prev2;
	reg [6:0] yin_prev2;
	reg [2:0] colour_in;
	reg [2:0] colour_in1;
	reg [2:0] colour_in2;
	reg [1:0] isFlipped = 2'b00;
	reg cardDrawn;
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "image.colour.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require
	// 22x32 card dimensions
	
	always@(posedge CLOCK_50)
	begin
		cardDrawn = 1'b0;
	   colour_in = colour_in1;
		if (ycounter < 6'b011100)
		begin
			xcounter = xcounter + 6'b000001;
			
			if (xcounter >= 6'b010010)
			begin
				xcounter = 6'b000000;
				ycounter = ycounter + 6'b000001;
				
				if (ycounter == 6'b011100)
				begin
					drawScreen = 6'b000000;
				end
			
			end
				
			if (xcounter >= 6'b001001)
			begin
			    colour_in = colour_in2;
			end
			
		end
		else
		begin
		
			if (isFlipped == 2'b00)
			begin
			isFlipped = isFlipped + 2'b01;
			end
			if (isFlipped == 2'b01)
			begin
			isFlipped = isFlipped + 2'b01;
			end
			
			drawScreen = 6'b000000;
		end

		if (~KEY[1])
		begin
			drawScreen = 6'b000001;
			xcounter = 6'b000000;
			ycounter = 6'b000000;
		end
		
		if (~KEY[2])
		begin
			drawScreen = 6'b000001;
			xcounter = 6'b000000;
			ycounter = 6'b000000;
			colour_in1 = 3'b000;
			colour_in2 = 3'b000;
			xin = xin_prev2;
			yin = yin_prev2;
		end
		
		if (~KEY[3])
		begin
			drawScreen = 6'b000001;
			xcounter = 6'b000000;
			ycounter = 6'b000000;
			colour_in1 = 3'b000;
			colour_in2 = 3'b000;
			xin = xin_prev1;
			yin = yin_prev1;
		end
		
		// ### FIRST ### color = 011 is background
		
		if (SW[17]) // top row most left
		begin
			xin = 8'b00000111; //card coordinates
			yin = 7'b0000110;
			colour_in1 = 3'b001;
			colour_in2 = 3'b010;
			if (isFlipped ==  2'b00)
			begin
				xin_prev1 = xin;
				yin_prev1 = yin;
			end
			if (isFlipped ==  2'b01)
			begin
				xin_prev2 = xin;
				yin_prev2 = yin;
				isFlipped =  2'b00;
			end
		end
		
		if (SW[16])
		begin
			xin = 8'b00100001; //card coordinates
			yin = 7'b0000110;
			colour_in1 = 3'b011;
			colour_in2 = 3'b100;
			if (isFlipped ==  2'b00)
			begin
				xin_prev1 = xin;
				yin_prev1 = yin;
			end
			if (isFlipped ==  2'b01)
			begin
				xin_prev2 = xin;
				yin_prev2 = yin;
				isFlipped =  2'b00;
			end
		end
		
		if (SW[15])
		begin
			xin = 8'b00111011; //card coordinates
			yin = 7'b0000110;
			colour_in1 = 3'b010;
			colour_in2 = 3'b011;
			if (isFlipped ==  2'b00)
			begin
				xin_prev1 = xin;
				yin_prev1 = yin;
			end
			if (isFlipped ==  2'b01)
			begin
				xin_prev2 = xin;
				yin_prev2 = yin;
				isFlipped =  2'b00;
			end
		end
		
		if (SW[14])
		begin
			xin = 8'b01010101; //card coordinates
			yin = 7'b0000110;
			colour_in1 = 3'b010;
			colour_in2 = 3'b111;
		end
		
		if (SW[13])
		begin
			xin = 8'b01101111; //card coordinates
			yin = 7'b0000110;
			colour_in1 = 3'b111;
			colour_in2 = 3'b100;
		end
		
		if (SW[12]) // top row most right
		begin
			xin = 8'b10001001; //card coordinates
			yin = 7'b0000110;
			colour_in1 = 3'b101;
			colour_in2 = 3'b001;
		end
		
		// #### SECOND ROW ### b0101101

		if (SW[11]) // second row most left
		begin
			xin = 8'b00000111; //card coordinates
			yin = 7'b0101101;
			colour_in1 = 3'b101;
			colour_in2 = 3'b001;
		end
		
		if (SW[10])
		begin
			xin = 8'b00100001; //card coordinates
			yin = 7'b0101101;
			colour_in1 = 3'b001;
			colour_in2 = 3'b010;
		end
		
		if (SW[9])
		begin
			xin = 8'b00111011; //card coordinates
			yin = 7'b0101101;
			colour_in1 = 3'b100;
			colour_in2 = 3'b101;
		end
		
		if (SW[8])
		begin
			xin = 8'b01010101; //card coordinates
			yin = 7'b0101101;
			colour_in1 = 3'b101;
			colour_in2 = 3'b111;
		end
		
		if (SW[7])
		begin
			xin = 8'b01101111; //card coordinates
			yin = 7'b0101101;
			colour_in1 = 3'b100;
			colour_in2 = 3'b101;
		end
		
		if (SW[6]) // second row most right
		begin
			xin = 8'b10001001; //card coordinates
			yin = 7'b0101101;
			colour_in1 = 3'b100;
			colour_in2 = 3'b001;
		end
		
		// #### THIRD ROW ###b1010101

		if (SW[5]) // third row most left
		begin
			xin = 8'b00000111; //card coordinates
			yin = 7'b1010011;
			colour_in1 = 3'b101;
			colour_in2 = 3'b111;
		end
		
		if (SW[4])
		begin
			xin = 8'b00100001; //card coordinates
			yin = 7'b1010011;
			colour_in1 = 3'b010;
			colour_in2 = 3'b011;
		end
		
		if (SW[3])
		begin
			xin = 8'b00111011; //card coordinates
			yin = 7'b1010011;
			colour_in1 = 3'b010;
			colour_in2 = 3'b111;
		end
		
		if (SW[2])
		begin
			xin = 8'b01010101; //card coordinates
			yin = 7'b1010011;
			colour_in1 = 3'b111;
			colour_in2 = 3'b100;
		end
		
		if (SW[1])
		begin
			xin = 8'b01101111; //card coordinates
			yin = 7'b1010011;
			colour_in1 = 3'b100;
			colour_in2 = 3'b001;
		end
		
		if (SW[0]) // third row most right
		begin
			xin = 8'b10001001; //card coordinates
			yin = 7'b1010011;
			colour_in1 = 3'b011;
			colour_in2 = 3'b100;
		end
		
	end // state_table
	
	assign colour = colour_in;
	assign x = xin + xcounter;
	assign y = yin + ycounter;
	assign writeEn = drawScreen;
	// Instansiate datapath
	// datapath d0(...);

   // Instansiate FSM control
   // control c0(...);
    
endmodule
