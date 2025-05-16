set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
## Switches
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {code[0]}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {code[1]}]
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports {code[2]}]
set_property -dict { PACKAGE_PIN W17   IOSTANDARD LVCMOS33 } [get_ports {code[3]}]
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports {code[4]}]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports {code[5]}]
set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports {code[6]}]
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports {code[7]}]
set_property -dict { PACKAGE_PIN V2    IOSTANDARD LVCMOS33 } [get_ports {enable}]
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {out_clk}]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]


final dco
//module testbench;

//wire buf_out;
//reg [7:0] code;
//reg enable;
//wire enable_out,out_clk;

//final_ringdco uut(
//.buf_out(buf_out),
//.code(code),
//.enable(enable)
//);

//initial
//begin
//code = 8'b0;
//enable = 1;
//end

//always
//begin
//code = 8'h0d;
//#1000 code = 8'h01;
//#1000 code = 8'h0d;
//#1000 code = 8'h1d;
//#1000 code = 8'he2;
//#4000 $finish;
//end



//endmodule
module final_ringdco(clk,code,enable,out_clk);
output wire out_clk;
input wire [7:0] code;
input wire enable;
input wire clk;
wire enable_out,buf_out;
and a1(enable_out, buf_out, enable);
not n1(out_clk, enable_out);
wire [5:0] sel_cel;
wire [1:0] sel_buf;
assign sel_cel = code[7:2];
assign sel_buf = code[1:0];
cam  c1(clk,del_out, out_clk, sel_cel);
fam f1(buf_out, del_out, sel_buf);
endmodule

//module testbench;

//wire buf_out;
//reg [7:0] code;
//reg enable;
//wire enable_out,out_clk;

//final_ringdco uut(
//.buf_out(buf_out),
//.code(code),
//.enable(enable)
//);

//initial
//begin
//code = 8'b0;
//enable = 1;
//end

//always
//begin
//code = 8'h0d;
//#1000 code = 8'h01;
//#1000 code = 8'h0d;
//#1000 code = 8'h1d;
//#1000 code = 8'he2;
//#4000 $finish;
//end



//endmodule
module final_ringdco(clk,code,enable,out_clk);
output wire out_clk;
input wire [7:0] code;
input wire enable;
input wire clk;
wire enable_out,buf_out;
and a1(enable_out, buf_out, enable);
not n1(out_clk, enable_out);
wire [5:0] sel_cel;
wire [1:0] sel_buf;
assign sel_cel = code[7:2];
assign sel_buf = code[1:0];
cam  c1(clk,del_out, out_clk, sel_cel);
fam f1(buf_out, del_out, sel_buf);
endmodule

aaaaa
`timescale 1ns/1ps


module mux64to1(in, sel, out);

input wire [63:0]in;
input wire [5:0]sel;
output reg out;
integer i;

always @(*)
begin
for(i=0; i<64; i=i+1)
begin
if (sel==i) 
out=in[i];
end
end
endmodule
module clk_divider(
    input clk_in,       // 100 MHz clock input
    output reg clk_out  // 50 MHz clock output
);
    reg [1:0] counter;  // 2-bit counter
    
    always @(posedge clk_in) begin
        if (counter == 1) begin
            clk_out <= ~clk_out;  // Toggle output clock
            counter <= 0;          // Reset counter
        end else begin
            counter <= counter + 1; // Increment counter
        end
    end
endmodule


module delay_cell (
    input wire clk,
    input wire vs1,
    output wire vs5
);
    reg vs2, vs3, vs4;
    reg vs5_reg;
    
    wire clk_out;
    clk_divider cd(clk,clk_out);
    

    always @(posedge clk_out) begin
        vs2 <= vs1;
        vs3 <= vs2;
        vs4 <= vs3;
        vs5_reg <= vs4;
    end

    assign vs5 = vs5_reg;
endmodule



module ring_dco #(parameter N=63)(clk,del_out, del_cel, out_clk, sel_cel);
output wire [63:0] del_cel;
input wire clk;
//input wire enable;
input wire out_clk;
input wire [5:0] sel_cel;
output wire del_out;
/*wire enable_out;
and (enable_out, del_out, enable);
not (out_clk, enable_out);*/
delay_cell delay_cell0(clk,out_clk,del_cel[0]);
genvar x;
generate
 for (x=1; x<=N; x=x+1) begin
 delay_cell dc(clk,del_cel[x-1],del_cel[x]);
 end
endgenerate
mux64to1 mux(del_cel, sel_cel, del_out);
endmodule


module cam(clk,del_out, out_clk, sel_cel);
input wire clk;
output reg del_out;
input wire[5:0] sel_cel;
wire [63:0] del_cel;
reg [5:0] sel_cel_d, sel_cel_d1, sel_cel_d2;
wire del_out_com, del_out_d;
input wire out_clk;
wire del_out_wire;

initial
begin
sel_cel_d2=6'b000000;
sel_cel_d1=6'b000000;
sel_cel_d =6'b000000;
end

always @(posedge del_out) //registers
begin
//$display("cam calls ring dco, compensation block");
//$display("enters cam");
sel_cel_d2 = sel_cel_d1;
sel_cel_d1 = sel_cel_d;
sel_cel_d = sel_cel;
end
ring_dco ro(clk,del_out_d,del_cel, out_clk, sel_cel_d); //ring oscillator
compensation_block cb(del_out_com, del_cel, sel_cel_d, sel_cel_d2); // compensation

always @(del_out_com,sel_cel_d2, sel_cel_d,del_out_d)
begin
//$display ("%d",(sel_cel_d2 < sel_cel));
if (sel_cel_d2 < sel_cel)
begin
//$display("x");
del_out = del_out_com;
end
else
begin
del_out= del_out_d;
end
end

//$display("compensation block working");

endmodule


module compensation_block(del_out_com,del_cel, sel_cel_d, sel_cel_d2);
output reg del_out_com;
input wire [63:0] del_cel;
input wire [5:0] sel_cel_d, sel_cel_d2;
integer i=0;
integer j=0;
integer m, n;
always @(sel_cel_d, sel_cel_d2)
begin
m =sel_cel_d2;
n= sel_cel_d;
end
always @(sel_cel_d, del_cel, m, n)
begin
if (sel_cel_d<=m)
del_out_com = del_cel[m];
else
begin
del_out_com = 0;
i=n;
for (j=0; j<=64; j=j+1)
begin
if(j>=m && j<=i)
del_out_com = del_cel[j] | del_out_com;
end
end
end
endmodule



module mux2to1(out, i0,i1,s);
output reg out;
input wire i0, i1,s;
always @(i0,i1,s)
begin
if (s==0)
out = i0;
else
out = i1;
//$display("last mux working");
end

endmodule

module buf_struct(out,in,clk);
output reg out;
input wire in;
input wire clk;
wire sel=0;
always@(posedge clk)
begin 
case (sel)
1'b0:  out =in;
1'b1:  out = 0;
endcase
//sel=0;
end
endmodule

module fam(buf_out, del_out, sel_buf);
output reg buf_out;
input wire del_out;
input wire [1:0] sel_buf;
wire out1,out2,out3,out4;
buf_struct bf0(out1,del_out);
buf_struct bf1(out2,out1);
buf_struct bf2(out3,out2);
buf_struct bf3(out4,out3);
always @(*)
begin 
case (sel_buf)
2'b00: buf_out = out1;
2'b01: buf_out = out2;
2'b10: buf_out = out3;
2'b11: buf_out = out4;
endcase
end
endmodule