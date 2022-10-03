module black(input G_i, P_i, G_k, P_k,
             output G_j, P_j);

        and (P_j, P_i, P_k);

        wire tr;

        and (tr, P_i, G_k);
        or (G_j, G_i, tr);
        
endmodule