module mux_2(in0, in1, s, out);

    input in0, in1, s;
    output out;

    wire w1;
    and (w1, in1, s);

    wire z;
    not(z, s);

    wire w0;
    and (w0, in0, z);

    or (out, w0, w1);

endmodule