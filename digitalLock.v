module digitalLock #(
	parameter numberOfDigits=4			//length of sequence parameter
)
(
	input clock, 
   input reset,
	input [3:0] key,
	input timeoutError,		  //input from counter module
	output reg  reEnterLock,
	output reg [3:0] state,   //can be commented out if not debugging 
	output reg lock,
	output reg [3:0] bitNumber,
	output reg [6:0] display0,		//used to display key press
	output reg [6:0] display1,		//used to display current mode of system
	output reg [6:0] display2		//used to display error
);

reg [(4*numberOfDigits)-1:0] setLock; //used to hold locking sequence
reg error;
reg [3:0] previousState;

/*state machine register. Declared as output port for debugging purpose.
  Can be uncommented if not debugging. */
//reg [3:0] state;	

//Local Parameters used to define state names
localparam INITIAL     = 4'b1111;
localparam KEY_PRESSED = 4'b0001;
localparam IDLE        = 4'b0010;
localparam ERROR       = 4'b0100;
localparam DISPLAY     = 4'b1000;

initial begin
	bitNumber<=4'b0000;
	error<=1'b0;
	display0<=7'b1111111;
	display1<=7'b1111111;
	display2<=7'b1111111;
	state<=INITIAL;
end

//outputs for each state
always @ (state) begin

	case (state)
		INITIAL : begin //state INITIAL behaviour
			display2<=7'b1111111;
			if(reset==1'b0) begin
				display1<=7'b1000001;
			end
			display0<=7'b1111111;
	   end
      KEY_PRESSED: begin //state KEY_PRESSED behaviour
			display2<=7'b1111111;
			case(key)		//output display0 is dependent on key input
				4'b1110:display0<=7'b1111001;
				4'b1101:display0<=7'b0100100;
				4'b1011:display0<=7'b0110000;
				4'b0111:display0<=7'b0011001;
			endcase
      end
		IDLE: begin //state IDLE behaviour
			display0<=7'b1111111;
			//executed if required number of keys are pressed
			if(bitNumber==(numberOfDigits)) begin
				if(lock==1'b1) begin
					display1<=7'b1000001;
				end
				else begin 
					if(reEnterLock==1'b0 && lock==1'b0) begin
						display1<=7'b0101111;
					end	
					else begin
						display1<=7'b1000111;
					end	
				end
			end
		end		
		ERROR: begin //state ERROR behaviour
			if(error==1'b1 || timeoutError==1'b1) begin
				display2<=7'b0000100;
			end
		end
		DISPLAY: begin //state DISPLAY behaviour
			if(lock==1'b1) begin
				display1<=7'b1000111;
			end
			else begin 
				if(reEnterLock==1'b1 && lock==1'b0) begin
					display1<=7'b0101111;
				end	
				else begin
					display1<=7'b1000001;
				end	
			end
		end
   endcase
end


//state transitions, which are synchronous
always @(posedge clock or posedge reset) begin
    if (reset) begin
        bitNumber<=4'b0000;
    end else begin
        case (state)
				INITIAL: begin		//state INITIAL behaviour
					if(reset==1'b0) begin
						lock<=1'b0;
						reEnterLock<=1'b0;
					end
					bitNumber<=4'b0000;
					previousState<=INITIAL;
					//state transition if a key is pressed
					if(key!=4'b1111) begin
						state<= KEY_PRESSED;
					end				
				end	 
            KEY_PRESSED: begin //state KEY_PRESSED behaviour
               //state transition if key is released
					if(key==4'b1111) begin
						state <= IDLE;
				   end
					if(previousState!=KEY_PRESSED) begin
						//sequence is set
						if(lock==1'b0 && reEnterLock==1'b0) begin
							setLock[((bitNumber*4)+3)-:4]<=key;
						end
						//sequence is verified
						else begin
							if(setLock[((bitNumber*4)+3)-:4] != key) begin
								error<=1'b1;
							end
						end
						bitNumber<=bitNumber+1;
					end
					previousState<=KEY_PRESSED;		
					//state transition if error occurs
				   if(error==1'b1 || timeoutError==1'b1) begin
						state<=ERROR;
			  	   end
            end
				IDLE: begin  //state IDLE behaviour
					//state transition if error occurs
					if(timeoutError==1'b1) begin
						state<=ERROR;
			  	   end
					//executed if required number of keys are pressed
					if(bitNumber==(numberOfDigits)) begin
						//system mode changes from locked to unlocked mode
						if(lock==1'b1) begin		
							lock<=1'b0;
							reEnterLock<=1'b0;
						end
						else begin 
							//system mode changes from unlocked to re-enter mode
							if(reEnterLock==1'b0 && lock==1'b0) begin
								lock<=1'b0;
								reEnterLock<=1'b1;
							end	
							//system mode changes from re-enter to locked mode
							else begin
								lock<=1'b1;
								reEnterLock<=1'b0;
							end	
						end
						bitNumber<=4'b0000;
				   end
					previousState<=IDLE;
					//state transition if a key is pressed
					if(key!=4'b1111) begin  
						state<= KEY_PRESSED;
					end
				end
				ERROR: begin //state ERROR behaviour
					if(reEnterLock==1'b1) begin
						reEnterLock<=1'b0;
						lock<=1'b0;	
					end
					error<=1'b0;
					bitNumber<=4'b0000;
					//state transition if error is cleared
					if(error==1'b0 && timeoutError==1'b0) begin
						state<=DISPLAY;
					end
				end
				DISPLAY: begin  //state DISPLAY behaviour
					//state transition to start detecting sequence
					if(key==4'b1111) begin
						state<=IDLE;
					end	
				end
				default: begin
					state <= KEY_PRESSED;             
				end 
        endcase
	end
end

endmodule
