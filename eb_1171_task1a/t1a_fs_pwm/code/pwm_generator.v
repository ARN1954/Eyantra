// EcoMender Bot : Task 1A : PWM Generator
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design a module which will scale down the 100KHz Clock Frequency to 500Hz and perform Pulse Width Modulation on it.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//PWM Generator
//Inputs : clk_1MHz, pulse_width
//Output : clk_500Hz, pwm_signal

module pwm_generator(
    input clk_1MHz,
    input [3:0] pulse_width,
    output reg clk_500Hz, pwm_signal
);

initial begin
    clk_500Hz = 0; pwm_signal = 1;
end

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

/*
Add your logic here
*/
reg[9:0] counter=0;
reg[4:0] pwm_counter=0;
reg[6:0] counter2=0;
always @ (posedge clk_1MHz)begin
    if (!counter) begin
	 clk_500Hz = ~clk_500Hz;	 
	 end	 
    counter = counter + 1'b1; 
	 if(counter==10'b1111101000) counter=0;
	  if(pwm_counter < pulse_width)pwm_signal =1;	  
	  else pwm_signal = 0;	 
	  counter2=counter2 +1'b1;
	  if(counter2 == 7'b1100100)begin
	  pwm_counter=pwm_counter +1'b1;
	  if(pwm_counter == 5'b10100)pwm_counter =0;	 
	  counter2 =0;
	  end
	 
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule
