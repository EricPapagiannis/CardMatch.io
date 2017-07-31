// Part 2 skeleton

module project
	(
		CLOCK_50,						//	On Board 50 MHz
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
		LEDG,
		HEX0,
		HEX2,
		HEX4,
		HEX5,
		HEX6,
		HEX7
	);
	input CLOCK_50;	// 50 MHz
	input [17:0] SW;
	input [3:0] KEY;
	output [6:0] HEX0, HEX2, HEX4, HEX5, HEX6, HEX7;
	// Do not change the following outputs
	output VGA_CLK;   	// VGA Clock
	output VGA_HS;		// VGA H_SYNC
	output VGA_VS;		// VGA V_SYNC
	output VGA_BLANK_N;	// VGA BLANK
	output VGA_SYNC_N;	// VGA SYNC
	output [9:0] VGA_R;   	// VGA Red[9:0]
	output [9:0] VGA_G;	// VGA Green[9:0]
	output [9:0] VGA_B;   	// VGA Blue[9:0]
	output [17:0] LEDR;
	output [7:0] LEDG;
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and  wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn_vga;
	wire writeEn; // Used to determine if in the matching state or not
	
	vga_in my_vga_in(.switches(SW[17:0]), .keys(KEY[3:0]), .clk(CLOCK_50), .x(x), .y(y), .colour(colour), .writeEn(writeEn_vga));

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	
	vga_adapter VGA(.resetn(resetn),
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
	
	wire card1, card2; // wire representing which to read (NOT WHICH CARDS HAVE BEEN CHOSEN)
    	wire [17:0] tc1; // Represents the first card chosen
	wire [17:0] tc2; // Represents the second card chosen
	wire [1:0] splayer; // Represents which players turn it is
    	// Instansiate datapath
	datapath d0(.clk(CLOCK_50),
	.resetn(KEY[0]),
	.cardVal(SW[17:0]), // The 18 switches each repre one of the 18 cards
	.card1(card1), 
	.card2(card2),
	.cc1(tc1),
	.cc2(tc2),
	.Key(KEY[1]),
	.ply(splayer),
	.match_the_card(writeEn), // An indicator to trigger the matching state to see if 2 cards are the same
	.card_chosen_1(tc1),
	.card_chosen_2(tc2),
	.LEDS(LEDR[9:0]), // LEDS used to represent which state the FSM is currently in
	.is_correct(splayer),
	.isMatch(m) //Represents whether the 2 cards were a match
	);
	
     	FSM c0(.clk(CLOCK_50),
	.resetn(KEY[0]),
	.go(~KEY[1]),
	.match_the_cards(writeEn),
	.card1(card1), 
	.card2(card2)
	);
	
	assign LEDG[1:0] = splayer; // Assigns the green LEDS to indicate which player it is (LED0 and LED1 off means P1; both on means P2)
	ScoreCounterP1 SCP1 (m, KEY[0], KEY[1], p1ScoreCounter, splayer); // A Counter to keep track of the scores for Player 1
	ScoreCounterP2 SCP2 (m, KEY[0], KEY[1], p2ScoreCounter, splayer); // A counter to keep track of the scores for Player 2
	wire [3:0] p1ScoreCounter;//the wire that connects the score counter the hexes for player 1
	wire [3:0] p2ScoreCounter;//the wire that connects the score counter the hexes for player 2
	wire m;
	SevenSegDecoder mydisplay9(HEX2, p1ScoreCounter[3:0]);//player 1 score hex output
	SevenSegDecoder mydisplay10(HEX0, p2ScoreCounter[3:0]);//player 2 score hex output

	reg enable, parload;
	wire [7:0] outDC;
	wire [27:0] outRD2;
	
	RateDivider rd2(.enable(1'b1), //Will always be enabled, timer does not stop
	.reset_n(1'b1),//reset for both this and the output timer is SW17. if held on, will stop at 50 million
	.clock(CLOCK_50),//50mhz clk
	.q(outRD2),//output that will determine if the timer can go down 1 second
	.d(28'b0010111110101111000001111111), //50 million - 1
	.ParLoad(1'b0)//when flipped, will immediately reset to 50 million since that is the d value constant
	);
	
        DisplayCounter dc(.enable(enable),//Counter that will count in seconds down from 15
	.reset_n(KEY[0]),//Same reset as rate divider, will reset to 15
	.clock(CLOCK_50),//50mhz clk
	.val(outDC),//output that will be fed to hexes
	.d(8'b11111111),// Represents FF in HEX
	.ParLoad(parload)
        );
	
	SevenSegDecoder_Timer my_display7(HEX4, outDC[3:0]);//Display least significant bit of timer on hex2
	SevenSegDecoder_Timer my_display8(HEX5, outDC[7:4]);//Display highest significant bit of timer on hex3
	
	reg leadEnable;
	wire [3:0] outLead;
	DisplayLead(.enable(1'b1), //Enabler that will trigger when timer reaches 0
	.score1(p1ScoreCounter[3:0]), //Input player 1 current score
	.score2(p2ScoreCounter[3:0]), //Input player 2 current score
	.lead(outLead) //Output for the current leader that will be sent to hexes
	);
	
	reg won;
	reg flashEnable;
	wire [4:0] pFlashOut, leadFlashOut;
	//EndState es(outDC, p1ScoreCounter[3:0], p2ScoreCounter[3:0], won);
	Flasher flash(.p(4'hA),
	.lead(outLead[3:0]),
	.load(4'hB),
	.enable(flashEnable),
	.pFlash(pFlashOut),
	.leadFlash(leadFlashOut)
	);
	SevenSegDecoder mydisplay11(HEX7, pFlashOut);
	SevenSegDecoder my_display9(HEX6, leadFlashOut);//Display the lead on hex 6
	
	//Always block that will check if the rate divider reaches 0, if so enable the timer to decrement one value.
	//Always block that will enable the lead display to change only when the timer reaches 0
	reg haswon;
	initial haswon = 1'b0;
	always @(*)
	begin
		leadEnable <= 1'b1;
		//Conditions for timer
		if (outRD2 == 28'b0000000000000000000000000000)
		begin
			enable <= 1'b1;
			flashEnable <= ~flashEnable ;
		end
		else
		begin
			enable <= 1'b0;
		end
		//Conditions for lead display
		if (outDC == 8'b00000000)
		begin
			leadEnable <= 1'b1;
			parload <= 1'b1;
		end
		else
		begin
			//leadEnable <= 1'b0;
			parload <= 1'b0;
		end
		if (outDC == 8'b11111111)
		begin
			//leadEnable <= 1'b1;
			parload <= 1'b1;
		end
		else
		begin
			//leadEnable <= 1'b0;
			parload <= 1'b0;
		end
	end
endmodule

module EndState(
	input [7:0] timer,
	input [3:0] score1,
	input [3:0] score2,
	output reg won
);
	reg [3:0] scoreT;
	always@(*)
	begin

	scoreT <= score1 + score2;
		if (timer == 8'b00000001)
			begin
				won <= 1'b1; 
			end
		else
			begin 
				won <= 1'b0;
			end
	end	
	
endmodule

module Flasher(
	input [3:0] p,
	input [3:0] lead,
	input [3:0] load,
	input enable,
	output reg [3:0] pFlash,
	output reg [3:0] leadFlash
	);
	
	always @(*)
	begin
		if (enable == 1'b1)
			begin
				pFlash <= load;
				leadFlash <=load;
			end
		else
			begin
				pFlash <= p;
				leadFlash <= lead;
			end
	end
endmodule

module FSM(
    input clk,
    input resetn,
    input go,
    output reg match_the_cards,
    output reg  card1, card2
    );

    reg [6:0] current_state, next_state; 
    
    localparam  choose_card1        = 4'd0,
                choose_card1_wait   = 4'd1,
                choose_card2        = 4'd2,
				choose_card2_wait   = 4'd3,
                check_match 	    = 4'd4,
				check_match_wait    = 4'd5;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)
					 
                choose_card1: next_state = go ? choose_card1_wait : choose_card1; // Choose card 1 state
				
                choose_card1_wait: next_state = go ? choose_card1_wait : choose_card2; // Choose card 1 wait state; Goes to choose card 2
				
                choose_card2: next_state = go ? choose_card2_wait : choose_card2; // Choose card 2 state
				
                choose_card2_wait: next_state = go ? choose_card2_wait : check_match; // Choose card 1 wait state; Goes to check match state
				
                check_match: next_state = go ? check_match_wait : check_match; // Check matching state
					 
					 check_match_wait: next_state = go ? check_match_wait : choose_card1; // Check matching wait state; goes to choose card 1 state
				
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
				match_the_cards = 1'b1;
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
    input [17:0] cardVal,
    input card1, card2, 
	 input [17:0] cc1, 
	 input [17:0] cc2,
	 input [1:0] ply,
	 input Key,
	 input match_the_card,
	 output [9:0] LEDS,
	output [17:0] card_chosen_1,
	output [17:0] card_chosen_2,
	output reg [1:0] is_correct,
	output isMatch
    );
     reg [5:0] otp = 6'b000000;
	 reg [17:0] c1; // Register for the first card chosen
	 reg [17:0] c2; // Register for the second card chosen
	 reg mat; // Whether or not a matching set was attained
	 always@(posedge clk)
	 begin
		if (!resetn)
		begin
			otp <= 6'b000000; // Inistal state of LEDS
		end
		else
		begin
			mat <= 1'b0;
			if (match_the_card)
			begin
				otp <= 6'b111111; // Indicates that the player is in the matching state
				if ((cc1[17] == 1'b1) && (cc2[10] == 1'b1)||
					 (cc2[17] == 1'b1) && (cc1[10] == 1'b1)||
					 (cc1[16] == 1'b1) && (cc2[0] == 1'b1)||
					 (cc2[16] == 1'b1) && (cc1[0] == 1'b1)|| 
					 (cc1[15] == 1'b1) && (cc2[4] == 1'b1)|| 
					 (cc2[15] == 1'b1) && (cc1[4] == 1'b1)||
					 (cc1[14] == 1'b1) && (cc2[3] == 1'b1)|| 
					 (cc2[14] == 1'b1) && (cc1[3] == 1'b1)|| 
					 (cc1[13] == 1'b1) && (cc2[2] == 1'b1)|| 
					 (cc2[13] == 1'b1) && (cc1[2] == 1'b1)||
					 (cc1[12] == 1'b1) && (cc2[11] == 1'b1)|| 
					 (cc2[12] == 1'b1) && (cc1[11] == 1'b1)|| 
					 (cc1[9] == 1'b1) && (cc2[7] == 1'b1)|| 
					 (cc2[9] == 1'b1) && (cc1[7] == 1'b1)|| 
					 (cc1[8] == 1'b1) && (cc2[5] == 1'b1)|| 
					 (cc2[8] == 1'b1) && (cc1[5] == 1'b1)|| 
					 (cc1[6] == 1'b1) && (cc2[1] == 1'b1)||
					 (cc2[6] == 1'b1) && (cc1[1] == 1'b1)) // Card combinations
				begin
					mat <= 1'b1;
					is_correct <= ply;
					c1 <= 18'b111111111111111110; // Set both cards to dummy values so the datapath does not loop in this sate while matching state it active (LEDS would constantly if this werent here)
					c2 <= 18'b111111111111111110;					
				end
				else if (cc1 == 18'b111111111111111110&& cc2 == 18'b111111111111111110)
				begin
					otp <= 6'b101001; // Dummy state on match so that the score does not constatnly increment and LEDS for players dont flicker
					mat <= 1'b1;
					
				end
				else if (cc1 != 18'b000000000000000000&& cc2 != 18'b000000000000000000)
				begin
					otp <= 6'b100001;
					mat <= 1'b0;
					is_correct <= ~ply;
					c1 <= 18'b000000000000000000; // Set both cards to dummy values so the datapath does not loop in this sate while matching state it active (LEDS would constantly if this werent here)
					c2 <= 18'b000000000000000000;

				end

			end
			else if (card1) // Load the first card
			begin
				otp <= 6'b000001;
				c1 <= cardVal;
				 			
			end
			else if (card2) // Load the second card
			begin
				otp <= 6'b10000;
				c2 <= cardVal;
			end
			
		end
	end
	assign LEDS[5:0] = otp;
	assign LEDS[9] = mat;
	assign card_chosen_1 = c1;
	assign card_chosen_2 = c2;
	assign isMatch = mat;

endmodule

module vga_in(switches, keys, clk, x, y, colour, writeEn);
	
	input [17:0] switches;
	input [3:0] keys;
	input	clk;
	output [2:0] colour;
	output [7:0] x;
	output [6:0] y;
	output writeEn;
	reg [5:0] x_pos_count = 6'b000000;
	reg [5:0] y_pos_count = 6'b100000;
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
			
			
			
			
			// Cards to be drawn. Each with unique (xin, yin) coordinates.
			// If ~keys[2], then flip the card back over (change colour_in1 and colour_in2 to black)
			// Otherwise, assign the respective colours of the card
			
			// ### FIRST ### color = 011 is background
			// Card 17
			if (switches[17]) // top row most left
			begin
				xin = 8'b00000111; //card coordinatescardDrawn = 1'b1;
				yin = 7'b0000110;
				
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b001;
					colour_in2 = 3'b010;
				end
			end
			// Card 17
			if (switches[16])
			begin
				xin = 8'b00100001; //card coordinates
				yin = 7'b0000110;
				
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b011;
					colour_in2 = 3'b100;
				end
			end
			
			// Card 15
			if (switches[15])
			begin
				xin = 8'b00111011; //card coordinates
				yin = 7'b0000110;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b010;
					colour_in2 = 3'b011;
				end
			end
			// Card 14
			if (switches[14])
			begin
				xin = 8'b01010101; //card coordinates
				yin = 7'b0000110;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b010;
					colour_in2 = 3'b111;
				end
			end
			// Card 13
			if (switches[13])
			begin
				xin = 8'b01101111; //card coordinates
				yin = 7'b0000110;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b111;
					colour_in2 = 3'b100;
				end
			end
			// Card 12
			if (switches[12]) // top row most right
			begin
				xin = 8'b10001001; //card coordinates
				yin = 7'b0000110;

				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
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
			// Card 11
			if (switches[11]) // second row most left
			begin
				xin = 8'b00000111; //card coordinates
				yin = 7'b0101101;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b101;
					colour_in2 = 3'b001;
				end
			end
			// Card 10
			if (switches[10])
			begin
				xin = 8'b00100001; //card coordinates
				yin = 7'b0101101;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b001;
					colour_in2 = 3'b010;
				end
			end
			// Card 9
			if (switches[9])
			begin
				xin = 8'b00111011; //card coordinates
				yin = 7'b0101101;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b100;
					colour_in2 = 3'b101;
				end
			end
			// Card 8
			if (switches[8])
			begin
				xin = 8'b01010101; //card coordinates
				yin = 7'b0101101;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b101;
					colour_in2 = 3'b111;
				end
			end
			// Card 7
			if (switches[7])
			begin
				xin = 8'b01101111; //card coordinates
				yin = 7'b0101101;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b100;
					colour_in2 = 3'b101;
				end
			end
			// Card 6
			if (switches[6]) // second row most right
			begin
				xin = 8'b10001001; //card coordinates
				yin = 7'b0101101;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b100;
					colour_in2 = 3'b001;
				end
			end
			
			// #### THIRD ROW ###
			// Card 5
			if (switches[5]) // third row most left
			begin
				xin = 8'b00000111; //card coordinates
				yin = 7'b1010011;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b101;
					colour_in2 = 3'b111;
				end
			end
			// Card 4
			if (switches[4])
			begin
				xin = 8'b00100001; //card coordinates
				yin = 7'b1010011;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b010;
					colour_in2 = 3'b011;
				end
			end
			// Card 3
			if (switches[3])
			begin
				xin = 8'b00111011; //card coordinates
				yin = 7'b1010011;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b010;
					colour_in2 = 3'b111;
				end
			end
			// Card 2
			if (switches[2])
			begin
				xin = 8'b01010101; //card coordinates
				yin = 7'b1010011;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b111;
					colour_in2 = 3'b100;
				end
			end
			// Card 1
			if (switches[1])
			begin
				xin = 8'b01101111; //card coordinates
				yin = 7'b1010011;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b100;
					colour_in2 = 3'b001;
				end
			end
			// Card 0
			if (switches[0]) // third row most right
			begin
				xin = 8'b10001001; //card coordinates
				yin = 7'b1010011;
				
				if (~keys[2])
				begin
					drawScreen = 6'b000001;
					x_pos_count = 6'b000000;
					y_pos_count = 6'b000000;
					colour_in1 = 3'b000;
					colour_in2 = 3'b000;
				end
				else
				begin
					colour_in1 = 3'b011;
					colour_in2 = 3'b100;
				end
			end
			
			cardDrawn = 1'b0;
			colour_in = colour_in1;
			// Draw a 18x28 rectangular card, but halfway through the x, change colour_in from
			// colour_in1 to colour_in2. This design choice was to implement having > 8 pairs of cards
			// because the VGA adapter only has 8 colours, so we split the cards in two colours to enable
			// Having more pairs.
			if (y_pos_count < 6'b011100)
			begin
				x_pos_count = x_pos_count + 6'b000001;
				
				if (x_pos_count >= 6'b010010)
				begin
					x_pos_count = 6'b000000;
					y_pos_count = y_pos_count + 6'b000001;
					
					if (y_pos_count == 6'b011100)
					begin
						drawScreen = 6'b000000;
					end
				
				end
					
				if (x_pos_count >= 6'b001001)
				begin
				cardDrawn = 1'b1;
					 colour_in = colour_in2;
				end
				
			end
			else
			begin
				
				drawScreen = 6'b000000;
			end
			// Draw the card
			if (~keys[1])
			begin
				drawScreen = 6'b000001;
				x_pos_count = 6'b000000;
				y_pos_count = 6'b000000;

			end
			
		end // state_table
	
		// Assign the vga colour to be drawn what was decided to be colour_in from the always block
		assign colour = colour_in;
		// Increment both counters, starting from the (xin, yin) coordinates
		assign x = xin + x_pos_count;
		assign y = yin + y_pos_count;
		// Assigning when to draw or not
		assign writeEn = drawScreen;
		
endmodule

module ScoreCounterP1(enable, reset_n, clock, q, player);
	output reg [3:0] q; // declare q
	input clock, enable, reset_n;
	input [1:0] player;
	always @(posedge clock) // triggered every time clock rises
		begin
			if (reset_n == 1'b0) // when reset is high
				q <= 1'b0; // q is set to 0
			else if (enable == 1'b1 && ~player[0]) //when enabled
				q <= q + 1'b1; // increment q
			else if (enable == 1'b0) // hold when not enabled
				q <= q;
			else if (q == 4'b1001)//if it reaches 9
				q <= 1'b0;//reset to 0
	end
endmodule

module ScoreCounterP2(enable, reset_n, clock, q, player);
	output reg [3:0] q; // declare q
	input clock, enable, reset_n;
	input [1:0] player;
	always @(posedge clock) // triggered every time clock rises
		begin
			if (reset_n == 1'b0) // when reset is high
				q <= 1'b0; // q is set to 0
			else if (enable == 1'b1 && player[0]) //when enabled
				q <= q + 1'b1; // increment q
			else if (enable == 1'b0) // hold when not enabled
				q <= q;
			else if (q == 4'b1001)//if it reaches 9
				q <= 1'b0;//reset to 0
	end
endmodule

module SevenSegDecoder_Timer(hex_out, inputs);
    output reg [6:0] hex_out;
    input [3:0] inputs;
    always @(inputs)
        case (inputs)
        4'h0: hex_out = 7'b1000000;
        4'h1: hex_out = 7'b1111001;
        4'h2: hex_out = 7'b0100100;
        4'h3: hex_out = 7'b0110000;
        4'h4: hex_out = 7'b0011001;
        4'h5: hex_out = 7'b0010010;
        4'h6: hex_out = 7'b0000010;
        4'h7: hex_out = 7'b1111000;
        4'h8: hex_out = 7'b0000000;
        4'h9: hex_out = 7'b0011000;
        4'hA: hex_out = 7'b0001000;
        4'hB: hex_out = 7'b0000011;
        4'hC: hex_out = 7'b1000110;
        4'hD: hex_out = 7'b0100001;
        4'hE: hex_out = 7'b0000110;
        4'hF: hex_out = 7'b0001110;
        default: hex_out = 7'b0001100;
	//For digits above 10, display the least significant bit
	//Set the default as the letter P for displaying players
    endcase
endmodule


module SevenSegDecoder(hex_out, inputs);
    output reg [6:0] hex_out;
    input [3:0] inputs;
    always @(inputs)
        case (inputs)
        4'h0: hex_out = 7'b1000000;
        4'h1: hex_out = 7'b1111001;
        4'h2: hex_out = 7'b0100100;
        4'h3: hex_out = 7'b0110000;
        4'h4: hex_out = 7'b0011001;
        4'h5: hex_out = 7'b0010010;
        4'h6: hex_out = 7'b0000010;
        4'h7: hex_out = 7'b1111000;
        4'h8: hex_out = 7'b0000000;
        4'h9: hex_out = 7'b0011000;
        4'hA: hex_out = 7'b0001100;//P value
        4'hB: hex_out = 7'b1111111;//Flash value
        4'hC: hex_out = 7'b1000110;
        4'hD: hex_out = 7'b0100001;
        4'hE: hex_out = 7'b0000110;
        4'hF: hex_out = 7'b0001110;
        default: hex_out = 7'b0001100;
	//For digits above 10, display the least significant bit
	//Set the default as the letter P for displaying players
    endcase
endmodule


module RateDivider(enable, reset_n, clock, q, d, ParLoad);
	output reg [27:0] q; // declare q
	input [27:0] d; // declare d
	input clock, enable, reset_n, ParLoad;
	always @(posedge clock) // triggered every time clock rises
		begin
		if (reset_n == 1'b0) // when Clear b is 0
			q <= 0; // q is set to 0
		else if (ParLoad == 1'b1) // Check if parallel load
			q <= d; // load d
		else if (q == 28'b0000000000000000000000000000) // when q is the minimum value for the counter
			q <= d; // q reset back to its original value
		else if (enable == 1'b1) // increment q only when Enable is 1
			//q <= q + 1'b1; // increment q
			q <= q - 1'b1; // decrement q
		else if (enable == 1'b0)
			q <= q; 
	end
endmodule


module DisplayCounter(enable, reset_n, clock, val, d, ParLoad);
	output reg [7:0] val; // declare q
	input clock, enable, reset_n, ParLoad;
	input [7:0] d;
	always @(posedge clock) // triggered every time clock rises
		begin
			if (reset_n == 1'b0) // when reset is high
				val <= 8'b11111111; // q is set to 15
			else if (enable == 1'b1) // when enabled
				val <= val - 1'b1; // count down 1
			else if (ParLoad == 1'b1) // Check if parallel load
				val <= d;
			else if (enable == 1'b0) // hold when not enabled
				val <= val;
			else if (val == 8'b00000000)//once it reaches 0, reset to 15
				val <= 8'b11111111;
		end
endmodule

module DisplayLead(enable, score1, score2, lead);
	output reg [3:0] lead; //declare the lead
	input enable;
	input [3:0] score1, score2;
	always @(enable)
		begin
			if (score1 > score2) //If player1 is in the lead
				lead <= 4'b0001;// Set the output to be 1
			else if (score2 > score1) //If player2 is in the lead
				lead <= 4'b0010; //Set the output to be 2
			else // If there is a tie
				lead <= 4'b0000; //Set the output to be 0
		end
	endmodule
	
