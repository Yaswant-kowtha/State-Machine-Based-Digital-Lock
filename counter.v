/*Module counter is used to check key timeouts.
  If key is pressed and held for 10 seconds or 
  key is not pressed for 10 seconds, timeout occurs.
  If timeout occurs since any key is not pressed, a key must be pressed 
  to make it active. If timeout occurs since any key is pressed and held,
  the module becomes active once key is released. */
module counter #(
	parameter frequency=50000000,		//input clock frequency
	parameter timeoutSeconds=10		//time the system should wait for timeout
)
(
	input clock,			
	input reset,
	input [3:0] key,
	output reg error
);
integer idleCount=0;			//counter to count key not pressed time
integer keyCount=0;			//counter to count key pressed time
reg [3:0] keyError=4'b1111; //holds value of key for which timeout occurs

initial begin
	error=1'b0;		//value of output error is initialised
end

always @ (posedge clock) begin
	if(reset) begin	//when reset, counters are reset to 0 and error is cleared
		idleCount<=0;
		keyCount<=0;
		error=1'b0;
	end
	else begin
		if(key!=keyError) begin	//when key not equal to timeout key
			error<=1'b0;
		end
		if(key==4'b1111) begin	//executed if no key is pressed
			keyCount<=0;		//counter for key pressed state is set to 0
			idleCount<=idleCount+1; //counter for key not pressed state is incremented
			//checks if counter value equals timeout value 
			if(idleCount==(timeoutSeconds*frequency)) begin
				error<=1'b1;
				keyError<=4'b1111;
			end
		end
		else begin		//executed if any key is pressed
			idleCount<=0;  //counter for key not pressed state is set to 0
			keyCount<=keyCount+1;	//counter for key pressed state is incremented
			//checks if counter value equals timeout value
			if(keyCount==(timeoutSeconds*frequency)) begin
				error<=1'b1;
				keyError<=key;
			end
		end
	end
end

endmodule
