module full_and (input [63:0] a,b, output [63:0] o);
    
    genvar i;
    for (i = 0; i < 64; i = i+1) begin

       and(o[i], a[i], b[i]);
    end

endmodule