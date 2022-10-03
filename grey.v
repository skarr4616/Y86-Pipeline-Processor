module grey(input G_i, P_i, G_k,
            output G_j);

        wire tr;

        and (tr, P_i, G_k);
        or (G_j, G_i, tr);
        
endmodule