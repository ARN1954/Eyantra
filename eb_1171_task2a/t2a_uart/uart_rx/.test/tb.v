`timescale 1ns/1ps

module tb;

reg clk_3125 = 0, rx;
wire [7:0] rx_msg;
reg  [7:0] rx_exp = 0;
wire rx_parity;
reg correct_parity = 0;
wire rx_complete;
reg  exp_rx_complete = 0;

integer err = 0;
reg [109:0] data = 0;
reg [7:0] msg = 0;

integer i = 0, j = 0, k = 0,p = 0, fd = 0, fw = 0, s = 0, f = 0;
integer counter = 0;
reg [(10*11)-1:0] str; //10 chars can be stored
reg flag = 0;

uart_rx uut(.clk_3125(clk_3125), .rx(rx), .rx_msg(rx_msg), .rx_parity(rx_parity), .rx_complete(rx_complete));

always begin
	clk_3125 = ~clk_3125; #160;
end

initial begin
	fd = $fopen("data.txt", "r");
	while(! $feof(fd)) begin
		$fgets(str, fd);
		if(str != 0) begin
			data[i] = str[15:8] - 48;
		end
		i = i + 1;
	end
	$fclose(fd);
end

initial begin
	@(negedge clk_3125);
	rx_exp = 0;
	repeat(154) begin @(posedge clk_3125); end
	for(k = 0; k < 11; k = k+1) begin
		msg = data[(11*k+1) + : 9];
		rx_exp = {<<{msg[7:0]}};
		correct_parity = (^rx_exp)?1'b1:1'b0;
		repeat(154) begin @(posedge clk_3125); end
		s = s + 1;
	end
end

initial begin
	fd = $fopen("data.txt", "r");
	while(! $feof(fd)) begin
    if($fgets(str, fd)) begin
        if(str != 0) begin
            rx = str[15:8] - 48;
    end
		repeat(14) begin @(posedge clk_3125); end
        end
        rx = 1'b0;
	end
	$fclose(fd);
end

always @(posedge clk_3125) begin
	exp_rx_complete = 1'b0;
	if(s >= (i-1)/10) begin
		exp_rx_complete = 1'b0;
	end else begin
		if(counter == 154) begin
			exp_rx_complete = 1'b1;
			counter = 0;
		end
		counter <= counter + 1;
	end
end

always @(posedge exp_rx_complete) begin
  if(p <= 9) begin
    p <= p + 1;
    if((rx_parity !== correct_parity)) begin
		  $display("rx_msg: %c,exp_msg:%c,rx_parity:%b,correct_parity:%b",rx_msg,8'h3F,rx_parity,correct_parity);
	  end else begin
		  $display("rx_msg: %c,exp_msg:%c,rx_parity:%b,correct_parity:%b",rx_msg,rx_exp,rx_parity,correct_parity);
	  end
  end else p <= 0;
end

always @(clk_3125) begin
	if(p >= 10) begin
		flag = 1;
	end else begin
		flag = 0;
	end
end

always @(clk_3125) begin
	#1;
	if (rx_parity === correct_parity) begin
		if(rx_msg !== rx_exp)
		 err = err + 1;
	end
	if (rx_parity !== correct_parity) begin
		if(rx_msg !== 'h3F)
		 err = err + 1; 
	end
	if (rx_complete !== exp_rx_complete) err = err + 1'b1;
end

always @(clk_3125) begin
    if (p == (((i-1)/10)) || (flag == 1)) begin
        if (err !== 0) begin
            fw = $fopen("results.txt","w");
            $fdisplay(fw, "%02h","Errors");
            repeat (125) begin @(posedge clk_3125); end
			$display("Error(s) encountered, please check your design!");
            $fclose(fw);
			$stop();
        end
        else begin
            fw = $fopen("results.txt","w");
            $fdisplay(fw, "%02h","No Errors");
            repeat (125) begin @(posedge clk_3125); end
            $display("No errors encountered, congratulations!");
            $fclose(fw);
            $stop();
        end
    end
end

endmodule

