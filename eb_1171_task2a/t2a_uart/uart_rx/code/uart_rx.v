// EcoMender Bot : Task 2A - UART Receiver
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.

This file is used to receive UART Rx data packet from receiver line and then update the rx_msg and rx_complete data lines.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

/*
Module UART Receiver

Baudrate: 230400 

Input:  clk_3125 - 3125 KHz clock
        rx      - UART Receiver

Output: rx_msg - received input message of 8-bit width
        rx_parity - received parity bit
        rx_complete - successful uart packet processed signal
*/

// module declaration
module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
    );

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

initial begin
    rx_msg = 0;
	 rx_parity = 0;
    rx_complete = 0;
end

// Add your code here....
localparam start=2'b00;
localparam data_bit=2'b01;
localparam parity=2'b10;
localparam stop=2'b11;

reg [1:0] state=start;
reg [2:0] bit_index =7;
reg [7:0] data_buffer=0;
reg [4:0] counter =0;
reg parity_bit=0;
reg pb;
reg pb_flag=0;
reg rx_sync1,rx_sync2;


always @(posedge clk_3125) begin
    rx_sync1 = rx;
    rx_sync2 = rx_sync1;
end

always @(*)begin
	if(pb_flag==1) begin
		pb = (data_buffer[7] ^ data_buffer[6] ^ data_buffer[5] ^ data_buffer[4] ^data_buffer[3] ^
		      data_buffer[2] ^ data_buffer[1] ^ data_buffer[0]);
	end

end

always @(posedge clk_3125)begin
		case(state)
			start:begin
		   if(rx_sync2 == 0)begin			 
				rx_complete=0;
				counter=counter+1'b1;
               if(data_buffer == 0) begin				
					if(counter==14)begin
						state=data_bit;
						counter =0;
					end
					end
					else
					if(counter==14)begin
						state=data_bit;
						counter =0;
					end
				end
			 else rx_complete=0;        				
			
			end				
			data_bit:begin
			data_buffer[bit_index]=rx_sync2;
			counter=counter+1'b1;
			if(counter == 14)begin
				counter=0;
				if(bit_index==0)begin
					state=parity;
					bit_index=7;
					counter=0;
				end
				else bit_index=bit_index-1'b1;				
			end
			end
			
			parity:begin			
			counter=counter+1'b1;
			parity_bit=pb;
			pb_flag=1;
					if(counter==14)begin
						state=stop;
						counter = 0;
						pb_flag=0;
					end				
			end
			
			stop:begin
			counter=counter+1'b1;
			if(counter == 14 )begin
				state=start;
				counter=0;            				
	         rx_msg=data_buffer;
				rx_parity=parity_bit;
	         rx_complete=1;			
			end
			end
		
		endcase

end








//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////


endmodule

