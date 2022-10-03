module fetch(
    // Inputs
    input [63:0] F_predPC,
    input [3:0] M_icode,
    input M_Cnd,
    input [63:0] M_valA,
    input [3:0] W_icode,
    input [63:0] W_valM,

    // Outputs
    output [2:0] f_stat,
    output reg[3:0] f_icode,
    output reg[3:0] f_ifun,
    output reg[3:0] f_rA,
    output reg[3:0] f_rB,
    output reg[63:0] f_valC,
    output reg[63:0] f_valP,
    output [63:0] f_predPC
);

    // Setting up instruction memory
    reg [7:0] inst_mem[0:1023];

    initial begin
        $readmemb("inst_mem.txt", inst_mem);
    end


    // Select f_PC
    wire [63:0] f_pc;

    Select_PC s_pc(
        // Inputs
        .F_predPC(F_predPC),
        .M_icode(M_icode),
        .M_Cnd(M_Cnd),
        .M_valA(M_valA),    
        .W_icode(W_icode),
        .W_valM(W_valM),

        // Outputs
        .f_pc(f_pc)
    );


    // Select f_icode, f_ifun, imem_error
    reg imem_error;

    always @(*) begin
        if (f_pc >= 0 && f_pc < 4096) begin 
            f_icode <= inst_mem[f_pc][7:4];
            f_ifun <= inst_mem[f_pc][3:0];
            imem_error <= 0;
        end
        else begin
            f_icode <= 1;
            f_ifun <= 0;
            imem_error <= 1;
        end
    end


    // Validating the instruction
    reg instr_valid;
    
    always @(*) begin

        if (f_icode >= 0 && f_icode <= 11) begin
            instr_valid <= 1;
        end
        else begin
            instr_valid <= 0;
        end
    end

    // Aligning f_rA, f_rB, f_valC, f_valP
    always @(*) begin

        if (f_icode == 2 || f_icode == 6 || f_icode == 10 || f_icode == 11) begin

            f_rA <= inst_mem[f_pc + 1][7:4];
            f_rB <= inst_mem[f_pc + 1][3:0];
            f_valC <= 0;
            f_valP <= f_pc + 2;
        end
        else if (f_icode == 3 || f_icode == 4 || f_icode == 5) begin
            f_rA <= inst_mem[f_pc + 1][7:4];
            f_rB <= inst_mem[f_pc + 1][3:0];
            f_valC[7:0] <= inst_mem[f_pc + 2];
            f_valC[15:8] <= inst_mem[f_pc + 3];
            f_valC[23:16] <= inst_mem[f_pc + 4];
            f_valC[31:24] <= inst_mem[f_pc + 5];
            f_valC[39:32] <= inst_mem[f_pc + 6];
            f_valC[47:40] <= inst_mem[f_pc + 7];
            f_valC[55:48] <= inst_mem[f_pc + 8];
            f_valC[63:56] <= inst_mem[f_pc + 9];
            f_valP <= f_pc + 10;
        end
        else if (f_icode == 7 || f_icode == 8) begin
            f_rA <= 15;
            f_rB <= 15;
            f_valC[7:0] <= inst_mem[f_pc + 1];
            f_valC[15:8] <= inst_mem[f_pc + 2];
            f_valC[23:16] <= inst_mem[f_pc + 3];
            f_valC[31:24] <= inst_mem[f_pc + 4];
            f_valC[39:32] <= inst_mem[f_pc + 5];
            f_valC[47:40] <= inst_mem[f_pc + 6];
            f_valC[55:48] <= inst_mem[f_pc + 7];
            f_valC[63:56] <= inst_mem[f_pc + 8];
            f_valP <= f_pc + 9;
        end
        else begin
            f_rA <= 15;  
            f_rB <= 15; 
            f_valC <= 0;
            f_valP <= f_pc + 1;
        end
    end

    // Predict PC
    Predict_PC pPC(
        // Inputs
        .f_icode(f_icode),
        .f_valC(f_valC),
        .f_valP(f_valP),

        // Outputs
        .f_predPC(f_predPC)
    );

    // Generating f_stat
    Stat s(
        // Inputs
        .instr_valid(instr_valid),
        .imem_error(imem_error),
        .f_icode(f_icode),

        // Outputs
        .f_stat(f_stat)
    );



endmodule

module Select_PC(
    // Inputs
    input [63:0] F_predPC,
    input [3:0] M_icode,
    input M_Cnd,
    input [63:0] M_valA,
    input [3:0] W_icode,
    input [63:0] W_valM,

    // Outputs
    output reg[63:0] f_pc
);

    always @(*) begin
        
        if (M_icode == 7 && M_Cnd == 0) begin

            f_pc <= M_valA;
        end
        else if (W_icode == 9) begin
            
            f_pc <= W_valM;
        end
        else begin

            f_pc <= F_predPC;
        end
    end
endmodule

module Predict_PC(
    // Inputs
    input [3:0] f_icode,
    input [63:0] f_valC,
    input [63:0] f_valP,

    // Outputs
    output reg[63:0] f_predPC
);

    always @(*) begin 

        if (f_icode == 7 || f_icode == 8) begin

            f_predPC <= f_valC;
        end
        else begin

            f_predPC <= f_valP;
        end
    end
endmodule

module Stat(
    // Inputs
    input instr_valid,
    input imem_error,
    input [3:0] f_icode,

    // Outputs
    output reg[2:0] f_stat
);

    always @(*) begin

        if (imem_error == 1) begin

            f_stat <= 3;
        end 
        else if (instr_valid == 0) begin

            f_stat <= 4;
        end
        else if (f_icode == 0) begin

            f_stat <= 2;
        end
        else begin

            f_stat <= 1;
        end

    end
endmodule