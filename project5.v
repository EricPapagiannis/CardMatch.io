// Part 2 skeleton

module FinalB58
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
		VGA_B,   						//	VGA Blue[9:0]
		LEDR,
		LEDG
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
	output [17:0] LEDR;
	output [7:0] LEDG;
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and  wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn_vga;
	wire writeEn;
	
	vga_in my_vga_in(.switches(SW[17:0]), .keys(KEY[3:0]), .clk(CLOCK_50), .x(x), .y(y), .colour(colour), .writeEn(writeEn_vga));

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn_vga),
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
	// for the VGA controller, in addition to any other functionality your design may require.
	wire card1, card2;
    wire [17:0] tc1;
	wire [17:0] tc2;
	 wire [1:0] player;
	 wire [1:0] splayer;
    // Instansiate datapath
	  datapath d0(.clk(CLOCK_50),
    .resetn(KEY[0]),
    .TEMP_match(SW[17:0]),
    .card1(card1), 
	.card2(card2),
	.cc1(tc1),
	.cc2(tc2),
	.ply(splayer),
	.match_the_card(writeEn),
	.card_chosen_1(tc1),
	.card_chosen_2(tc2),
	.LEDS(LEDR[9:0]),
	.is_correct(splayer)
	);
	assign LEDG[1:0] = splayer;
    // Instansiate FSM control
     FSM c0(.clk(CLOCK_50),
    .resetn(KEY[0]),
    .go(~KEY[1]), // try with low
	 .matching(1'b1),
	.match_the_cards(writeEn),
   .card1(card1), 
	.card2(card2)
);
 
    /*FSM_Players p0(.clk(CLOCK_50),
    .resetn(KEY[0]),
    .go(splayer),
	.writeEn(writeEn),
   .player(player)
	);*/

    /*FSM_Joystick j0(.clk(CLOCK_50),
    .resetn(KEY[0]),
    .go(SW[17:14]),
   .can_move(can_move)
	);*/

	// NEED A DATAPATH FOR THE JOYSTICK COORDINATE - send coordinate into FSM_cards


   wire can_move;
   reg out;
   //initial switch = 1'b1;
	
	/*always@(*)
	begin
		if (KEY[0])
		begin 
		switch <= 1'b0;
		end
	end*/
	
	/*always@(*)
	begin
		if (writeEn)
		begin
			if (tc1 == tc2)
				begin
					out <= 1'b1; 
					//switch <= switch;
				end
			else
				begin
					if (out == 1'b0)
					begin
						switch <= ~switch;
					end
					out <= 1'b0;
					
				end
		end
	end
	assign LEDG[0] = switch;
	assign LEDR[9] = out;*/
endmodule


module FSM(
    input clk,
    input resetn,
    input go,
    input matching, // Used to determine if the fsm is in the matching state; if so dont do anything until it is finished
    //output reg writeEn,
    output reg match_the_cards,
    //output reg  ld_x, ld_y
    output reg  card1, card2
    );

    reg [6:0] current_state, next_state; 
    
    localparam  choose_card1        = 4'd0,
                choose_card1_wait   = 4'd1,
                choose_card2        = 4'd2,
					 choose_card2_wait   = 4'd3,
                check_match 	    	= 4'd4,
					 check_match_wait    = 4'd5;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)

		//State for Init
		//State for choose card 1card1
		//State for choose card 2
		//State for match   reg out;
		//State for no m1'b0atch
					 
                choose_card1: next_state = go ? choose_card1_wait : choose_card1; // Loop in current state until value is input
				
                choose_card1_wait: next_state = go ? choose_card1_wait : choose_card2; // Loop in current state until go signal goes low
				
                choose_card2: next_state = go ? choose_card2_wait : choose_card2; // Loop in current state until value is input
				
                choose_card2_wait: next_state = go ? choose_card2_wait : check_match; // Loop in current state until go signal goes low
				
                check_match: next_state = go ? check_match_wait : check_match; // Loop in current state until value is input
					 
					 check_match_wait: next_state = go ? check_match_wait : choose_card1; // Loop in current state until value is input
				
                default:     next_state = choose_card1;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        card1 = 1'b0;
        card2 = 1'b0;
        match_the_cards = 1'b0;

        case (current_state)
            choose_card1: begin
                card1 = 1'b1;
                end
	        choose_card1_wait: begin
                card1 = 1'b1; // Draw the card in this state
                end
            choose_card2: begin
                card2 = 1'b1;
                end
			choose_card2_wait: begin
                card2 = 1'b1; // Draw the card in this state
                end
            check_match: begin
                match_the_cards = 1'b1;
                end
			check_match_wait : begin
				match_the_cards = 1'b1;//e
				end
        // default:  n  // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= choose_card1;
        else
            current_state <= next_state;
    end // state_FFS
endmodule


module datapath(
    input clk,
    input resetn,
    input [17:0] TEMP_match,
    input card1, card2, 
	 input [17:0] cc1, 
	 input [17:0] cc2,
	 input [1:0] ply,
	 input match_the_card,
	 output [9:0] LEDS,
	output [17:0] card_chosen_1,
	output [17:0] card_chosen_2,
	output reg [1:0] is_correct
    );
    reg [5:0] otp = 6'b000000;
	 reg [17:0] c1;
	 reg [17:0] c2;
	 reg mat;
	 always@(posedge clk)
	 begin
		if (!resetn)
		begin
			otp <= 6'b000000;
		end
		else
		begin
			if (match_the_card)
			begin
				otp <= 6'b111111;
				/*
				((cc1 == 18'b100000000000000000)&& (cc2 == 18'b000000001000000000)|| 
					 (cc1 == 18'b010000000000000000)&& (cc2 == 18'b000000000000000001)|| 
					 (cc1 == 18'b001000000000000000)&& (cc2 == 18'b000000000000010000)|| 
					 (cc1 == 18'b000100000000000000)&& (cc2 == 18'b000000000000001000)|| 
					 (cc1 == 18'b000010000000000000)&& (cc2 == 18'b000000000000000100)|| 
					 (cc1 == 18'b000001000000000000)&& (cc2 == 18'b000000100000000000)|| 
					 (cc1 == 18'b000000001000000000)&& (cc2 == 18'b000000000010000000)|| 
					 (cc1 == 18'b000000000100000000)&& (cc2 == 18'b000000000000100000)|| 
					 (cc1 == 18'b100000000010000000)&& (cc2 == 18'b000000000000000010))
				*/
				if ((cc1[17] == 1'b1) && (cc2[10] == 1'b1)|| 
					 (cc1[16] == 1'b1) && (cc2[0] == 1'b1)|| 
					 (cc1[15] == 1'b1) && (cc2[4] == 1'b1)|| 
					 (cc1[14] == 1'b1) && (cc2[3] == 1'b1)|| 
					 (cc1[13] == 1'b1) && (cc2[2] == 1'b1)|| 
					 (cc1[12] == 1'b1) && (cc2[11] == 1'b1)|| 
					 (cc1[9] == 1'b1) && (cc2[7] == 1'b1)|| 
					 (cc1[8] == 1'b1) && (cc2[5] == 1'b1)|| 
					 (cc1[6] == 1'b1) && (cc2[1] == 1'b1))
				begin
					mat <= 1'b1;
					is_correct <= ply;
					//otp <= 6'b101001;
				end
				else
				begin
					otp <= 6'b100001;
					mat <= 1'b0;
					is_correct <= ~ply;
					c2 <= 18'b100000000000000000;
					c1 <= 18'b000000010000000000;
				end

			end
			else if (card1)
			begin
				otp <= 6'b000001;
				c1 <= TEMP_match;
				
				//INSERT IF STATEMENTS HERE
				
			end
			else if (card2)
			begin
				otp <= 6'b10000;
				c2 <= TEMP_match;
			end
			
		end
	end
	//assign LEDS[16:11] = TEMP_match; // used to see what cards we're fliped
	assign LEDS[5:0] = otp;
	assign LEDS[9] = mat;
	assign card_chosen_1 = c1;
	assign card_chosen_2 = c2;

endmodule

module vga_in(switches, keys, clk, x, y, colour, writeEn);
	
	input [17:0] switches;
	input [3:0] keys;
	input	clk;
	output [2:0] colour;
	output [7:0] x;
	output [6:0] y;
	output writeEn;
	reg [5:0] xcounter = 6'b000000;
	reg [5:0] ycounter = 6'b100000;
	reg [7:0] xin;
	reg [6:0] yin;
	reg [2:0] colour_in;
	reg [2:0] colour_in1;
	reg [2:0] colour_in2;
	reg drawScreen = 1'b0;
	reg cardDrawn;
	reg countCard = 2'b00;


		always@(posedge clk)
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
				cardDrawn = 1'b1;
					 colour_in = colour_in2;
				end
				
			end
			else
			begin
				
				drawScreen = 6'b000000;
			end

			if (~keys[1])
			begin
				drawScreen = 6'b000001;
				xcounter = 6'b000000;
				ycounter = 6'b000000;

			end
			
			
			
			
			// ### FIRST ### color = 011 is background
			
			if (switches[17]) // top row most left
			begin
				xin = 8'b00000111; //card coordinatescardDrawn = 1'b1;
				yin = 7'b0000110;
				
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b001;
					colour_in2 = 3'b010;
				end
			end
			
			if (switches[16])
			begin
				xin = 8'b00100001; //card coordinates
				yin = 7'b0000110;
				
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b011;
					colour_in2 = 3'b100;
				end
			end
			
			
			if (switches[15])
			begin
				xin = 8'b00111011; //card coordinates
				yin = 7'b0000110;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b010;
					colour_in2 = 3'b011;
				end
			end
			
			if (switches[14])
			begin
				xin = 8'b01010101; //card coordinates
				yin = 7'b0000110;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b010;
					colour_in2 = 3'b111;
				end
			end
			
			if (switches[13])
			begin
				xin = 8'b01101111; //card coordinates
				yin = 7'b0000110;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b111;
					colour_in2 = 3'b100;
				end
			end
			
			if (switches[12]) // top row most right
			begin
				xin = 8'b10001001; //card coordinates
				yin = 7'b0000110;

				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b101;
					colour_in2 = 3'b001;
				end
			end
			
			// #### SECOND ROW ### b0101101

			if (switches[11]) // second row most left
			begin
				xin = 8'b00000111; //card coordinates
				yin = 7'b0101101;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b101;
					colour_in2 = 3'b001;
				end
			end
			
			if (switches[10])
			begin
				xin = 8'b00100001; //card coordinates
				yin = 7'b0101101;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b001;
					colour_in2 = 3'b010;
				end
			end
			
			if (switches[9])
			begin
				xin = 8'b00111011; //card coordinates
				yin = 7'b0101101;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b100;
					colour_in2 = 3'b101;
				end
			end
			
			if (switches[8])
			begin
				xin = 8'b01010101; //card coordinates
				yin = 7'b0101101;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b101;
					colour_in2 = 3'b111;
				end
			end
			
			if (switches[7])
			begin
				xin = 8'b01101111; //card coordinates
				yin = 7'b0101101;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b100;
					colour_in2 = 3'b101;
				end
			end
			
			if (switches[6]) // second row most right
			begin
				xin = 8'b10001001; //card coordinates
				yin = 7'b0101101;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b100;
					colour_in2 = 3'b001;
				end
			end
			
			// #### THIRD ROW ###b1010101

			if (switches[5]) // third row most left
			begin
				xin = 8'b00000111; //card coordinates
				yin = 7'b1010011;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b101;
					colour_in2 = 3'b111;
				end
			end
			
			if (switches[4])
			begin
				xin = 8'b00100001; //card coordinates
				yin = 7'b1010011;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b010;
					colour_in2 = 3'b011;
				end
			end
			
			if (switches[3])
			begin
				xin = 8'b00111011; //card coordinates
				yin = 7'b1010011;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b010;
					colour_in2 = 3'b111;
				end
			end
			
			if (switches[2])
			begin
				xin = 8'b01010101; //card coordinates
				yin = 7'b1010011;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b111;
					colour_in2 = 3'b100;
				end
			end
			
			if (switches[1])
			begin
				xin = 8'b01101111; //card coordinates
				yin = 7'b1010011;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b100;
					colour_in2 = 3'b001;
				end
			end
			
			if (switches[0]) // third row most right
			begin
				xin = 8'b10001001; //card coordinates
				yin = 7'b1010011;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					xcounter = 6'b000000;
					ycounter = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b011;
					colour_in2 = 3'b100;
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
