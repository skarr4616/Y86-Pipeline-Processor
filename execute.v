`include "ALU.v"

module execute(
    input clk,
    
    // Inputs
    input [2:0] E_stat,
    input [3:0] E_icode,
    input [3:0] E_ifun,
    input [63:0] E_valC,
    input [63:0] E_valA,
    input [63:0] E_valB,
    input [3:0] E_dstE,
    input [3:0] E_dstM,
    input [2:0] W_stat,
    input [2:0] m_stat,

    // Outputs
    output reg[2:0] e_stat,
    output reg[3:0] e_icode,
    output reg e_Cnd,
    output [63:0] e_valE,
    output reg[63:0] e_valA,
    output reg[3:0] e_dstE,
    output reg[3:0] e_dstM
);

    // Setting up direct transfer wires
    always @(*) begin
        
        e_stat <= E_stat;
        e_icode <= E_icode;
        e_valA <= E_valA;
        e_dstM <= E_dstM;
    end

    // Selecting aluA
    reg [63:0] aluA, aluB;

    always @(*) begin

        if (e_icode == 2) begin
            aluA <= E_valA;
            aluB <= 0;
        end
        else if (e_icode == 3) begin
            aluA <= E_valC;
            aluB <= 0;
        end
        else if (e_icode == 4) begin
            aluA <= E_valC;
            aluB <= E_valB;
        end
        else if (e_icode == 5) begin
            aluA <= E_valC;
            aluB <= E_valB;
        end
        else if (e_icode == 6) begin
            aluA <= E_valB;
            aluB <= E_valA;
        end
        else if (e_icode == 8) begin
            aluA <= -8;
            aluB <= E_valB;
        end
        else if (e_icode == 9) begin
            aluA <= 8;
            aluB <= E_valB;
        end
        else if (e_icode == 10) begin
            aluA <= -8;
            aluB <= E_valB;
        end
        else if (e_icode == 11) begin
            aluA <= 8;
            aluB <= E_valB;
        end
        else begin

            aluA <= 0;
            aluB <= 0;
        end
    end

    // Setting up ALU operation
    wire [3:0] alu_fun;

    assign alu_fun = (e_icode == 6) ? E_ifun : 0;

    // ALU operation
    ALU OPq(.A(aluA),.B(aluB), .s(alu_fun), .Out(e_valE));

    // Making set_cc signal
    wire set_cc;

    assign set_cc = ((e_icode == 6) && (m_stat != 2 && m_stat != 3 && m_stat != 4) && (W_stat != 2 && W_stat != 3 && W_stat != 4)) ? 1 : 0;

    // Setting up condition code registers
    reg Z = 0, S = 0, Ov = 0;

    always @(posedge clk) begin
        if (set_cc == 1) begin
            Z <= (e_valE == 0) ? 1 : 0;
            S <= (e_valE[63] == 1) ? 1 : 0;

            if (alu_fun == 0) begin
                Ov <= ((aluA[63] == 1 && aluB[63] == 1 && e_valE[63] == 0) || (aluA[63] == 0 && aluB[63] == 0 && e_valE[63] == 1)) ? 1 : 0;
            end
            else if (alu_fun == 1) begin
                Ov <= ((aluA[63] == 1 && aluB[63] == 0 && e_valE[63] == 0) || (aluA[63] == 0 && aluB[63] == 1 && e_valE[63] == 1)) ? 1 : 0;
            end
            else begin
                Ov <= 0;
            end
        end
    end

    // Setting up condition bit
    always @(*) begin
        if (E_ifun == 0) begin
            e_Cnd <= 1;
        end
        else if (E_ifun == 1) begin
            e_Cnd <= (S ^ Ov) | Z;
        end
        else if (E_ifun == 2) begin
            e_Cnd <= (S ^ Ov);
        end
        else if (E_ifun == 3) begin
            e_Cnd <= Z;
        end
        else if (E_ifun == 4) begin
            e_Cnd <= ~Z;
        end
        else if (E_ifun == 5) begin
            e_Cnd <= ~(S ^ Ov);
        end
        else if (E_ifun == 6) begin
            e_Cnd <= ~(S ^ Ov) & ~Z;
        end
        else begin
            e_Cnd <= 1;
        end
    end

    // Select e_dstE
    always @(*) begin

        if (e_icode == 2 && e_Cnd == 0) begin
            
            e_dstE <= 15;
        end
        else begin

            e_dstE <= E_dstE;
        end
    end


endmodule