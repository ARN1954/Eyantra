`timescale 1ns/1ps

module tb;
reg clk_3125 = 1;
reg [7:0] data = 0;
reg parity_type = 0;    // even parity.
reg parity_bit = 0;

reg tx_start = 0;

wire tx;
reg tx_exp = 1;
wire tx_err;

wire tx_done;
reg tx_done_exp = 0;
wire tx_done_err;

integer r = 0, i = 0,k = 0,j = 0,y = 0,x = 0,err = 0;
integer fd = 0,fw = 0;

reg [10:0] data_packet = 0;
reg [99:0] file_data = 0;
reg [(10*8)-1:0] str = 0;
reg [7:0] rev_msg = 0;
reg [7:0] msg = 0;
reg flag = 0;
reg [7:0] cnt = 0;

assign #(1,1) tx_err = tx ^ tx_exp;
assign #(1,1) tx_done_err = tx_done ^ tx_done_exp;

// module instance.
uart_tx uut(.clk_3125(clk_3125),.parity_type(parity_type),.tx_start(tx_start),.data(data),.tx_done(tx_done),.tx(tx));

// 3.125MHz clock
always begin
    clk_3125 = ~clk_3125; #160;
end

initial begin
    fd = $fopen("data.txt","r");
    while(! $feof(fd)) begin
        if($fgets(str,fd)) begin
            if(str != 0) begin
                file_data[i] = str[15:8] - 48;
            end
            i = i + 1;
            msg = file_data[(10*k+1)+:8];
        end
    end
    $fclose(fd);
end

// parity_bit calculation.
always @(msg,parity_type) begin
    case(parity_type)
            1'b0: parity_bit = (^msg);       // even parity
            1'b1: parity_bit = ~(^msg);      // odd parity
    endcase
end

task reverse(input [7:0]in, output [7:0] out);
  begin
    for(r = 0; r < 8; r = r + 1) begin
      out[r] = in[7-r];
    end
  end
endtask

// sending data.
task send_data(input [7:0] msg,input parity_bit);
    begin
    data_packet = {1'b1,parity_bit,msg,1'b0};   // stop-parity-data-start;
    for(x = 0; x < 11; x = x + 1) begin
        tx_exp = data_packet[x];
        repeat(13) begin
        @(posedge clk_3125);
        end
        flag = 1;
        @(posedge clk_3125);    // 13 + 1 = 14;
        flag = 0;
    end
    end
endtask

initial begin
    tx_done_exp = 0;
    for(y = 0; y < 10; y = y + 1) begin
        tx_start = 1;
        msg = file_data[(10*k+1) +: 8];
        reverse(msg,data);
        @(posedge clk_3125);
        tx_start = 0;
        send_data(msg,parity_bit);
        k = k + 1;
        @(posedge clk_3125);
    end
end

always @(flag) begin
    cnt = cnt + 1;
    if(cnt == 23) cnt = 1;
end

always @(cnt) begin
    if(cnt == 22) tx_done_exp = 1;
    else tx_done_exp = 0;
end

// check on both edges
always@(clk_3125) begin
    if(tx !== tx_exp) err = err + 1;
end

always @(posedge clk_3125) begin
    if(k == i/10) begin
        if(err !== 0) begin
            fw = $fopen("results.txt", "w");
            $fdisplay(fw, "%02h", "Errors");
            $display("Error(s) encountered, please check your design!");
            $fclose(fw);
        end else begin
            fw = $fopen("results.txt", "w");
            $fdisplay(fw, "%02h", "No Errors");
            $display("No errors encountered, congratulations!");
            $fclose(fw);
            $stop();
        end
    end
end

endmodule

