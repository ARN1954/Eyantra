`timescale 1 ns/1 ns

// No Teams are allowed to edit this file.
module tb;

reg clk_50MHz;

wire clk_1MHz;
reg exp_clk_out_1;
reg error_clk_1;

wire clk_500Hz;
reg exp_clk_out_2;
reg error_clk_2;

reg [3:0] pulse_width;
wire pwm_signal;
reg exp_pwm_out;
reg error_pwm;
integer error_count;
reg [2:0] i;
integer fw;

t1a_fs_pwm_bdf uut (
    .clk_50MHz(clk_50MHz), .pulse_width(pulse_width),
    .clk_500Hz(clk_500Hz), .pwm_signal(pwm_signal),
    .clk_1MHz(clk_1MHz)
);

initial begin
    exp_clk_out_1 = 0; error_clk_1 = 0; exp_pwm_out = 1; error_pwm = 0; i = 0; pulse_width = 8;
    exp_clk_out_2 = 0; error_clk_2 = 0; error_count = 0; clk_50MHz = 0;  fw = 0;
end

always begin
    clk_50MHz = ~clk_50MHz; #10;
end

always @(posedge clk_50MHz) begin
    exp_clk_out_1 <= ~exp_clk_out_1; #500;
end

always @(posedge clk_50MHz) begin
    exp_clk_out_2 <= ~exp_clk_out_2; #1000000;
end

always @(posedge clk_50MHz) begin
	pulse_width[3:0] = 4'd08; i = 0; #2000000;
	pulse_width[3:0] = 4'd11; i = 1; #2000000;
    pulse_width[3:0] = 4'd04; i = 2; #2000000;
	pulse_width[3:0] = 4'd12; i = 3; #2000000;
	pulse_width[3:0] = 4'd04; i = 4; #2000000;
	pulse_width[3:0] = 4'd05; i = 5; #2000000;
	pulse_width[3:0] = 4'd09; i = 6; #2000000;
	pulse_width[3:0] = 4'd13; i = 7; #2000000;
end

always @(posedge clk_50MHz) begin
	exp_pwm_out <= 1; #(pulse_width*100000);
	exp_pwm_out <= 0; #((20-pulse_width)*100000);
end

always @(clk_50MHz) begin
    #1;
    if (exp_pwm_out !== pwm_signal) begin
        error_pwm <= 1; error_count = error_count + 1'b1;
    end
    else begin
        error_pwm <= 0;
    end
    if (exp_clk_out_1 !== clk_1MHz) begin
        error_clk_1 <= 1; error_count = error_count + 1'b1;
    end
    else begin
        error_clk_1 <= 0;
    end
    if (exp_clk_out_2 !== clk_500Hz) begin
        error_clk_2 <= 1; error_count = error_count + 1'b1;
    end
    else begin
        error_clk_2 <= 0;
    end
    if (i == 7) begin
        if (error_count !== 0) begin
            fw = $fopen("results.txt","w");
            $fdisplay(fw, "%02h","Errors");
            $display("Error(s) encountered, please check your design!");
            $fclose(fw);
        end
        else begin
            fw = $fopen("results.txt","w");
            $fdisplay(fw, "%02h","No Errors");
            $display("No errors encountered, congratulations!");
            $fclose(fw);
        end
        i = 0;
    end
end

endmodule
