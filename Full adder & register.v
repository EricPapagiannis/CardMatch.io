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