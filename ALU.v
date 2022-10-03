`include "64_bit_xor.v"
`include "64_bit_and.v"
`include "subtractor_64.v"
`include "adder_64.v"
`include "adder_16.v"
`include "prop_gen.v"
`include "grey.v"
`include "black.v"
`include "mux_2.v"
`include "mux_4.v"


module ALU(A, B, s, Out);

    input [63:0] A, B;
    input [3:0] s;
    output [63:0] Out;

    // Adder
    wire [63:0] Add;
    adder_64 A1(.A(A), .B(B), .Out(Add));

    // Subtractor
    wire [63:0] Subtract;
    subtractor_64 S1(.A(A), .B(B), .Out(Subtract));

    // And
    wire [63:0] And;
    full_and An1(.a(A), .b(B), .o(And));

    // Xor
    wire [63:0] Xor;
    full_xor X1(.a(A), .b(B), .o(Xor));

    genvar i;
    for (i = 0; i < 64; i = i+1) begin

        mux_4 M(.in0(Add[i]), .in1(Subtract[i]), .in2(And[i]), .in3(Xor[i]), .s0(s[0]), .s1(s[1]), .out(Out[i]));
    end

endmodule

