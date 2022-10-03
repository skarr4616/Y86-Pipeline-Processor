module decode(
    input clk,

    // Inputs from D register
    input [2:0] D_stat,
    input [3:0] D_icode,
    input [3:0] D_ifun,
    input [3:0] D_rA,
    input [3:0] D_rB,
    input [63:0] D_valC,
    input [63:0] D_valP,

    // Inputs forwarded from execute stage
    input [3:0] e_dstE,
    input [63:0] e_valE,

    // Inputs forwarded from M register and memory stage
    input [3:0] M_dstE,
    input [63:0] M_valE,
    input [3:0] M_dstM,
    input [63:0] m_valM,

    // Inputs forwarded from W register
    input [3:0] W_dstM,
    input [63:0] W_valM,
    input [3:0] W_dstE,
    input [63:0] W_valE,

    // Outputs
    output reg[2:0] d_stat,
    output reg[3:0] d_icode,
    output reg[3:0] d_ifun,
    output reg[63:0] d_valC,
    output reg[63:0] d_valA,
    output reg[63:0] d_valB,
    output reg[3:0] d_dstE,
    output reg[3:0] d_dstM,
    output reg[3:0] d_srcA,
    output reg[3:0] d_srcB
);

    // Initiating register arrays
    reg [63:0] reg_array[0:15];
    integer i;

    initial begin
        for (i = 0; i < 16; i = i+1) begin
          reg_array[i] <= 0; 
        end

        $dumpfile("dump.vcd");
        $dumpvars(0, reg_array[0], reg_array[1], reg_array[2], reg_array[3], reg_array[4], reg_array[5], reg_array[6], reg_array[7], reg_array[8], reg_array[9], reg_array[10], reg_array[11], reg_array[12], reg_array[13], reg_array[14], reg_array[15]);
    end
   
    // Setting up direct transfer wires
    always @(*) begin
        
        d_stat <= D_stat;
        d_icode <= D_icode;
        d_ifun <= D_ifun;
        d_valC <= D_valC;
    end

    // Updating register file at positive edge of clock
    always @(posedge clk) begin
        
        reg_array[W_dstM] <= W_valM;
        reg_array[W_dstE] <= W_valE;
    end

    // Selecting d_dstE
    always @(*) begin

        if (d_icode == 2 || d_icode == 3 || d_icode == 6) begin

            d_dstE <= D_rB;
        end
        else if (d_icode == 8 || d_icode == 9 || d_icode == 10 || d_icode == 11) begin

            d_dstE <= 4;
        end
        else begin

            d_dstE <= 15;
        end
    end

    // Selecting d_dstM
    always @(*) begin

        if (d_icode == 5 || d_icode == 11) begin

            d_dstM <= D_rA;
        end
        else begin

            d_dstM <= 15;
        end
    end

    // Selecting d_srcA
    always @(*) begin

        if (d_icode == 2 || d_icode == 4 || d_icode == 6) begin

            d_srcA <= D_rA;
        end
        else if (d_icode == 9 || d_icode == 10 || d_icode == 11) begin

            d_srcA <= 4;
        end
        else begin

            d_srcA <= 15;
        end 
    end

    // Selecting d_srcB
    always @(*) begin

        if (d_icode == 4 || d_icode == 5 || d_icode == 6) begin

            d_srcB <= D_rB;
        end
        else if (d_icode == 8 || d_icode == 9 || d_icode == 10 || d_icode == 11) begin

            d_srcB <= 4;
        end
        else begin

            d_srcB <= 15;
        end 
    end

    // Reading d_rvalA and d_rvalB from register
    wire [63:0] d_rvalA;
    wire [63:0] d_rvalB;

    assign d_rvalA = reg_array[d_srcA];
    assign d_rvalB = reg_array[d_srcB];

    // Sel+Fwd A Block
    always @(*) begin

        if (d_icode == 7 || d_icode == 8) begin

            d_valA <= D_valP;
        end
        else if (d_srcA == e_dstE) begin

            d_valA <= e_valE;
        end
        else if (d_srcA == M_dstM) begin

            d_valA <= m_valM;
        end
        else if (d_srcA == M_dstE) begin

            d_valA <= M_valE;
        end
        else if (d_srcA == W_dstM) begin

            d_valA <= W_valM;
        end
        else if (d_srcA == W_dstE) begin

            d_valA <= W_valE;
        end
        else begin
            
            d_valA <= d_rvalA;
        end
    end

    // Fwd B Block
    always @(*) begin

        if (d_srcB == e_dstE) begin

            d_valB <= e_valE;
        end
        else if (d_srcB == M_dstM) begin

            d_valB <= m_valM;
        end
        else if (d_srcB == M_dstE) begin

            d_valB <= M_valE;
        end
        else if (d_srcB == W_dstM) begin

            d_valB <= W_valM;
        end
        else if (d_srcB == W_dstE) begin

            d_valB <= W_valE;
        end
        else begin
            
            d_valB <= d_rvalB;
        end
    end

endmodule
