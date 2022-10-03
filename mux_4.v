module mux_4(in0, in1, in2, in3, s0, s1, out);

    input in0, in1, in2, in3, s0, s1;
    output out;

    wire n0, n1;
    not (n0, s0);
    not (n1, s1);

    wire w0;
    and (w0, n0, n1, in0);

    wire w1;
    and (w1, s0, n1, in1);

    wire w2;
    and (w2, n0, s1, in2);

    wire w3;
    and (w3, s0, s1, in3);

    or (out, w0, w1, w2, w3);

endmodule