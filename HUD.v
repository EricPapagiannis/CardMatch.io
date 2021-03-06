`timescale 1ns / 1ns // `timescale time_unit/time_precision

module FinalB58(KEY, SW, EXT_IO, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);
    //GPIO inputs (Will change upon pin assignment)
    input [3:0] EXT_IO;


    
    //Outputs for Hexes
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
    //Outputs for joystick testing	
    output [3:0] LEDR;
    wire [3:0] q;
    //Instatiate the scores for P1 and P2
    SevenSegDecoder my_display1(HEX0, 4'b0000);
    SevenSegDecoder my_display2(HEX1, 4'b0000);
    //Set P1 as the first person to make a move (Exclude HEX5 since default is P)
    SevenSegDecoder my_display3(HEX4, 4'b0001);
    //Set the timer default as 15
    SevenSegDecoder my_display4(HEX2, 4'b1111);
    SevenSegDecoder_High my_display5(HEX3, 4'b1111);
    //Instatiate winner as P1 (Exclude HEX5 since default is P)
    SevenSegDecoder my_display6(HEX6, 4'b0001);

    //Assign the LEDRs to respond to GPIO joystick inputs
    JoystickTester tester1(.inputs(EXT_IO),
	 .outputs(q)
    );
	 
    assign LEDR[3:0] = q;


    input [17:0] SW;
    reg enable;//used to enable the timer when the rate divider is finished counting down from 50 million
    input CLOCK_50;//clk for rate divider and timer
    wire [27:0] outRD2;//output for the rate divider, triggers enable when == 0
    wire [3:0] outDC;//timer output, this will go to the hexes for display
	
    RateDivider rd2(.enable(1'b1), //Will always be enabled, timer does not stop
		    .reset_n(SW[17]),//reset for both this and the output timer is SW17. if held on, will stop at 50 million
		    .clock(CLOCK_50),//50mhz clk
		    .q(outRD2),//output that will determine if the timer can go down 1 second
		    .d(28'b0010111110101111000001111111), //50 million - 1
		    .ParLoad(SW[16])//when flipped, will immediately reset to 50 million since that is the d value constant
    );
	
    DisplayCounter dc(.enable(enable),//Counter that will count in seconds down from 15
			  .reset_n(SW[17]),//Same reset as rate divider, will reset to 15
			  .clock(CLOCK_50),//50mhz clk
			  .q(outDC)//output that will be fed to hexes
    );
	//Always block that will check if the rate divider reaches 0, if so enable the timer to decrement one value.
	always @(*)
	begin
		case(SW[0])
			1'b0: enable = (outRD2 == 28'b0000000000000000000000000000) ? 1'b1 : 1'b0;
			default: enable = 1'b0;
	    endcase
	end
        
	SevenSegDecoder my_display7(HEX2, outDC[3:0]);//Display least significant bit of timer on hex2
	SevenSegDecoder_High my_display8(HEX3, outDC[3:0]);//Display highest significant bit of timer on hex3
	    

	input [1:0] KEY;//the keys that will increment the score
	wire [3:0] p1ScoreCounter;//the wire that connects the score counter the hexes for player 1
	wire [3:0] p2ScoreCounter;//the wire that connects the score counter the hexes for player 2
	
    ScoreCounter p1Score(.enable(1'b1), //score counter for player 1, always enabled since we have a controlled clock
			 .reset_n(SW[16]),//switch 16 will set the score to 0
			 .clock(KEY[0]),//the key that will increment the score
			 .q(p1ScoreCounter)//the output that will be fed to the hexes
    );

    
    ScoreCounter p2Score(.enable(1'b1),//score counter for player 2; always enabled since we have a controlled clock
			 .reset_n(SW[15]),//switch 15 will set the score to 0
	  		 .clock(KEY[1]),//the key that will increment the score
			 .q(p2ScoreCounter)//the output that will be fed to the hexes
    );

	SevenSegDecoder my_display9(HEX0, p1ScoreCounter[3:0]);//player 1 score hex output
	SevenSegDecoder my_display10(HEX1, p2ScoreCounter[3:0]);//player 2 score hex output




endmodule
/*
Since the output will be in decimal and not in hex, this module will represent the least significant bit of a number.
For example, when fed (12) it will output (2), when fed (8) it will output (8)
*/
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
	//For digits above 10, display the least significant bit
        4'd10: hex_out = 7'b1000000;
        4'd11: hex_out = 7'b1111001;
        4'd12: hex_out = 7'b0100100;
        4'd13: hex_out = 7'b0110000;
        4'd14: hex_out = 7'b0011001;
        4'd15: hex_out = 7'b0010010;
	//Set the default as the letter P for displaying players
        default: hex_out = 7'b0001100;
    endcase
endmodule
/*
Since the output will be in decimal and not in hex, this module will represent the highest significant bit of a 2 bit number number.
For example, when fed (12) it will output (1), when fed (8) it will output (0)
*/
module SevenSegDecoder_High(hex_out, inputs);
    output reg [6:0] hex_out;
    input [3:0] inputs;
    always @(inputs)
        case (inputs)
	//Display 0 for all values lower than 10
        4'h0: hex_out = 7'b1000000;
        4'h1: hex_out = 7'b1000000;
        4'h2: hex_out = 7'b1000000;
        4'h3: hex_out = 7'b1000000;
        4'h4: hex_out = 7'b1000000;
        4'h5: hex_out = 7'b1000000;
        4'h6: hex_out = 7'b1000000;
        4'h7: hex_out = 7'b1000000;
        4'h8: hex_out = 7'b1000000;
        4'h9: hex_out = 7'b1000000;
	//For digits above 10, display 1
        4'd10: hex_out = 7'b1111001;
        4'd11: hex_out = 7'b1111001;
        4'd12: hex_out = 7'b1111001;
        4'd13: hex_out = 7'b1111001;
        4'd14: hex_out = 7'b1111001;
        4'd15: hex_out = 7'b1111001;
	//Set the default as the letter P for displaying players
        default: hex_out = 7'b0001100;
    endcase
endmodule

module JoystickTester(inputs, outputs);
    output reg [3:0] outputs;
    input [3:0] inputs;
    always @(inputs)
	case(inputs)
	     4'h1: outputs[0] = 1'b1;
        4'h2: outputs[1] = 1'b1;
        4'h3: outputs[2] = 1'b1;
        4'h4: outputs[3] = 1'b1;
	default: outputs[3:0] = 4'b0000;
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



module DisplayCounter(enable, reset_n, clock, q);
	output reg [3:0] q; // declare q
	input clock, enable, reset_n;
	always @(posedge clock) // triggered every time clock rises
		begin
			if (reset_n == 1'b1) // when reset is high
				q <= 4'b1111; // q is set to 15
			else if (enable == 1'b1) // when enabled
				q <= q - 1'b1; // count down 1
			else if (enable == 1'b0) // hold when not enabled
				q <= q;
			else if (q == 1'b0)//once it reaches 0, reset to 15
				q <= 4'b1111;
		end
endmodule

module ScoreCounter(enable, reset_n, clock, q);
	output reg [3:0] q; // declare q
	input clock, enable, reset_n;
	always @(posedge clock) // triggered every time clock rises
		begin
			if (reset_n == 1'b1) // when reset is high
				q <= 1'b0; // q is set to 0
			else if (enable == 1'b1) //when enabled
				q <= q + 1'b1; // increment q
			else if (enable == 1'b0) // hold when not enabled
				q <= q;
			else if (q == 4'b1001)//if it reaches 9
				q <= 1'b0;//reset to 0
	end
endmodule
