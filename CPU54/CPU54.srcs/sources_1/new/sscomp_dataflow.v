`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/21 20:52:06
// Design Name: 
// Module Name: Dataflow
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sccomp_dataflow(
input clk_in,
input reset,
input [15:0] sw,
output [7:0] o_seg,
output [7:0] o_sel,
output hsync,
output vsync,
output [3:0]vga_r,
output [3:0]vga_g,
output [3:0]vga_b
    );
wire locked;
wire exc;
wire [31:0]status;
   
wire [31:0]rdata;
wire [31:0]wdata;
wire IM_R,DM_CS,DM_R,DM_W;
wire [31:0]inst,pc,addr;
wire inta,intr;
wire clk;
wire [31:0]data_fmem;
wire [31:0]data_fvga;
wire rst=reset|~locked;
wire [31:0]ip_in;
wire seg7_cs,switch_cs;

assign ip_in = pc-32'h00400000;

wire dmem_cs;
wire vga_cs;
wire clk_vga;

clk_wiz_0 clk_inst
   (
    // Clock out ports
    .clk_out1(clk),     // output clk_out1
    .clk_out2(clk_vga),     // output clk_out2
    // Status and control signals
    .reset(reset), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk_in)); 

//clk_div #(3)cpu_clk(clk_in,clk);

/*��ַ����*/
// io_sel io_mem(addr, DM_CS, DM_W, DM_R, seg7_cs, switch_cs);
io_sel io_mem(
   .addr(addr),
   .cs(DM_CS),
   .sig_w(DM_W),
   .sig_r(DM_R),
   .dmem_cs(dmem_cs),
   .vga_cs(vga_cs)
    );

CPU54 sccpu(clk,rst,inst,rdata,pc,addr,wdata,IM_R,DM_CS,DM_R,DM_W,intr,inta);
//rdata ��dmem�ж�ȡ��������


/*ָ��洢��*/
//imem imem(ip_in[12:2],inst);
//imemory im(pc,inst);
dist_iram_ip IMEM (
  .a(ip_in[12:2]),      // input wire [10 : 0] a
  .spo(inst)  // output wire [31 : 0] spo
);

wire [31:0]addr_in=addr-32'h10010000;

/*���ݴ洢��*/
dist_dmem_ip DMEM (
  .a(addr_in[16:2]),      // input wire [10 : 0] a
  .d(wdata),      // input wire [31 : 0] d
  .clk(clk),  // input wire clk
  .we(dmem_cs&DM_W),    // input wire we
  .spo(data_fmem)  // output wire [31 : 0] spo
);


//dmem scdmem(~clk,reset,DM_CS,DM_W,DM_R,addr-32'h10010000,wdata,data_fmem);



// seg7x16 seg7(clk, reset, seg7_cs, wdata, o_seg, o_sel);

// sw_mem_sel sw_mem(switch_cs, sw, data_fmem, rdata);

    vga vga_inst(
.clk_in(clk),//50M
.clk_in_25(clk_vga),
.rst_in(rst),
.i_data(wdata),
.we(vga_cs&DM_W),
.hsync(hsync),
.vsync(vsync),
.vga_r(vga_r),
.vga_g(vga_g),
.vga_b(vga_b),
.intr(intr),
.o_data(data_fvga)
    );

  assign rdata = vga_cs?data_fvga:data_fmem;
   
endmodule
