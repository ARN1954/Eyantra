// EcoMender Bot : Task 1B : Color Detection using State Machines
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design a module which will detect colors red, green, and blue using state machine and frequency detection.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//Color Detection
//Inputs : clk_1MHz, cs_out
//Output : filter, color

// Module Declaration
module t1b_cd_fd (
    input  clk_1MHz, cs_out,
    output reg [1:0] filter, color
);

// red   -> color = 1;
// green -> color = 2;
// blue  -> color = 3;

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

initial begin // editing this initial block is allowed
    filter = 2; color = 0;
end

/*
Add your logic here
*/
reg[10:0] counter=0;
reg[15:0] pulse=0;
reg[15:0] max=0;
reg[1:0] f_c=2;

always @ (posedge clk_1MHz)begin
    
    if(counter <500)begin
	 filter = 3;	 	 
	 end
	 
	 if(counter >= 500 && counter <1000)begin
	 filter = 0;	 	 
	 end
	 
	 if(counter >= 1000 && counter <1500)begin
	 filter = 1;	 	  
	 end
	 
	 if(counter==1500)begin
    color = f_c;	 	 
	 filter=2;
	 end	 
	 
    if(counter == 1501)begin
	 filter = 3;
	 counter=0;	 
	 end
	 
	 counter = counter +1'b1;
end

always @ (posedge cs_out)begin

	
	if(counter == 499) begin
		if(pulse > max) begin
			max=pulse;
			f_c=2;
			pulse=0;
		end
	end
	
	
	if(counter == 999) begin 
		if(pulse > max) begin
			max=pulse;
			f_c=1;
		end
		pulse=0;
	end
	
	
	if(counter == 1499) begin
		if(pulse > max) begin
			max=pulse;
			f_c=3;
		end
	pulse=0;
	end
	
	if(filter == 2) begin
	pulse =0;
	max=0;
	f_c=2;
	end
	
	pulse = pulse + 1'b1;
	
	
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule
