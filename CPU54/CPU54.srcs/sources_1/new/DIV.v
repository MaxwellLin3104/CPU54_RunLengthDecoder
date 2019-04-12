`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/28 20:36:24
// Design Name: 
// Module Name: DIV
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


module DIV( 
    input signed [31:0]dividend,//������ 
    input signed [31:0]divisor,//���� 
    input start,//������������  
    input clock, 
    input reset, 
    output [31:0]q,//�� 
    output reg [31:0]r,//����     
    output reg busy,//������æ��־λ 
    output reg over
);
reg[5:0]count; 
reg signed [31:0] reg_q; 
reg signed [31:0] reg_r; 
reg signed [31:0] reg_b; 
reg r_sign; 

wire [32:0] sub_add = r_sign?({reg_r,q[31]} + {1'b0,reg_b}):({reg_r,q[31]} - {1'b0,reg_b});//�ӡ������� 

// assign q = reg_q;    
// wire signed[31:0] tq=(dividend[31]^divisor[31])?(-reg_q):reg_q;
assign q = reg_q;     
always @ (posedge clock or posedge reset)
begin 
    if (reset)
        begin//���� 
            count <=0; 
            busy <= 0; 
            over<=0;
        end
    else
        begin 
            if (start) 
                begin//��ʼ�������㣬��ʼ�� 
                    reg_r <= 0; 
                    r_sign <= 0; 
                    count <= 0; 
                    busy <= 1; 
                    if(dividend<0)
                        reg_q <= -dividend;
                    else
                        reg_q <= dividend;
                    if(divisor<0)
                        reg_b <= -divisor; 
                    else
                        reg_b <= divisor; 
                end 
            else if (busy) 
                begin
                    if(count<=31)
                        begin 
                            reg_r <= sub_add[31:0];//�������� 
                            r_sign <= sub_add[32];//���Ϊ�����´���� 
                            reg_q <= {reg_q[30:0],~sub_add[32]};//����
                            count <= count +1;//��������һ 
                        end
                    else
                        begin
                            if(dividend[31]^divisor[31])
                                reg_q<=-reg_q;
                            if(!dividend[31])
                                r<=r_sign? reg_r + reg_b : reg_r;
                            else
                                r<=-(r_sign? reg_r + reg_b : reg_r);
                            busy <= 0;
                            over <= 1;
                        end
                end
            else
            over<=0;
        end 
end 
endmodule