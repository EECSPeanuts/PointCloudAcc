// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//      "header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author : zhouchch@pku.edu.cn
// File   : CCU.v
// Create : 2020-07-14 21:09:52
// Revise : 2020-08-13 10:33:19
// -----------------------------------------------------------------------------
module PSS #(
    parameter SORT_LEN_WIDTH  = 5                 ,
    parameter IDX_WIDTH       = 10                ,
    parameter DIST_WIDTH      = 17                ,
    parameter NUM_SORT_CORE   = 8                 ,
    parameter SRAM_WIDTH      = 256               ,
    parameter MASK_ADDR_WIDTH = $clog2(2**IDX_WIDTH*NUM_SORT_CORE/SRAM_WIDTH)

    )(
    input                                   clk,
    input                                   rst_n,
    input                                   KNNPSS_Rst  ,
    input                                   KNNPSS_LopLast  ,
    input   [IDX_WIDTH              -1 : 0] KNNPSS_CpIdx    ,
    input   [IDX_WIDTH+DIST_WIDTH   -1 : 0] KNNPSS_Lop      ,  
    input                                   KNNPSS_LopVld   ,  
    output                                  PSSKNN_LopRdy   ,

    output  [MASK_ADDR_WIDTH        -1 : 0] PSSGLB_MaskRdAddr,
    output                                  PSSGLB_MaskRdAddrVld,
    input                                   GLBPSS_MaskRdAddrRdy,
    input   [SRAM_WIDTH             -1 : 0] GLBPSS_MaskDatOut,
    input                                   GLBPSS_MaskDatOutVld,
    output                                  PSSGLB_MaskDatRdy,

    output  [SRAM_WIDTH             -1 : 0] PSSCTR_Map      , 
    output                                  PSSCTR_MapVld   , 
    input                                   CTRPSS_MapRdy    
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================
localparam SORT_LEN        = 2**SORT_LEN_WIDTH;
//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
wire [NUM_SORT_CORE         -1 : 0] INS_LopRdy;

wire [SRAM_WIDTH*NUM_SORT_CORE-1 : 0] PSSMap;
wire [NUM_SORT_CORE           -1 : 0] INSPSS_IdxVld;
wire [NUM_SORT_CORE           -1 : 0] PSSINS_IdxRdy;
wire [(IDX_WIDTH*SORT_LEN)*NUM_SORT_CORE-1 : 0] INSPSS_Idx;
wire                                  PISO_IN_RDY;

integer int_i;
//=====================================================================================================================
// Logic Design 2: HandShake
//=====================================================================================================================


//=====================================================================================================================
// Logic Design 1: INSPSS_Idx
//=====================================================================================================================


//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================
genvar i;
generate
    for(i=0; i<NUM_SORT_CORE; i=i+1) begin

        wire [$clog2(SRAM_WIDTH/NUM_SORT_CORE)  -1 : 0] ByteIdx;
        reg  [IDX_WIDTH                         -1 : 0] LopIdx_s1;
        wire                                            INSPSS_LopRdy;
        wire                                            PSSINS_LopVld;
        reg [IDX_WIDTH+DIST_WIDTH               -1 : 0] PSSINS_Lop;

        // PIPE0: Input SRAM
        assign PSSGLB_MaskRdAddr = KNNPSS_Lop[IDX_WIDTH+DIST_WIDTH -1 -: IDX_WIDTH]>>$clog2(SRAM_WIDTH/NUM_SORT_CORE); // /(SRAM_WIDTH/NUM_SORT_CORE)
        assign PSSGLB_MaskRdAddrVld = KNNPSS_LopVld;
        assign PSSKNN_LopRdy = GLBPSS_MaskRdAddrRdy;

        // PIPE1: Output SRAM
        assign PSSGLB_MaskDatRdy = INSPSS_LopRdy;
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                PSSINS_Lop <= 0;
                LopIdx_s1  <= 0;
            end else if(KNNPSS_LopVld & PSSKNN_LopRdy) begin
                PSSINS_Lop <= KNNPSS_Lop;
                LopIdx_s1  <= KNNPSS_Lop[IDX_WIDTH+DIST_WIDTH -1 -: IDX_WIDTH];
            end
        end
        assign ByteIdx = LopIdx_s1 % (SRAM_WIDTH/NUM_SORT_CORE);
        assign PSSINS_LopVld = GLBPSS_MaskDatOutVld & GLBPSS_MaskDatOut[NUM_SORT_CORE*ByteIdx + i];
        INS#(
            .SORT_LEN_WIDTH   ( SORT_LEN_WIDTH ),
            .IDX_WIDTH       ( IDX_WIDTH ),
            .DIST_WIDTH      ( DIST_WIDTH )
        )u_INS(
            .clk                 ( clk                 ),
            .rst_n               ( rst_n               ),
            .PSSINS_LopLast      ( KNNPSS_LopLast      ),
            .PSSINS_Lop          ( PSSINS_Lop          ),
            .PSSINS_LopVld       ( PSSINS_LopVld       ),
            .INSPSS_LopRdy       ( INSPSS_LopRdy       ),
            .INSPSS_Idx          ( INSPSS_Idx[(IDX_WIDTH*SORT_LEN)*i +: (IDX_WIDTH*SORT_LEN)]),
            .INSPSS_IdxVld       ( INSPSS_IdxVld[i]       ),
            .PSSINS_IdxRdy       ( PSSINS_IdxRdy[i]       )
        );

        assign PSSMap[SRAM_WIDTH*i +: SRAM_WIDTH] = {54'd0, {KNNPSS_CpIdx, INSPSS_Idx[(IDX_WIDTH*SORT_LEN)*i +: (IDX_WIDTH*SORT_LEN)]}};
        
    end
endgenerate

assign PSSKNN_LopRdy = & INS_LopRdy;

assign PSSINS_IdxRdy = {NUM_SORT_CORE{PISO_IN_RDY}};

PISO#(
    .DATA_IN_WIDTH   ( SRAM_WIDTH*NUM_SORT_CORE  ), // (32+1)*10 /96 = 330 /96 <= 4
    .DATA_OUT_WIDTH  ( SRAM_WIDTH  )
)U_PISO(
    .CLK       ( clk            ),
    .RST_N     ( rst_n          ),
    .IN_VLD    ( &INSPSS_IdxVld ),
    .IN_LAST   ( 1'b0           ),
    .IN_DAT    ( PSSMap         ),
    .IN_RDY    ( PISO_IN_RDY  ),
    .OUT_DAT   ( PSSCTR_Map     ),
    .OUT_VLD   ( PSSCTR_MapVld  ),
    .OUT_LAST  (                ),
    .OUT_RDY   ( CTRPSS_MapRdy  )
);


endmodule
