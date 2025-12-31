// to adapt to when ball hits paddle:
// replace reset KEY[0] and KEY[1] with player 2 and player 1 score conditions respectively

// HEX 1 and 0 is for points that go up to 9
// player wins game when score goes up to 9

// for best of three, add count 1 when player wins game

module score (CLOCK_50, Resetn,  player1, player2, HEX1, HEX0, HEX3, HEX2, HEX5, HEX4);
    input CLOCK_50;
    //input [3:0] KEY;
	 input Resetn, player1, player2;
    output [6:0] HEX1; // Player 1 score (goes up to 9)
    output [6:0] HEX0; // Player 2 score

    output [6:0] HEX3; // Player 1 # of rounds won
    output [6:0] HEX2; // Player 2 # of rounds won

    output [6:0] HEX5; // Player 1 winner display (1 if they won)
    output [6:0] HEX4; // Player 2 winner display

    wire clk;
    wire reset;
    wire player1Inc_raw, player2Inc_raw;
    wire player1Inc, player2Inc;
    wire resetScores, resetScoresEdge;
    wire [3:0] player1Score, player2Score;
    wire [3:0] p1RoundsWon, p2RoundsWon;
    wire [3:0] p1Winner, p2Winner;
    wire slowedClock; // if not slowed, the clock goes up to 9 right away and there's lots of flickering
	wire player1IncInitial, player2IncInitial;

    // Assignments
    assign clk = CLOCK_50;
    assign reset = ~Resetn; // press key 0 to reset
    assign player1IncInitial = player1; // replace w win condition: player 1 score increases by 1 (these are processed later bc there's flickering)
    assign player2IncInitial = player2; // replace w win condition: player 2 score increases by 1

    // Slow down clock
    slowClock slow (clk, reset, slowedClock);

    // Edge detectors for player increments
    edgeDetector player1IncreaseEdgeChecker (slowedClock, player1IncInitial, player1Inc);
    edgeDetector player2IncreaseEdgeChecker (slowedClock, player2IncInitial, player2Inc);

    // Scoring registers
    register scoreRegister (slowedClock, reset, player1Inc, player2Inc, resetScoresEdge, player1Score, player2Score);

    // Round checker
    roundChecker round (slowedClock, reset, player1Score, player2Score, p1RoundsWon, p2RoundsWon, resetScores);

    // Edge detector for resetScores or else theres flickering
    edgeDetector ed_resetScores (slowedClock, resetScores, resetScoresEdge);

    // Win condition
    win winCond (slowedClock, reset, p1RoundsWon, p2RoundsWon, p1Winner, p2Winner);

    // 7-segment display decoders for scores
    decoder score1 (player1Score, HEX1);
    decoder score2 (player2Score, HEX0);

    // Wires for decoder outputs
    wire [6:0] wireHEX3, wireHEX2, wireHEX5, wireHEX4;

    // Decoders for rounds won and winner displays
    decoder p1Round (p1RoundsWon, wireHEX3);
    decoder p2Round (p2RoundsWon, wireHEX2);
    decoder p1WinLose (p1Winner, wireHEX5);
    decoder p2WinLose (p2Winner, wireHEX4);

    // Registers for display outputs
    reg [6:0] okHEX3, okHEX2, okHEX5, okHEX4;

    // if 0 is pressed, all the lights are off
    // if there is time, make everything go back to zero
    always @(posedge slowedClock or posedge reset) begin // if I get rid of the posedge reset, KEY 0 doesn't make everything 0
        if (reset) begin
            okHEX3 <= 7'b1111111;
            okHEX2 <= 7'b1111111;
            okHEX5 <= 7'b1111111;
            okHEX4 <= 7'b1111111;
        end else begin
            okHEX3 <= wireHEX3;
            okHEX2 <= wireHEX2;
            okHEX5 <= wireHEX5;
            okHEX4 <= wireHEX4;
        end
    end

    // Assign the registered outputs to the HEX outputs
    assign HEX3 = okHEX3;
    assign HEX2 = okHEX2;
    assign HEX5 = okHEX5;
    assign HEX4 = okHEX4;
endmodule

module edgeDetector(clk, in, out);
    input clk;
    input in;
    output reg out;

    reg risingEdge;

    always @(posedge clk) begin
        out <= in & ~risingEdge; // Detect rising edge
        risingEdge <= in;
    end
endmodule


module slowClock(clk, reset, slowedClock);
    input clk;
    input reset;
    output reg slowedClock;

    reg [18:0] count;

    parameter SLOWTHIS = 250_000; // 50,000,000 / (2 * 100 Hz)

    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            slowedClock <= 0;
        end else begin
            if (count >= (SLOWTHIS - 1)) begin
                count <= 0;
                slowedClock <= ~slowedClock;
            end else begin
                count <= count + 1;
            end
        end
    end
endmodule

module register (clk, reset, player1Inc, player2Inc, resetScores, player1Score, player2Score);
    input clk;
    input reset;
    input player1Inc; // increment signal for Player 1 on edge
    input player2Inc; // increment signal for Player 2 on edge
    input resetScores; // reset scores signal on edge
    output reg [3:0] player1Score;
    output reg [3:0] player2Score;

    always @(posedge clk) begin
        if (reset || resetScores) begin
            player1Score <= 4'b0000;
            player2Score <= 4'b0000;
        end else begin
            if (player1Inc && player1Score < 4'b1001) // Less than 9
                player1Score <= player1Score + 4'b0001;
            if (player2Inc && player2Score < 4'b1001) // Less than 9
                player2Score <= player2Score + 4'b0001;
        end
    end
endmodule

module roundChecker (clk, reset, player1Score, player2Score, p1RoundsWon, p2RoundsWon, resetScores);
    input clk;
    input reset;
    input [3:0] player1Score;
    input [3:0] player2Score;
    output reg [3:0] p1RoundsWon;
    output reg [3:0] p2RoundsWon;
    output reg resetScores;

    reg roundWon;

    always @(posedge clk) begin
        if (reset) begin
            p1RoundsWon <= 4'b0000;
            p2RoundsWon <= 4'b0000;
            resetScores <= 1'b0;
            roundWon <= 1'b0;
        end else begin
            resetScores <= 1'b0; // Default value
            if (!roundWon) begin
                // Check if a player has won a round
                if (player1Score == 4'b1001 && player2Score < 4'b1001) begin
                    p1RoundsWon <= p1RoundsWon + 1;
                    resetScores <= 1'b1; // reset scores
                    roundWon <= 1'b1;
                end else if (player2Score == 4'b1001 && player1Score < 4'b1001) begin
                    p2RoundsWon <= p2RoundsWon + 1;
                    resetScores <= 1'b1;
                    roundWon <= 1'b1;
                end
            end else if (player1Score == 4'b0000 && player2Score == 4'b0000) begin
                roundWon <= 1'b0;
            end
        end
    end

endmodule

module win (clk, reset, p1RoundsWon, p2RoundsWon, p1Winner, p2Winner);
    input clk;
    input reset;
    input [3:0] p1RoundsWon;
    input [3:0] p2RoundsWon;
    output reg [3:0] p1Winner;
    output reg [3:0] p2Winner;

    reg gameWon;

    always @(posedge clk) begin
        if (reset) begin
            p1Winner <= 4'b0000;
            p2Winner <= 4'b0000;
            gameWon <= 1'b0;
        end else if (!gameWon) begin
            if (p1RoundsWon >= 4'b0010) begin  // Player 1 wins best of three
                p1Winner <= 4'b0001;
                p2Winner <= 4'b0000;
                gameWon <= 1'b1;
            end else if (p2RoundsWon >= 4'b0010) begin  // Player 2 wins best of three
                p1Winner <= 4'b0000;
                p2Winner <= 4'b0001;
                gameWon <= 1'b1;
            end else begin
                p1Winner <= 4'b0000;
                p2Winner <= 4'b0000;
            end
        end
    end

endmodule

module decoder (binaryScore, display);
    input [3:0] binaryScore;
    output reg [6:0] display;

    always @(*) begin
        case (binaryScore)
            4'b0000: display = 7'b1000000; // 0
            4'b0001: display = 7'b1111001; // 1
            4'b0010: display = 7'b0100100; // 2
            4'b0011: display = 7'b0110000; // 3
            4'b0100: display = 7'b0011001; // 4
            4'b0101: display = 7'b0010010; // 5
            4'b0110: display = 7'b0000010; // 6
            4'b0111: display = 7'b1111000; // 7
            4'b1000: display = 7'b0000000; // 8
            4'b1001: display = 7'b0010000; // 9
            default: display = 7'b1111111; // nothing is lit
        endcase
    end
endmodule

