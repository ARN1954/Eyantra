
// alu.v - ALU module

module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,       // operands
    input       [3:0] alu_ctrl,         // ALU control
    output reg  [WIDTH-1:0] alu_out,    // ALU output
    output      zero                    // zero flag
);

always @(a, b, alu_ctrl) begin
    case (alu_ctrl)
        4'b0000:  alu_out <= a + b;       // ADD
        4'b0001:  alu_out <= a + ~b + 1;  // SUB
        4'b0010:  alu_out <= a & b;       // AND
        4'b0011:  alu_out <= a | b;       // OR
		  4'b0100:  alu_out <= a ^ b;       // XOR
		  4'b0111:  alu_out <= a << b[4:0]; //sll 
		  4'b1000:  alu_out <= a >> b[4:0]; //srli
		  4'b1001:  alu_out <= $signed(a) >>> b[4:0]; //srai
        4'b0101:  begin                   // SLT
//                     if (a[31] != b[31]) alu_out <= a[31] ? 0 : 1;
//                     else alu_out <= a < b ? 1 : 0;
                       alu_out <= ($signed(a) < $signed(b)) ? 1 : 0; // Signed comparison

        
                 end
		  4'b0110: alu_out <= (a < b) ? 1 : 0;// Unsigned
        default: alu_out = 0;
    endcase
end

assign zero = (alu_out == 0) ? 1'b1 : 1'b0;

endmodule

