`timescale 1ns / 1ns // `timescale time_unit/time_precision

module HUD(GPIO, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);
    //GPIO inputs (Will change upon pin assignment)
    input [3:0] GPIO;
    //Outputs for Hexes
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
    //Outputs for joystick testing	
    output [3:0] LEDR;
    
    //Instatiate the scores for P1 and P2
    SevenSegDecoder my_display1(HEX0, 4'b0000);
    SevenSegDecoder my_display2(HEX1, 4'b0000);
    //Set P1 as the first person to make a move (Exclude HEX5 since default is P)
    SevenSegDecoder my_display3(HEX4, 4'b0001);
    //Set the timer default as 15
    SevenSegDecoder my_display4(HEX3, 4'b0001);
    SevenSegDecoder my_display5(HEX2, 4'b0101);
    //Instatiate winner as P1 (Exclude HEX5 since default is P)
    SevenSegDecoder my_display5(HEX6, 4'b0001);

    //Assign the LEDRs to respond to GPIO joystick inputs
    JoystickTester tester1(LEDR, GPIO);
    
    
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
	
	//Other Letters not needed
	/*
        4'hA: hex_out = 7'b0001000;
        4'hB: hex_out = 7'b0000011;
        4'hC: hex_out = 7'b1000110;
        4'hD: hex_out = 7'b0100001;
        4'hE: hex_out = 7'b0000110;
        4'hF: hex_out = 7'b0001110;
	*/

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
    assign LEDR = outputs;
endmodule
