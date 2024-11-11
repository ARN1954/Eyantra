// EcoMender Bot : Task 2A - UART Transmitter
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.

This file is used to generate UART Tx data packet to transmit the messages based on the input data.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

/*
Module UART Transmitter

Input:  clk_3125 - 3125 KHz clock
        parity_type - even(0)/odd(1) parity type
        tx_start - signal to start the communication.
        data    - 8-bit data line to transmit

Output: tx      - UART Transmission Line
        tx_done - message transmitted flag
*/

// module declaration
module uart_tx(
    input clk_3125,
    input parity_type,tx_start,
    input [7:0] data,
    output reg tx, tx_done
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

initial begin
    tx = 1;
    tx_done = 0;
end

// Add your code here...

localparam start=2'b00;
localparam data_bits=2'b01;
localparam parity=2'b10;
localparam stop=2'b11;

reg[3:0] counter=0;
reg [2:0] state=start;
reg [2:0] bit_index =7;
reg start_flag;
reg par;

always @(*) begin
	par=(data[7] ^ data[6] ^ data[5] ^ data[4] ^ 
                  data[3] ^ data[2] ^ data[1] ^ data[0]);

end

always @(posedge clk_3125) begin
	if(tx_start || start_flag) begin
	start_flag = 1;	
		case(state)			
			start:begin            			
				tx=0;
				counter=counter+1'b1;
					if(counter == 14) begin
						state = data_bits;
						counter = 0 ;
				end
			end
				
			data_bits:begin
				tx = data[bit_index];				
				counter = counter + 1'b1;
					if(counter == 14) begin
						counter = 0;						
						if(bit_index == 0) begin
							state = parity;
							bit_index = 7;						
						end
						else bit_index = bit_index - 1'b1;					
					end
			end
			
			parity:begin
				tx = par;
				counter=counter+1'b1;
					if(counter == 14) begin
						state = stop;
						counter = 0 ;
				end
			end
				
			stop:begin
				tx = 1'b1;
				counter=counter+1'b1;
					if(counter == 14) begin
						state = start;
						counter = 0 ;
						tx_done = 1;
						start_flag=0;
				end
			end		
		endcase
   end
	else tx_done = 0;
       

end



//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule

