module subtractor_64(A, B, Out);

        input [63:0] A;
        input [63:0] B;
        output [63:0] Out;

        wire zero = 0;
        wire one = 1;

        //Not Layer
        wire [63:0] B_not;
        
        genvar k;
        for (k = 0; k < 64; k = k+1) begin

            not (B_not[k], B[k]);
        end

        //Group 1;
        wire [16:0] W;

        adder_16 M1(.A(A[15:0]), .B(B_not[15:0]), .Cin(one), .O(W));

        assign Out[15:0] = W[15:0];

        //Group 2;
        wire [16:0] X0;
        wire [16:0] X1;

        adder_16 M2(.A(A[31:16]), .B(B_not[31:16]), .Cin(zero), .O(X0));
        adder_16 M3(.A(A[31:16]), .B(B_not[31:16]), .Cin(one), .O(X1));

        genvar i;
        for (i = 0; i < 16; i = i+1) begin

            mux_2 F(.in0(X0[i]), .in1(X1[i]), .s(W[16]), .out(Out[16+i]));
        end

        wire U1;
        mux_2 V1(.in0(X0[16]), .in1(X1[16]), .s(W[16]), .out(U1));

        //Group 3;
        wire [16:0] Y0;
        wire [16:0] Y1;

        adder_16 M4(.A(A[47:32]), .B(B_not[47:32]), .Cin(zero), .O(Y0));
        adder_16 M5(.A(A[47:32]), .B(B_not[47:32]), .Cin(one), .O(Y1));

        for (i = 0; i < 16; i = i+1) begin

            mux_2 G(.in0(Y0[i]), .in1(Y1[i]), .s(U1), .out(Out[32+i]));
        end

        wire U2;
        mux_2 V2(.in0(Y0[16]), .in1(Y1[16]), .s(U1), .out(U2));

        //Group 4
        wire [16:0] Z0;
        wire [16:0] Z1;

        adder_16 M6(.A(A[63:48]), .B(B_not[63:48]), .Cin(zero), .O(Z0));
        adder_16 M7(.A(A[63:48]), .B(B_not[63:48]), .Cin(one), .O(Z1));

        for (i = 0; i < 16; i = i+1) begin

            mux_2 G(.in0(Z0[i]), .in1(Z1[i]), .s(U2), .out(Out[48+i]));
        end

endmodule