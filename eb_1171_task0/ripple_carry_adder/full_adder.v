module full_adder(
     input a,b,c_in,
	  output sum,c_out
	  );
assign sum=((a^b)^c_in);
assign c_out=((a&b)|((a^b)&c_in));
endmodule
