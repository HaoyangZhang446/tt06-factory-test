`default_nettype none

module alarm(
    clk, 
    reset, 
    in, 
    out,
    counter
    );
    input clk;
    input reset;    // Synchronous reset
    input in;
    output reg [7:0] out;//  
    output reg [4:0] counter;
    
    wire clean_in;
    clean_button btn(
        .async_btn   (in)            ,
        .clk         (clk)           ,
        .clean       (clean_in)
    );

    // Fill in state name declarations
	parameter Idle=2'b01, AlarmSet=2'b10, Alerting=2'b11;
    reg [1:0] present_state, next_state;

    always @(posedge clk) begin
        if (reset) begin  
            present_state <=Idle;
        end 
        else begin
            present_state <= next_state;   
        end
    end
    
    always @(posedge clk ) begin
        if (reset || counter == 31) begin
            counter <= 5'd0;
        end
        if (present_state == AlarmSet)begin
            counter <= counter + 5'd1;
        end
    end

    always @(*)begin
            case (present_state)
                Idle: next_state = ~clean_in ? AlarmSet : Idle;
                AlarmSet: next_state = (counter == 5'd31) ? Alerting : AlarmSet ;
                Alerting: next_state = ~clean_in ? Idle : Alerting;
                default:   next_state = 2'b0;
            endcase
    end
    
    always @(*)begin
            case (present_state)
                Idle:           out = 8'b0;
                AlarmSet:       out = 8'b0;
                Alerting:       out = 8'b1;
                default:        out = 8'b0;
            endcase
    end
    
endmodule

module clean_button(
	input async_btn,
	input clk,
	output clean
);

reg down_press = 1;
reg[15:0] press_reset = 16'h0004;

assign clean = down_press;

always @(posedge clk) begin
	if (clk) begin

		if (~down_press) begin
			down_press = 1;
		end

		if (!async_btn && press_reset == 0) begin
			down_press = 0;
			press_reset = 16'hFFFF;
		end

		else if (async_btn && press_reset > 0) begin
			press_reset = press_reset - 16'h0001;
		end

	end

end

endmodule
