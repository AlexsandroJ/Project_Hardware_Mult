`timescale 1ps/1ps
module simulcao_CPU;
    logic clock;
    logic reset;
    logic [31:0] opcode;

    logic [63:0] MemOutInst;
    logic [31:0] rAddressInst;
    logic [63:0] WriteDataMem;
    logic [63:0] WriteRegister;
    logic [63:0] WriteDataReg;
    logic RegWrite;
    logic [63:0] MDR;
    logic [63:0] Alu;
    logic [63:0] AluOut;
    logic [63:0] PC;
    logic [63:0] DeslocValue;
    logic wrDataMem;
    logic wrInstMem;
    logic IRWrite;
    logic [63:0] EPC;
    logic [4:0] Estado;


    
     CPU teste_CPU(      .clock(         clock                   ),
                        .reset(         reset                   ),
                        
                        .opcode(        opcode                  ),

                        .MemOutInst(        MemOutInst          ),
                        .rAddressInst(      rAddressInst        ),
                        .WriteDataMem(      WriteDataMem        ),
                        .WriteRegister(     WriteRegister       ),
                        .WriteDataReg(      WriteDataReg        ),
                        .RegWrite(          RegWrite            ),
                        .MDR(               MDR                 ),
                        .Alu(               Alu                 ),
                        .AluOut(            AluOut              ),
                        .PC_(                PC                  ),
                        .DeslocValue(       DeslocValue         ),
                        .wrDataMem(         wrDataMem           ),
                        .wrInstMem(         wrInstMem           ),
                        .IRWrite(           IRWrite             ),
                        .EPC_(               EPC                 ),
                        .Estado(        Estado                  )
                                                                );
    localparam CLKPERIODO = 10000;
    localparam CLKDELAY = CLKPERIODO/2;
    initial begin
        clock = 1'b0;
        reset = 1'b1;
        #(CLKPERIODO)
        #(CLKPERIODO)
        #(CLKPERIODO)
        reset = 1'b0;
    end

    always #(CLKDELAY) clock = ~clock;

    always_ff@(posedge clock or posedge reset)begin
        
        if($time < 10000000 ) begin
            
            //$monitor("Mem_Inst:%d OpCode:%d Clock:%b Reset:%b PC:%d Estado:%d A:%d B:%d MuxA:%d MuxB:%d Ula:%d igual:%d Menor:%d Maior:%d OvFlo:%d Mem64:%d MuxReg:%d EPC:%d Causa:%d",Instruction[6:0],opcode[6:0],clock, reset,Pc_Out[31:0],Estado, Registrador_A[31:0], Registrador_B[31:0], MUX_A_SAIDA[31:0], MUX_B_SAIDA[31:0], Ula_Out[63:0],igual_Ula,menor_Ula,maior_Ula,overFlow_Ula, Memoria64_Out, Mux64_Banco_Reg_Out[31:0],Reg_EPC[31:0],Reg_Caua[2:0]);
            //$monitor("RD:%d OpCode:%d Clock:%b Reset:%b PC:%d Estado:%d A:%d B:%d MuxA:%d MuxB:%d Ula:%d Mem64:%d MuxReg:%d EPC:%d Causa:%d wr:%d WriteDataReg:%d IRWrite:%d ",Instruction[11:7],opcode[6:0],clock, reset,Pc_Out[31:0],Estado, Registrador_A[31:0], Registrador_B[31:0], MUX_A_SAIDA[31:0], MUX_B_SAIDA[31:0], Ula_Out[63:0], Memoria64_Out, Mux64_Banco_Reg_Out[31:0],Reg_EPC[31:0],Reg_Caua[10:0],memoria_wr,reg_wr,Ld_ir);
           
            //$monitor("MenData:%d Address:%d L/S:%d WriteDataReg:%d MDR:%d Alu:%d AluOut:%d PC:%d wr:%d RegWrite:%d IRWrite:%d EPC:%d Estado:%d",Memoria64_Out,Ula_Out,memoria_wr,Mux64_Banco_Reg_Out,Reg_Memory_Data, Ula_Out,Reg_ULAOut, Pc_Out,memoria_wr,reg_wr,Ld_ir,Reg_EPC,Estado);
            
        end
        else begin
            $stop;
        end
    end
endmodule