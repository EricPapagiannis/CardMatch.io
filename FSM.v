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
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn; 

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
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
	wire card1, card2;
    wire [5:0] tc1, tc2;
    // Instansiate datapath
	 datapath d0(.clk(CLOCK_50),
    .resetn(KEY[0]),
    .TEMP_match(SW[5:0]),
    .card1(card1), 
	.card2(card2), 
    .output_X(x), 
	.output_Y(y),
	.match_the_card(writeEn),
	.card_chosen_1(tc1),
	.card_chosen_2(tc2),
	.data_result_colour(colour),
	.LEDS(LEDR)
	);

    // Instansiate FSM control
     FSM c0(.clk(CLOCK_50),
    .resetn(KEY[0]),
    .go(KEY[3]),
	 .matching(1'b1),
	.match_the_cards(writeEn),
   .card1(card1), 
	.card2(card2)
	);
 
    FSM_Players p0(.clk(CLOCK_50),
    .resetn(KEY[0]),
    .go(out),
   .player(player)
	);

    FSM_Joystick j0(.clk(CLOCK_50),
    .resetn(KEY[0]),
    .go(SW[17:14]),
   .can_move(can_move)
	);

	// NEED A DATAPATH FOR THE JOYSTICK COORDINATE - send coordinate into FSM_cards


   wire can_move;
   reg out;
   wire [1:0] player;
	always@(posedge CLOCK_50)
	begin
		if (tc1 == tc2)
		begin
			out <= 1'b1;
		end
		else
		begin
			out <= 1'b0;
		end
	end
	assign LEDG[1:0] = player;
	assign LEDR[17] = out;
endmodule

/*module FSM_Cards(
    input clk,
    input resetn,
    input go,
    input matching, // Used to determine if the fsm is in the matching state; if so dont do anything until it is finished
    //output reg writeEn,
    //output reg  ld_x, ld_y
    output reg  is_match
    );

    reg [6:0] current_state, next_state; 
    
    localparam  card0        = 4'd1,
		card1        = 4'd2,
		card2        = 4'd3,
		card3        = 4'd4,
		card4        = 4'd5,
		card5        = 4'd6,
		card6        = 4'd7,
		card7        = 4'd8,
		card8        = 4'd1,
		card9        = 4'd2,
		card10       = 4'd3,
		card11       = 4'd4,
		card12       = 4'd5,
		card13       = 4'd6,
		card14       = 4'd7,
		card15       = 4'd8,
		card16       = 4'd9,
		card17       = 4'd9;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)

		//State for Init
		//State for choose card 1
		//State for choose card 2
		//State for match
		//State for no match
					 
                card0: next_state = go ? choose_card1_wait : choose_card1; // Loop in current state until value is input
				
                choose_card1_wait: next_state = go ? choose_card1_wait : choose_card2; // Loop in current state until go signal goes low
				
                choose_card2: next_state = go ? choose_card2_wait : choose_card2; // Loop in current state until value is input
				
                choose_card2_wait: next_state = go ? choose_card2_wait : check_match; // Loop in current state until go signal goes low
				
                check_match: next_state = go ? check_match_wait : check_match; // Loop in current state until value is input
					 
		check_match_wait: next_state = go ? check_match_wait : choose_card1; // Loop in ent state until value is input
				
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
            choose_card2: begin
                card2 = 1'b1;
                end
            check_match: begin
                match_the_cards = 1'b1;
                end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
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
endmodule*/

module FSM_Joystick(
    input clk,
    input resetn,
    input [0:3] go,
    input matching, // Used to determine if the fsm is in the matching state; if so dont do anything until it is finished
    //output reg writeEn,
    //output reg  ld_x, ld_y
    output reg  can_move
    );

    reg [6:0] current_state, next_state; 
    
    localparam  idle        	= 4'd0,
                move   		= 4'd1,
                waitMove        = 4'd2;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)

		//State for Init
		//State for choose card 1
		//State for choose card 2
		//State for match
		//State for no match
					 
                idle: next_state = go > 1'b0 ? move : idle; // Loop in current state until value is input
				
                move: next_state = go > 1'b0 ? waitMove : move; // Loop in current state until go signal goes low
				
                waitMove: next_state = go > 1'b0 ? waitMove : idle; // Loop in current state until go signal goes low
				
                default:     next_state = idle;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        can_move = 1'b0;

        case (current_state)
            idle: begin
                //card1 = 1'b1;
                end
            move: begin
                can_move = 1'b1;
                end
            waitMove: begin
                //match_the_cards = 1'b1;
                end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= idle;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module FSM_Players(
    input clk,
    input resetn,
    input go,
    //output reg writeEn,
    //output reg  ld_x, ld_y
    output reg [1:0] player
    );

    reg [6:0] current_state, next_state; 
    
    localparam  Player1        = 4'd0,
                Player2        = 4'd1;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)

		//State for Init
		//State for choose card 1
		//State for choose card 2
		//State for match
		//State for no match
					 
                Player1: next_state = go ? Player1 : Player2; // Loop in current state until value is input
				
                Player2: next_state = go ? Player2 : Player1; // Loop in current state until go signal goes low
				
                default:     next_state = Player1;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
	reg player = 2'b00;

        case (current_state)
            Player1: begin
                player = 2'b01;
                end
            Player2: begin
                player = 2'b10;
                end
        // default:    // don't need 	assign LEDS[17:11] = TEMP_match; default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
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
		choose_card2_wait   = 4'd4,
                check_match 	    = 4'd3,
	        check_match_wait    = 4'd5;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)

		//State for Init
		//State for choose card 1
		//State for choose card 2
		//State for match   reg out;
		//State for no match
					 
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
            choose_card2: begin
                card2 = 1'b1;
                end
            check_match: begin
                match_the_cards = 1'b1;
                end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
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
    input [5:0] TEMP_match,
    input card1, card2,
	 input match_the_card,
	 output [16:0] LEDS,
    output [7:0] output_X, 
	output [6:0] output_Y,
	output [5:0] card_chosen_1, card_chosen_2,
	output reg [2:0] data_result_colour
    );
    reg [5:0] otp = 6'b000000;
	 reg [5:0] c1;
	 reg [5:0] c2;
	 //always@(posedge clk)
	 always@(*)
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

			end
			else if (card1)
			begin
				otp <= 6'b000001;
				c1 <= TEMP_match;
			end
			else if (card2)
			begin
				otp <= 6'b10000;
				c2 <= TEMP_match;
			end
			
		end
	end
	assign LEDS[16:11] = TEMP_match; // used to see what cards we're fliped
	assign LEDS[5:0] = otp;
	assign card_chosen_1 = c1;
	assign card_chosen_2 = c2;
	/*output reg [7:0] output_X; 
	output reg [6:0] output_Y;
	
    // input registers
    reg [7:0] x;
	reg [6:0] y;
	reg [2:0] c;

    // Registers a, b, c, x with respective input logic
    always@(posedge clk) begin
        if(!resetn) begin
            x <= 7'b0; 
            y <= 6'b0; 
            c <= 3'b0; 
        end
        else begin
            if(ld_x)
                x <= {1'b0, data_in};
            if(ld_y)
                y <= data_in;
            if(1'b1)
                c <= colour_in;
        end
    end
	
	reg [3:0] counter;output_Y
	always@(posedge clk) begin
		if(!resetn) 
			begin
				output_X <= 7'b0;
				output_Y <= 6'b0;
				data_result_colour <= 3'b0;  
			end
        else 
            output_X <= x;
			output_Y <= y;
			data_result_colour <= c;
			
        if(!resetn) 
			begin
				counter <= 4'b00; 
			end 
		else 
			begin
			if (counter == 4'b1111)
				counter <= 4'b0000;
			else
				counter <= counter + 1'b1;
				output_X <= x + counter[1:0];
				output_Y <= y + counter[3:2];
			end
	end
	
	assign output_X_f = output_X;
	assign output_X_f = output_X;*/

endmodule
