//Will be used to add to scores upon matching cards
module full_adder (A, B, C_in, S, C_out);
  //Inputs for a 1 bit full adder
  input  A, B, C_in;
  //Outputs
  output S, C_out;
  //Wire connectors for the logic gates
  wire   w1, w2, w3;
  //Full adder logic gates
  assign w1 = A ^ B;
  assign w2 = w1 & C_in;
  assign w3 = A & B;
  //Assign sum and carry outputs
  assign S   = w1 ^ C_in;
  assign C_out = w2 | w3;
  
endmodule

//Memory used to store player scores
module register(d, reset_n, clock, q);
	//Inputs for a 1 bit register with reset
	input d, reset_n, clock;
	//Output
	output reg q;
	//Check for resets on posedge
	always @(posedge clock)
	begin
		if (reset_n == 1'b0)
			q <= 0;
		else
			q <= d;
	end
endmodule

//Used to display scores and timer
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
        4'hA: hex_out = 7'b0001000;
        4'hB: hex_out = 7'b0000011;
        4'hC: hex_out = 7'b1000110;
        4'hD: hex_out = 7'b0100001;
        4'hE: hex_out = 7'b0000110;
        4'hF: hex_out = 7'b0001110;
        default: hex_out = 7'b1111111;
    endcase
endmodule
