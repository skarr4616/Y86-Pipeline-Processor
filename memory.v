module memory(
    input clk,

    // Inputs
    input [2:0] M_stat,
    input [3:0] M_icode,
    input [63:0] M_valE,
    input [63:0] M_valA,
    input [3:0] M_dstE,
    input [3:0] M_dstM,

    // Outputs
    output reg[2:0] m_stat,
    output reg[3:0] m_icode,
    output reg[63:0] m_valE,
    output reg[63:0] m_valM,
    output reg[3:0] m_dstE,
    output reg[3:0] m_dstM
);

    // Initiating data memory
    reg [63:0] Data_Mem[0:4095];
    integer i;

    initial begin
        for (i = 0; i < 4096; i = i+1) begin
            Data_Mem[i] <= 0;
        end

        $dumpvars(0, Data_Mem[0], Data_Mem[1], Data_Mem[2], Data_Mem[3], Data_Mem[4], Data_Mem[5], Data_Mem[6], Data_Mem[7], Data_Mem[8]);
    end

    // Setting up direct transfer wires
    always @(*) begin
    
        m_icode <= M_icode;
        m_valE <= M_valE;
        m_dstE <= M_dstE;
        m_dstM <= M_dstM;
    end

    // Mem_write block
    reg Mem_write;

    always @(*) begin

        if (m_icode == 4 || m_icode == 8 || m_icode == 10) begin

            Mem_write <= 1;
        end
        else begin

            Mem_write <= 0;
        end
    end

    // Mem_read block
    reg Mem_read;

    always @(*) begin

        if (m_icode == 5 || m_icode == 9 || m_icode == 11) begin

            Mem_read <= 1;
        end
        else begin

            Mem_read <= 0;
        end
    end

    // Selecting Address
    reg [63:0] m_addr;

    always @(*) begin

        if (m_icode == 4 || m_icode == 5 || m_icode == 8 || m_icode == 10) begin

            m_addr <= m_valE;
        end
        else if (m_icode == 9 || m_icode == 11) begin

            m_addr <= M_valA;
        end
        else begin

            m_addr <= 4095; 
        end
    end

    // Checking memory error
    reg dmem_error;

    always @(*) begin

        if (m_addr < 4096 && m_addr >= 0) begin

            dmem_error <= 0;
        end
        else begin

            dmem_error <= 1;
        end
    end

    // Assigning data_in
    wire [63:0] m_data_in;

    assign m_data_in = M_valA;

    // Writing back to data memory at positive clock edge
    always @(posedge clk) begin

        if (dmem_error == 0 && Mem_write == 1) begin
            Data_Mem[m_addr] <= m_data_in;
        end
    end

    // Reading from data memory
    always @(*) begin

        if (dmem_error == 0 && Mem_read == 1) begin

            m_valM <= Data_Mem[m_addr];
        end
        else begin

            m_valM <= 0;
        end
    end

    // Setting up m_stat
    always @(*) begin
        
        if (dmem_error == 1) begin

            m_stat <= 3;
        end 
        else begin

            m_stat <= M_stat;
        end
    end

endmodule