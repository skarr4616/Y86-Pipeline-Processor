module full_xor (input [63:0] a,b, output [63:0] o);
    
    genvar i;
    for (i = 0; i < 64; i = i+1) begin

       xor (o[i], a[i], b[i]);
    end

endmodule