

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
	reg [2:0] colour_in;
	reg [2:0] colour_in1;
	reg [2:0] colour_in2;
	
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
		defparam VGA.BACKGROUND_IMAGE = "image.colour2.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require
	always@(posedge SW[0])
	begin
		xin = 8'b00000111; //card coordinates
		yin = 7'b0000111;
		ycounter = 6'b000000;
		xcounter = 6'b000000;
		drawScreen = 6'b000001;
		colour_in1 = 3'b110;
		colour_in2 = 3'b101;
	end
	always@(negedge SW[0])
	begin
		xin = 8'b00000111; //card coordinates
		yin = 7'b0000111;
		ycounter = 6'b000000;
		xcounter = 6'b000000;
		drawScreen = 6'b000001;
		colour_in1 = 3'b111;
		colour_in2 = 3'b101;
	end
	// 22x32 card dimensions
	always@(posedge CLOCK_50)
	begin
		if (ycounter < 6'b100000)
		begin
			xcounter = xcounter + 6'b000001;
			if (xcounter >= 6'b010110)
			begin
				xcounter = 6'b000000;
				ycounter = ycounter + 6'b000001;
				if (ycounter == 6'b100000)
				begin
					drawScreen = 6'b000000;
				end
			end		
		end
		else
		begin
			drawScreen = 6'b000000;
		end
		if (xcounter < 6'b001011)
		begin
		    colour_in = colour_in1;
		end
		else
		begin
		    if (xcounter == 6'b001011)
			begin
				colour_in = 3'b000;
			end
			else
			begin
		        colour_in = colour_in2;
		    end
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

