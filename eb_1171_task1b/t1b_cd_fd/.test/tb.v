`timescale 1 ns/1 ns

// Teams are not allowed to edit this file.
module tb;

reg clk_1MHz, cs_out;

wire [1:0] filter;
reg [1:0] exp_filter;

wire [1:0] color;
reg [1:0] exp_color;

integer error_count;
reg [2:0] i, j;
integer fw;
integer tp, k, l, m, counter;

t1b_cd_fd uut (
    .clk_1MHz(clk_1MHz), .cs_out(cs_out),
    .filter(filter), .color(color)
);

initial begin
    clk_1MHz = 0; exp_filter = 2; fw = 0;
    exp_color = 0; error_count = 0; i = 0;
    cs_out = 1; tp = 0; k = 0; j = 0; l = 0; m = 0;
end

always begin
    clk_1MHz = ~clk_1MHz; #500;
end

always @(posedge clk_1MHz) begin
    // exp_filter = 2; #1000;
    m = (i%3) + 1;
    exp_filter = 3; #500000;
    exp_filter = 0; #500000;
    exp_filter = 1; #500000;
    exp_filter = 2; exp_color = (i%3) + 1;
    i = i + 1'b1; m = m + 1'b1; #1000;
end

always begin
    for (j=0; j<6; j=j+1) begin
        #1000;
        for (l = 0; l < 3; l=l+1) begin
            case(exp_filter)
                0: begin
                    if (m == 1) tp = 10;
                    else tp = 16;
                end
                1: begin
                    if (m == 3) tp = 8;
                    else tp = 18;
                end
                3: begin
                    if (m == 2) tp = 12;
                    else tp = 19;
                end
                default: tp = 17;
            endcase
            counter = 500000/(2*tp);
            for (k = 0; k < counter; k=k+1) begin
                cs_out = 1; #tp;
                cs_out = 0; #tp;
            end
            #(500000-(counter*2*tp));
        end
        #1000;
    end
end

always @(clk_1MHz) begin
    #1;
    if (filter !== exp_filter) error_count = error_count + 1'b1;
    if (color !== exp_color) error_count = error_count + 1'b1;

    if (i == 6) begin
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
