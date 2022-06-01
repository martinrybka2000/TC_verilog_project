module main(clk_main, switch_inWombat, switch_inDanger, switch_Damaged, switch_Immobilized, LEDs);

    input clk_main;

    input switch_inWombat;
    input switch_inDanger;
    input switch_Damaged;
    input switch_Immobilized;
   
    output [7:0] LEDs;
   
    wire kabel_clk_10ms;
    wire kabel_clk_333ms;
 
    wire kabel_inWombat;
    wire kabel_inDanger;
    wire kabel_Damaged;
    wire kabel_Immobilized;

    wire kabel_chuckles_i_m_in_danger;

    wire [7:0] kable_LEDs;

    divider div_10ms  (clk_main, 250000,  kabel_clk_10ms); // 0.01 * 50 000 000 / 2
    divider div_333ms (clk_main, 8325000, kabel_clk_333ms); // 0.333 * 50 000 000 / 2
   
    Debouncer inCombat      (kabel_clk_10ms, switch_inWombat,    kabel_inWombat);
    Debouncer inDanger      (kabel_clk_10ms, switch_inDanger,    kabel_inDanger);
    Debouncer Damaged       (kabel_clk_10ms, switch_Damaged,     kabel_Damaged);
    Debouncer Immobilized   (kabel_clk_10ms, switch_Immobilized, kabel_Immobilized);

    chuckles_i_m_in_danger yes   (kabel_clk_10ms,    kabel_inDanger,               kabel_Damaged,  kabel_Immobilized, kabel_chuckles_i_m_in_danger);
    counter selfBoom             (kabel_clk_10ms,    kabel_chuckles_i_m_in_danger, kabel_inWombat, kable_LEDs);
    epilepsy my_eyes             (kabel_clk_333ms,   kabel_inWombat,               kable_LEDs,     LEDs);

endmodule

module chuckles_i_m_in_danger(clk, danger ,damaged, immobilized, i_m_fucked);
    input clk;
    input danger;
    input damaged;
    input immobilized;
    output reg i_m_fucked;
   
    // checking for 2 of 3 inputs
    always @(posedge clk) begin
        if((danger && damaged) || (danger && immobilized) || (damaged && immobilized)) begin
            i_m_fucked <= 1; // yes
        end
        else begin
            i_m_fucked <= 0; // no
        end
    end
   
endmodule

module epilepsy(clk_3Hz, enable, in_cnt, display);
    input clk_3Hz;
    input enable;
    input[7:0] in_cnt;
    output reg[7:0] display = 0;

    reg CHADflag = 0; // blocking all inputs on purpose to symulate not working robot

    always @(posedge clk_3Hz) begin
      if((enable && CHADflag == 0)) begin
        display <= (8'b11111111 ^ display) & in_cnt;    // just displaying
      end
      else begin
        display <= 0;  // if robot goes out of combat then reset
      end

      if(in_cnt == 8'b00000000 || CHADflag == 1) begin  // if dead then light up all LEDs and block changing its state
        CHADflag <= 1;
        display <= 8'b11111111;
      end
      
    end
endmodule

module divider(clk, bicycles, out); //just one divider module, reqiure how many cycles to wait
    input clk;
    input [24:0] bicycles; // defing input and its limitation
    output out;

    reg flag = 0;
    reg [24:0] cnt = 0;

    assign out = flag;

    always @(posedge clk) begin
        cnt <= (cnt + 1);
        if(cnt > bicycles) begin
            flag <= !flag;
            cnt <= 0;
        end
    end
endmodule

module Debouncer(clk, in, out);
    input clk;
    input in;
    reg [3:0] cnt = 0;
    reg [3:0] cnt2 = 0;
    reg flag = 1;
    reg flag2 = 0;
    output reg out;

    always @(posedge clk) begin

        if(in == 1) begin
            cnt <= cnt + 1;
            if((cnt >= 3) & flag) begin // 30ms
                out <= 1;
                flag <= 0;
            end
            cnt2 <= 0;
            flag2 <= 1;
        end

        else begin
            cnt2 <= cnt2 + 1;
            if((cnt2 >= 3) & flag2) begin
                out <= 0;
                flag2 <= 0;
            end
            cnt <= 0;
            flag <= 1;
        end
    end
endmodule

module counter(clk, enable, reset, cnt_out);
    input clk;
    input enable;
    input reset;
    output[7:0] cnt_out;
   
    reg [6:0] cnt1s = 0;
    reg [7:0] cnt = 255;

    assign cnt_out = cnt;

    always @(posedge clk) begin

        if(enable && reset && cnt > 0) begin  // couting from 8s to 0s
            cnt1s <= cnt1s + 1;
            if(cnt1s >= 100) begin  // couting to 1s from the 10ms timer
                cnt <= cnt >> 1;
                cnt1s <= 0;
            end
        end

        if(!reset) begin // reseting the counter
            cnt <= 255;
            cnt1s <= 0;
        end

    end
endmodule