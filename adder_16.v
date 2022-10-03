module adder_16(A, B, Cin, O);

        input [15:0] A;
        input [15:0] B;
        input Cin;
        output [16:0]O;

        wire [15:0]P;
        wire [15:0]G;

        genvar i;
        generate
            for (i = 0; i < 16; i = i+1) begin

                prop_gen a(.a(A[i]), .b(B[i]), .P(P[i]), .G(G[i]));
            end
        endgenerate

        // Zeroth Layer
        wire V;
        grey L0(.G_i(G[0]), .P_i(P[0]), .G_k(Cin), .G_j(V));

        // First Layer
        wire [7:0]G1;
        wire [7:0]P1;

        grey L1(.G_i(G[1]), .P_i(P[1]), .G_k(V), .G_j(G1[0]));

        black B0(.G_i(G[3]), .P_i(P[3]), .G_k(G[2]), .P_k(P[2]), .G_j(G1[1]), .P_j(P1[1]));
        black B1(.G_i(G[5]), .P_i(P[5]), .G_k(G[4]), .P_k(P[4]), .G_j(G1[2]), .P_j(P1[2]));
        black B2(.G_i(G[7]), .P_i(P[7]), .G_k(G[6]), .P_k(P[6]), .G_j(G1[3]), .P_j(P1[3]));
        black B3(.G_i(G[9]), .P_i(P[9]), .G_k(G[8]), .P_k(P[8]), .G_j(G1[4]), .P_j(P1[4]));
        black B4(.G_i(G[11]), .P_i(P[11]), .G_k(G[10]), .P_k(P[10]), .G_j(G1[5]), .P_j(P1[5]));
        black B5(.G_i(G[13]), .P_i(P[13]), .G_k(G[12]), .P_k(P[12]), .G_j(G1[6]), .P_j(P1[6]));
        black B6(.G_i(G[15]), .P_i(P[15]), .G_k(G[14]), .P_k(P[14]), .G_j(G1[7]), .P_j(P1[7]));

        //Second Layer
        wire [3:0]G2;
        wire [3:0]P2;

        grey L2(.G_i(G1[1]), .P_i(P1[1]), .G_k(G1[0]), .G_j(G2[0]));

        black B7(.G_i(G1[3]), .P_i(P1[3]), .G_k(G1[2]), .P_k(P1[2]), .G_j(G2[1]), .P_j(P2[1]));
        black B8(.G_i(G1[5]), .P_i(P1[5]), .G_k(G1[4]), .P_k(P1[4]), .G_j(G2[2]), .P_j(P2[2]));
        black B9(.G_i(G1[7]), .P_i(P1[7]), .G_k(G1[6]), .P_k(P1[6]), .G_j(G2[3]), .P_j(P2[3]));

        //Third Layer
        wire [1:0]G3;
        wire [1:0]P3;

        grey L3(.G_i(G2[1]), .P_i(P2[1]), .G_k(G2[0]), .G_j(G3[0]));

        black B10(.G_i(G2[3]), .P_i(P2[3]), .G_k(G2[2]), .P_k(P2[2]), .G_j(G3[1]), .P_j(P3[1]));

        //Fourth Layer
        wire G4;

        grey L4(.G_i(G3[1]), .P_i(P3[1]), .G_k(G3[0]), .G_j(G4));

        //Fifth Layer
        wire G5;

        grey L5(.G_i(G2[2]), .P_i(P2[2]), .G_k(G3[0]), .G_j(G5));

        //Sixth Layer
        wire [2:0]G6;

        grey L6(.G_i(G1[2]), .P_i(P1[2]), .G_k(G2[0]), .G_j(G6[0]));
        grey L7(.G_i(G1[4]), .P_i(P1[4]), .G_k(G3[0]), .G_j(G6[1]));
        grey L8(.G_i(G1[6]), .P_i(P1[6]), .G_k(G5), .G_j(G6[2]));

        //Seventh Layer
        wire [15:0]X;

        assign X[0] = V;

        assign X[1] = G1[0];
        
        grey L9(.G_i(G[2]), .P_i(P[2]), .G_k(G1[0]), .G_j(X[2]));

        assign X[3] = G2[0];

        grey L10(.G_i(G[4]), .P_i(P[4]), .G_k(G2[0]), .G_j(X[4]));

        assign X[5] = G6[0];

        grey L11(.G_i(G[6]), .P_i(P[6]), .G_k(G6[0]), .G_j(X[6]));

        assign X[7] = G3[0];

        grey L12(.G_i(G[8]), .P_i(P[8]), .G_k(G3[0]), .G_j(X[8]));

        assign X[9] = G6[1];

        grey L13(.G_i(G[10]), .P_i(P[10]), .G_k(G6[1]), .G_j(X[10]));

        assign X[11] = G5;

        grey L14(.G_i(G[12]), .P_i(P[12]), .G_k(G5), .G_j(X[12]));

        assign X[13] = G6[2];

        grey L15(.G_i(G[14]), .P_i(P[14]), .G_k(G6[2]), .G_j(X[14]));

        assign X[15] = G4;

        //Sum Layer
        xor T0(O[0], P[0], Cin);
        xor T1(O[1], P[1], X[0]);
        xor T2(O[2], P[2], X[1]);
        xor T3(O[3], P[3], X[2]);
        xor T4(O[4], P[4], X[3]);
        xor T5(O[5], P[5], X[4]);
        xor T6(O[6], P[6], X[5]);
        xor T7(O[7], P[7], X[6]);
        xor T8(O[8], P[8], X[7]);
        xor T9(O[9], P[9], X[8]);
        xor T10(O[10], P[10], X[9]);
        xor T11(O[11], P[11], X[10]);
        xor T12(O[12], P[12], X[11]);
        xor T13(O[13], P[13], X[12]);
        xor T14(O[14], P[14], X[13]);
        xor T15(O[15], P[15], X[14]);
        assign O[16] = X[15];
        
endmodule