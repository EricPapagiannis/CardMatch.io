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
	wire writeEn; 

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	
			
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
    .output_X(x),
	.output_Y(y),
	.match_the_card(writeEn),
	.card_chosen_1(tc1),
	.card_chosen_2(tc2),
	.data_result_colour(colour),
	.LEDS(LEDR[9:0]),
	.is_correct(splayer)
	);
	assign LEDG[1:0] = splayer;
    // Instansiate FSM control
     FSM c0(.clk(CLOCK_50),
    .resetn(KEY[0]),
    .go(~KEY[3]), // try with low
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

module FSM_Players(
    input clk,
    input resetn,
    input go,
	input writeEn,
    //output reg writeEn,
    //output reg  ld_x, ld_y
    output reg [1:0] player
    );

    reg [6:0] current_state, next_state; 
    
    localparam  Player1        = 4'd0,
                Player2        = 4'd1;
    
    // Next state logic aka our state table
    always@(negedge go) // Change to * if doesnt work
    begin: state_table
            case (current_state)

		//State for Init
		//State for choose card 1~
		//State for choose card 2
		//State for match
		//State for no match
					 
                Player1: next_state = go && writeEn ? Player1 : Player2; // Loop in current state until value is input
					 
					 //Player1W : next_state = go ? Player1W : Player2;
				
                Player2: next_state = go && writeEn ? Player2 : Player1; // Loop in current state until go signal goes low
					 
					 //Player2W : next_state = go ? Player2W : Player1;
				
                default:     next_state = Player1;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
	player = 2'b00;

        case (current_state)
            Player1: begin
                player = 2'b01;
                end
            Player2: begin
                player = 2'b10;
                end
					
        // default:    // don't need 	assign LEDS[17:11] = TEMP_match; default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signalsnegedge
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs	   
        if(!resetn)
            current_state <= Player1;
        else
            current_state <= next_state;
    end // state_FFS
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
    output [7:0] output_X, 
	output [6:0] output_Y,
	output [17:0] card_chosen_1,
	output [17:0] card_chosen_2,
	output reg [2:0] data_result_colour,
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
 