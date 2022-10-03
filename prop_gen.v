module prop_gen(input a, b,
                output P, G);

        xor (P, a, b);
        and (G, a, b);
        
endmodule