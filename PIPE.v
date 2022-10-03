`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory.v"
`include "PIPE_CON.v"

module PIPE(input clk, output [2:0] Stat);

    // F pipeline register
    reg [63:0] F_predPC = 0;

    // D pipeline register
    reg [2:0] D_stat = 1;
    reg [3:0] D_icode = 1;
    reg [3:0] D_ifun = 0;
    reg [3:0] D_rA = 0;
    reg [3:0] D_rB = 0;
    reg [63:0] D_valC = 0;
    reg [63:0] D_valP = 0;

    // E pipeline register
    reg [2:0] E_stat = 1;
    reg [3:0] E_icode = 1;
    reg [3:0] E_ifun = 0;
    reg [63:0] E_valC = 0;
    reg [63:0] E_valA = 0;
    reg [63:0] E_valB = 0;
    reg [3:0] E_dstE = 0;
    reg [3:0] E_dstM = 0;
    reg [3:0] E_srcA = 0;
    reg [3:0] E_srcB = 0;

    // M pipeline register
    reg [2:0] M_stat = 1;
    reg [3:0] M_icode = 1;
    reg M_Cnd = 0;
    reg [63:0] M_valE = 0;
    reg [63:0] M_valA = 0;
    reg [3:0] M_dstE = 0;
    reg [3:0] M_dstM = 0;

    // W pipeline register
    reg [2:0] W_stat = 1;
    reg [3:0] W_icode = 1;
    reg [63:0] W_valE = 0;
    reg [63:0] W_valM = 0;  
    reg [3:0] W_dstE = 0;
    reg [3:0] W_dstM = 0;

    // Fetch stage output
    wire [2:0] f_stat;
    wire [3:0] f_icode;
    wire [3:0] f_ifun;
    wire [3:0] f_rA;
    wire [3:0] f_rB;
    wire [63:0] f_valC;
    wire [63:0] f_valP;
    wire [63:0] f_predPC;

    // Decode stage output
    wire [2:0] d_stat;
    wire [3:0] d_icode;
    wire [3:0] d_ifun;
    wire [63:0] d_valC;
    wire [63:0] d_valA;
    wire [63:0] d_valB;
    wire [3:0] d_dstE;
    wire [3:0] d_dstM;
    wire [3:0] d_srcA;
    wire [3:0] d_srcB;

    // Execute stage output
    wire [2:0] e_stat;
    wire [3:0] e_icode;
    wire e_Cnd;
    wire [63:0] e_valE;
    wire [63:0] e_valA;
    wire [3:0] e_dstE;
    wire [3:0] e_dstM;

    // Memory stage output
    wire [2:0] m_stat;
    wire [3:0] m_icode;
    wire [63:0] m_valE;
    wire [63:0] m_valM;
    wire [3:0] m_dstE;
    wire [3:0] m_dstM;



    // Passing inputs to FETCH stage
    fetch f(
        // Inputs from F register
        .F_predPC(F_predPC),

        // Inputs forwarded from M register
        .M_icode(M_icode),
        .M_Cnd(M_Cnd),
        .M_valA(M_valA),

        // Inputs forwarded from W register
        .W_icode(W_icode),
        .W_valM(W_valM),

        // Outputs
        .f_stat(f_stat),
        .f_icode(f_icode),
        .f_ifun(f_ifun),
        .f_rA(f_rA),
        .f_rB(f_rB),
        .f_valC(f_valC),
        .f_valP(f_valP),
        .f_predPC(f_predPC)
    );

    decode d(
        .clk(clk),
        
        // Inputs from D register
        .D_stat(D_stat),
        .D_icode(D_icode),
        .D_ifun(D_ifun),
        .D_rA(D_rA),
        .D_rB(D_rB),
        .D_valC(D_valC),
        .D_valP(D_valP),

        // Inputs forwarded from execute stage
        .e_dstE(e_dstE),
        .e_valE(e_valE),

        // inputs forwarded from M register and memory stage
        .M_dstE(M_dstE),
        .M_valE(M_valE),
        .M_dstM(M_dstM),
        .m_valM(m_valM),

        // Inputs forwarded from W register
        .W_dstM(W_dstM),
        .W_valM(W_valM),
        .W_dstE(W_dstE),
        .W_valE(W_valE),

        // Outputs
        .d_stat(d_stat),
        .d_icode(d_icode),
        .d_ifun(d_ifun),
        .d_valC(d_valC),
        .d_valA(d_valA),
        .d_valB(d_valB),
        .d_dstE(d_dstE),
        .d_dstM(d_dstM),
        .d_srcA(d_srcA),
        .d_srcB(d_srcB)
    );

    execute e(
        .clk(clk),

        // Inputs
        .E_stat(E_stat),
        .E_icode(E_icode),
        .E_ifun(E_ifun),
        .E_valC(E_valC),
        .E_valA(E_valA),
        .E_valB(E_valB),
        .E_dstE(E_dstE),
        .E_dstM(E_dstM),
        .W_stat(W_stat),
        .m_stat(m_stat),

        // Outputs
        .e_stat(e_stat),
        .e_icode(e_icode),
        .e_Cnd(e_Cnd),
        .e_valE(e_valE),
        .e_valA(e_valA),
        .e_dstE(e_dstE),
        .e_dstM(e_dstM)
    );

    memory m(
        .clk(clk),

        // Inputs
        .M_stat(M_stat),
        .M_icode(M_icode),
        .M_valE(M_valE),
        .M_valA(M_valA),
        .M_dstE(M_dstE),
        .M_dstM(M_dstM),

        // Outputs
        .m_stat(m_stat),
        .m_icode(m_icode),
        .m_valE(m_valE),
        .m_valM(m_valM),
        .m_dstE(m_dstE),
        .m_dstM(m_dstM)
    );

    // Code for Processor Status Code
    assign Stat = W_stat;


    // Writing PipeLine Control Logic
    wire W_stall;
    wire M_bubble;
    wire E_bubble;
    wire D_bubble;
    wire D_stall;
    wire F_stall;

    PIPE_CON pip_con(
        // Inputs
        .D_icode(D_icode),
        .d_srcA(d_srcA),
        .d_srcB(d_srcB),
        .E_icode(E_icode),
        .E_dstM(E_dstM),
        .e_Cnd(e_Cnd),
        .M_icode(M_icode),
        .m_stat(m_stat),
        .W_stat(W_stat),

        // Outputs
        .W_stall(W_stall),
        .M_bubble(M_bubble),
        .E_bubble(E_bubble),
        .D_bubble(D_bubble),
        .D_stall(D_stall),
        .F_stall(F_stall)
    );


    // Updating F register at every positive edge of clock
    always @(posedge clk) begin
        
        if (F_stall != 1) begin

            F_predPC <= f_predPC;
        end
    end

    // Updating D register at every positive edge of clock
    always @(posedge clk) begin

        if (D_stall == 0) begin

            if (D_bubble == 0) begin

                D_stat <= f_stat;
                D_icode <= f_icode;
                D_ifun <= f_ifun;
                D_rA <= f_rA;
                D_rB <= f_rB;
                D_valC <= f_valC;
                D_valP <= f_valP;
            end
            else begin

                D_stat <= 1;
                D_icode <= 1;
                D_ifun <= 0;
                D_rA <= 0;
                D_rB <= 0;
                D_valC <= 0;
                D_valP <= 0;
            end
        end
        
    end

    // Updating E register at every positive edge of clock
    always @(posedge clk) begin

        if (E_bubble == 1) begin

            E_stat <= 1;
            E_icode <= 1;
            E_ifun <= 0;
            E_valC <= 0;
            E_valA <= 0;
            E_valB <= 0;
            E_dstE <= 0;
            E_dstM <= 0;
            E_srcA <= 0;
            E_srcB <= 0;
        end
        else begin

            E_stat <= d_stat;
            E_icode <= d_icode;
            E_ifun <= d_ifun;
            E_valC <= d_valC;
            E_valA <= d_valA;
            E_valB <= d_valB;
            E_dstE <= d_dstE;
            E_dstM <= d_dstM;
            E_srcA <= d_srcA;
            E_srcB <= d_srcB;
        end
    end

    // Updating M register at every positive edge of clock
    always @(posedge clk) begin

        if (M_bubble == 1) begin

            M_stat <= 1;
            M_icode <= 1;
            M_Cnd <= 0;
            M_valE <= 0;
            M_valA <= 0;
            M_dstE <= 0;
            M_dstM <= 0;
        end
        else begin
            M_stat <= e_stat;
            M_icode <= e_icode;
            M_Cnd <= e_Cnd;
            M_valE <= e_valE;
            M_valA <= e_valA;
            M_dstE <= e_dstE;
            M_dstM <= e_dstM;
        end
    end

    // Updating W register at every positive edge of clock
    always @(posedge clk) begin
    
        if (W_stall != 1) begin

            W_stat <= m_stat;
            W_icode <= m_icode;
            W_valE <= m_valE;
            W_valM <= m_valM;
            W_dstE <= m_dstE;
            W_dstM <= m_dstM;
        end
    end

endmodule

module tb();

    reg clk;
    wire [2:0] Stat;

    PIPE dut(.clk(clk), .Stat(Stat));

    initial begin
        clk <= 0;
            forever #50 clk <= ~clk; 
    end

    initial begin

        $dumpvars(0, tb);

        $monitor ("clk = %b Stat = %b", clk, Stat);

    end

    always @(*) begin
        
        if(Stat == 2) begin

            $finish;
        end
    end
endmodule
