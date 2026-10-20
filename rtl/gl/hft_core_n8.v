module orderbook_unsorted (
	clk_i,
	rst_ni,
	valid_i,
	op_i,
	side_i,
	price_i,
	qty_i,
	best_bid_price_o,
	best_bid_qty_o,
	best_ask_price_o,
	best_ask_qty_o,
	bid_qty_sum_o,
	ask_qty_sum_o,
	error_o
);
	reg _sv2v_0;
	parameter signed [31:0] N = 8;
	input wire clk_i;
	input wire rst_ni;
	input wire valid_i;
	input wire op_i;
	input wire side_i;
	localparam [31:0] orderbook_pkg_PRICE_WIDTH = 9;
	input wire [8:0] price_i;
	localparam [31:0] orderbook_pkg_QTY_WIDTH = 8;
	input wire [7:0] qty_i;
	output wire [8:0] best_bid_price_o;
	output wire [7:0] best_bid_qty_o;
	output wire [8:0] best_ask_price_o;
	output wire [7:0] best_ask_qty_o;
	output wire [($clog2(N) + orderbook_pkg_QTY_WIDTH) - 1:0] bid_qty_sum_o;
	output wire [($clog2(N) + orderbook_pkg_QTY_WIDTH) - 1:0] ask_qty_sum_o;
	output wire error_o;
	localparam signed [31:0] SUM_WIDTH = $clog2(N) + orderbook_pkg_QTY_WIDTH;
	localparam signed [31:0] IDX_WIDTH = $clog2(N);
	reg [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] bid_prices_d;
	reg [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] bid_prices_q;
	reg [(N * orderbook_pkg_QTY_WIDTH) - 1:0] bid_qtys_d;
	reg [(N * orderbook_pkg_QTY_WIDTH) - 1:0] bid_qtys_q;
	reg [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] ask_prices_d;
	reg [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] ask_prices_q;
	reg [(N * orderbook_pkg_QTY_WIDTH) - 1:0] ask_qtys_d;
	reg [(N * orderbook_pkg_QTY_WIDTH) - 1:0] ask_qtys_q;
	reg error_d;
	reg error_q;
	reg [SUM_WIDTH - 1:0] bid_sum_d;
	reg [SUM_WIDTH - 1:0] bid_sum_q;
	reg [SUM_WIDTH - 1:0] ask_sum_d;
	reg [SUM_WIDTH - 1:0] ask_sum_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			error_q <= 1'b0;
			bid_prices_q <= 1'sb0;
			bid_qtys_q <= 1'sb0;
			ask_prices_q <= 1'sb0;
			ask_qtys_q <= 1'sb0;
			bid_sum_q <= 1'sb0;
			ask_sum_q <= 1'sb0;
		end
		else begin
			error_q <= error_d;
			bid_prices_q <= bid_prices_d;
			bid_qtys_q <= bid_qtys_d;
			ask_prices_q <= ask_prices_d;
			ask_qtys_q <= ask_qtys_d;
			bid_sum_q <= bid_sum_d;
			ask_sum_q <= ask_sum_d;
		end
	function automatic [IDX_WIDTH - 1:0] first;
		input reg [N - 1:0] array;
		reg [N - 1:0] lsb;
		begin
			lsb = array & -array;
			first = 1'sb0;
			begin : sv2v_autoblock_1
				reg signed [31:0] i;
				for (i = 0; i < N; i = i + 1)
					if (lsb[i])
						first = first | i[IDX_WIDTH - 1:0];
			end
		end
	endfunction
	function automatic [((orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH) - 1:0] pick;
		input reg [((orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH) - 1:0] a;
		input reg [((orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH) - 1:0] b;
		input reg want_max;
		reg [0:1] _sv2v_jump;
		begin
			_sv2v_jump = 2'b00;
			if (a[orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1)-:((IDX_WIDTH + 7) >= (IDX_WIDTH + 0) ? ((orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1)) - (IDX_WIDTH + 0)) + 1 : ((IDX_WIDTH + 0) - (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1))) + 1)] == 0) begin
				pick = b;
				_sv2v_jump = 2'b11;
			end
			if (_sv2v_jump == 2'b00) begin
				if (b[orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1)-:((IDX_WIDTH + 7) >= (IDX_WIDTH + 0) ? ((orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1)) - (IDX_WIDTH + 0)) + 1 : ((IDX_WIDTH + 0) - (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1))) + 1)] == 0) begin
					pick = a;
					_sv2v_jump = 2'b11;
				end
				if (_sv2v_jump == 2'b00) begin
					pick = ((a[32'd9 + (IDX_WIDTH + 7)-:((32'd9 + (IDX_WIDTH + 7)) >= (32'd8 + (IDX_WIDTH + 0)) ? ((32'd9 + (IDX_WIDTH + 7)) - (32'd8 + (IDX_WIDTH + 0))) + 1 : ((32'd8 + (IDX_WIDTH + 0)) - (32'd9 + (IDX_WIDTH + 7))) + 1)] >= b[32'd9 + (IDX_WIDTH + 7)-:((32'd9 + (IDX_WIDTH + 7)) >= (32'd8 + (IDX_WIDTH + 0)) ? ((32'd9 + (IDX_WIDTH + 7)) - (32'd8 + (IDX_WIDTH + 0))) + 1 : ((32'd8 + (IDX_WIDTH + 0)) - (32'd9 + (IDX_WIDTH + 7))) + 1)]) == want_max ? a : b);
					_sv2v_jump = 2'b11;
				end
			end
		end
	endfunction
	function automatic [((orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH) - 1:0] reduce;
		input reg [(N * ((orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH)) - 1:0] arr;
		input reg want_max;
		reg [(N * ((orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH)) - 1:0] tmp;
		begin
			tmp = arr;
			begin : sv2v_autoblock_2
				reg signed [31:0] stride;
				for (stride = 1; stride < N; stride = stride << 1)
					begin : sv2v_autoblock_3
						reg signed [31:0] i;
						for (i = 0; (i + stride) < N; i = i + (stride << 1))
							tmp[((N - 1) - i) * ((orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH)+:(orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH] = pick(tmp[((N - 1) - i) * ((orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH)+:(orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH], tmp[((N - 1) - (i + stride)) * ((orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH)+:(orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH], want_max);
					end
			end
			reduce = tmp[(N - 1) * ((orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH)+:(orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH];
		end
	endfunction
	function automatic [(N * ((orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH)) - 1:0] cand_of;
		input reg [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] prices;
		input reg [(N * orderbook_pkg_QTY_WIDTH) - 1:0] qtys;
		reg signed [31:0] i;
		for (i = 0; i < N; i = i + 1)
			cand_of[((N - 1) - i) * ((orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH)+:(orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH] = {prices[i * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH], qtys[i * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH], i[IDX_WIDTH - 1:0]};
	endfunction
	function automatic signed [SUM_WIDTH - 1:0] sv2v_cast_ED32E_signed;
		input reg signed [SUM_WIDTH - 1:0] inp;
		sv2v_cast_ED32E_signed = inp;
	endfunction
	always @(*) begin : sv2v_autoblock_4
		reg [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] cur_prices;
		reg [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] new_prices;
		reg [(N * orderbook_pkg_QTY_WIDTH) - 1:0] cur_qtys;
		reg [(N * orderbook_pkg_QTY_WIDTH) - 1:0] new_qtys;
		reg [((orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH) - 1:0] worst;
		reg [N - 1:0] equals;
		reg [N - 1:0] empties;
		reg any_eq;
		reg any_empty;
		reg evict;
		reg [IDX_WIDTH - 1:0] eq_idx;
		reg [IDX_WIDTH - 1:0] empty_idx;
		reg pre_error;
		reg signed [9:0] sum_delta;
		if (_sv2v_0)
			;
		bid_prices_d = bid_prices_q;
		bid_qtys_d = bid_qtys_q;
		ask_prices_d = ask_prices_q;
		ask_qtys_d = ask_qtys_q;
		bid_sum_d = bid_sum_q;
		ask_sum_d = ask_sum_q;
		sum_delta = 1'sb0;
		cur_prices = (side_i == 1'd0 ? bid_prices_q : ask_prices_q);
		cur_qtys = (side_i == 1'd0 ? bid_qtys_q : ask_qtys_q);
		new_prices = cur_prices;
		new_qtys = cur_qtys;
		equals = 1'sb0;
		empties = 1'sb0;
		any_eq = 1'b0;
		any_empty = 1'b0;
		evict = 1'b0;
		eq_idx = 1'sb0;
		empty_idx = 1'sb0;
		pre_error = 1'b0;
		worst = 1'sb0;
		error_d = error_q;
		if (valid_i && !error_q) begin
			begin : sv2v_autoblock_5
				reg signed [31:0] i;
				for (i = 0; i < N; i = i + 1)
					begin
						equals[i] = (cur_qtys[i * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] != 0) && (cur_prices[i * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH] == price_i);
						empties[i] = cur_qtys[i * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] == 0;
					end
			end
			any_eq = |equals;
			eq_idx = first(equals);
			any_empty = |empties;
			empty_idx = first(empties);
			pre_error = qty_i == 0;
			if (pre_error)
				error_d = 1'b1;
			else begin
				(* full_case, parallel_case *)
				case (op_i)
					1'd0:
						if (any_eq) begin
							if (qty_i > ({8 {1'sb1}} - cur_qtys[eq_idx * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH]))
								error_d = 1'b1;
							else begin
								new_qtys[eq_idx * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] = cur_qtys[eq_idx * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] + qty_i;
								sum_delta = $signed({2'b00, qty_i});
							end
						end
						else if (any_empty) begin
							new_prices[empty_idx * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH] = price_i;
							new_qtys[empty_idx * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] = qty_i;
							sum_delta = $signed({2'b00, qty_i});
						end
						else begin
							worst = reduce(cand_of(cur_prices, cur_qtys), side_i == 1'd1);
							evict = (side_i == 1'd0 ? price_i > worst[orderbook_pkg_PRICE_WIDTH + (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1))-:((32'd9 + (IDX_WIDTH + 7)) >= (32'd8 + (IDX_WIDTH + 0)) ? ((orderbook_pkg_PRICE_WIDTH + (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1))) - (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH + 0))) + 1 : ((orderbook_pkg_QTY_WIDTH + (IDX_WIDTH + 0)) - (orderbook_pkg_PRICE_WIDTH + (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1)))) + 1)] : price_i < worst[orderbook_pkg_PRICE_WIDTH + (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1))-:((32'd9 + (IDX_WIDTH + 7)) >= (32'd8 + (IDX_WIDTH + 0)) ? ((orderbook_pkg_PRICE_WIDTH + (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1))) - (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH + 0))) + 1 : ((orderbook_pkg_QTY_WIDTH + (IDX_WIDTH + 0)) - (orderbook_pkg_PRICE_WIDTH + (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1)))) + 1)]);
							if (evict) begin
								new_prices[worst[IDX_WIDTH - 1-:IDX_WIDTH] * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH] = price_i;
								new_qtys[worst[IDX_WIDTH - 1-:IDX_WIDTH] * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] = qty_i;
								sum_delta = $signed({2'b00, qty_i}) - $signed({2'b00, worst[orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1)-:((IDX_WIDTH + 7) >= (IDX_WIDTH + 0) ? ((orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1)) - (IDX_WIDTH + 0)) + 1 : ((IDX_WIDTH + 0) - (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1))) + 1)]});
							end
						end
					1'd1:
						if (any_eq && (cur_qtys[eq_idx * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] >= qty_i)) begin
							new_qtys[eq_idx * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] = cur_qtys[eq_idx * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] - qty_i;
							sum_delta = -$signed({2'b00, qty_i});
						end
						else
							error_d = 1'b1;
					default: error_d = 1'b1;
				endcase
				(* full_case, parallel_case *)
				case (side_i)
					1'd0: begin
						bid_prices_d = new_prices;
						bid_qtys_d = new_qtys;
						bid_sum_d = sv2v_cast_ED32E_signed($signed({1'b0, bid_sum_q}) + sum_delta);
					end
					1'd1: begin
						ask_prices_d = new_prices;
						ask_qtys_d = new_qtys;
						ask_sum_d = sv2v_cast_ED32E_signed($signed({1'b0, ask_sum_q}) + sum_delta);
					end
					default: error_d = 1'b1;
				endcase
			end
		end
	end
	reg [((orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH) - 1:0] best_bid;
	reg [((orderbook_pkg_PRICE_WIDTH + orderbook_pkg_QTY_WIDTH) + IDX_WIDTH) - 1:0] best_ask;
	always @(*) begin
		if (_sv2v_0)
			;
		best_bid = reduce(cand_of(bid_prices_q, bid_qtys_q), 1'b1);
		best_ask = reduce(cand_of(ask_prices_q, ask_qtys_q), 1'b0);
	end
	localparam [8:0] orderbook_pkg_DEFAULT_BID = 1'sb0;
	assign best_bid_price_o = (best_bid[IDX_WIDTH + 7-:((IDX_WIDTH + 7) >= (IDX_WIDTH + 0) ? ((IDX_WIDTH + 7) - (IDX_WIDTH + 0)) + 1 : ((IDX_WIDTH + 0) - (IDX_WIDTH + 7)) + 1)] != 0 ? best_bid[orderbook_pkg_PRICE_WIDTH + (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1))-:((32'd9 + (IDX_WIDTH + 7)) >= (32'd8 + (IDX_WIDTH + 0)) ? ((orderbook_pkg_PRICE_WIDTH + (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1))) - (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH + 0))) + 1 : ((orderbook_pkg_QTY_WIDTH + (IDX_WIDTH + 0)) - (orderbook_pkg_PRICE_WIDTH + (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1)))) + 1)] : orderbook_pkg_DEFAULT_BID);
	assign best_bid_qty_o = best_bid[orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1)-:((IDX_WIDTH + 7) >= (IDX_WIDTH + 0) ? ((orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1)) - (IDX_WIDTH + 0)) + 1 : ((IDX_WIDTH + 0) - (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1))) + 1)];
	localparam [8:0] orderbook_pkg_DEFAULT_ASK = 1'sb1;
	assign best_ask_price_o = (best_ask[IDX_WIDTH + 7-:((IDX_WIDTH + 7) >= (IDX_WIDTH + 0) ? ((IDX_WIDTH + 7) - (IDX_WIDTH + 0)) + 1 : ((IDX_WIDTH + 0) - (IDX_WIDTH + 7)) + 1)] != 0 ? best_ask[orderbook_pkg_PRICE_WIDTH + (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1))-:((32'd9 + (IDX_WIDTH + 7)) >= (32'd8 + (IDX_WIDTH + 0)) ? ((orderbook_pkg_PRICE_WIDTH + (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1))) - (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH + 0))) + 1 : ((orderbook_pkg_QTY_WIDTH + (IDX_WIDTH + 0)) - (orderbook_pkg_PRICE_WIDTH + (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1)))) + 1)] : orderbook_pkg_DEFAULT_ASK);
	assign best_ask_qty_o = best_ask[orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1)-:((IDX_WIDTH + 7) >= (IDX_WIDTH + 0) ? ((orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1)) - (IDX_WIDTH + 0)) + 1 : ((IDX_WIDTH + 0) - (orderbook_pkg_QTY_WIDTH + (IDX_WIDTH - 1))) + 1)];
	assign bid_qty_sum_o = bid_sum_q;
	assign ask_qty_sum_o = ask_sum_q;
	assign error_o = error_q;
	initial _sv2v_0 = 0;
endmodule
module orderbook_sorted (
	clk_i,
	rst_ni,
	valid_i,
	op_i,
	side_i,
	price_i,
	qty_i,
	bid_prices_o,
	bid_qtys_o,
	ask_prices_o,
	ask_qtys_o,
	bid_qty_sum_o,
	ask_qty_sum_o,
	error_o
);
	reg _sv2v_0;
	parameter signed [31:0] N = 8;
	input wire clk_i;
	input wire rst_ni;
	input wire valid_i;
	input wire op_i;
	input wire side_i;
	localparam [31:0] orderbook_pkg_PRICE_WIDTH = 9;
	input wire [8:0] price_i;
	localparam [31:0] orderbook_pkg_QTY_WIDTH = 8;
	input wire [7:0] qty_i;
	output wire [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] bid_prices_o;
	output wire [(N * orderbook_pkg_QTY_WIDTH) - 1:0] bid_qtys_o;
	output wire [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] ask_prices_o;
	output wire [(N * orderbook_pkg_QTY_WIDTH) - 1:0] ask_qtys_o;
	output wire [($clog2(N) + orderbook_pkg_QTY_WIDTH) - 1:0] bid_qty_sum_o;
	output wire [($clog2(N) + orderbook_pkg_QTY_WIDTH) - 1:0] ask_qty_sum_o;
	output wire error_o;
	localparam signed [31:0] SUM_WIDTH = $clog2(N) + orderbook_pkg_QTY_WIDTH;
	reg [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] bid_prices_d;
	reg [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] bid_prices_q;
	reg [(N * orderbook_pkg_QTY_WIDTH) - 1:0] bid_qtys_d;
	reg [(N * orderbook_pkg_QTY_WIDTH) - 1:0] bid_qtys_q;
	reg [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] ask_prices_d;
	reg [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] ask_prices_q;
	reg [(N * orderbook_pkg_QTY_WIDTH) - 1:0] ask_qtys_d;
	reg [(N * orderbook_pkg_QTY_WIDTH) - 1:0] ask_qtys_q;
	reg error_d;
	reg error_q;
	reg [SUM_WIDTH - 1:0] bid_sum_d;
	reg [SUM_WIDTH - 1:0] bid_sum_q;
	reg [SUM_WIDTH - 1:0] ask_sum_d;
	reg [SUM_WIDTH - 1:0] ask_sum_q;
	localparam [8:0] orderbook_pkg_DEFAULT_ASK = 1'sb1;
	localparam [8:0] orderbook_pkg_DEFAULT_BID = 1'sb0;
	function automatic [8:0] sv2v_cast_DC923;
		input reg [8:0] inp;
		sv2v_cast_DC923 = inp;
	endfunction
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			error_q <= 1'b0;
			bid_prices_q <= {N {sv2v_cast_DC923(orderbook_pkg_DEFAULT_BID)}};
			bid_qtys_q <= 0;
			ask_prices_q <= {N {sv2v_cast_DC923(orderbook_pkg_DEFAULT_ASK)}};
			ask_qtys_q <= 0;
			bid_sum_q <= 1'sb0;
			ask_sum_q <= 1'sb0;
		end
		else begin
			error_q <= error_d;
			bid_prices_q <= bid_prices_d;
			bid_qtys_q <= bid_qtys_d;
			ask_prices_q <= ask_prices_d;
			ask_qtys_q <= ask_qtys_d;
			bid_sum_q <= bid_sum_d;
			ask_sum_q <= ask_sum_d;
		end
	function automatic [$clog2(N) - 1:0] first;
		input reg [N - 1:0] array;
		reg [N - 1:0] lsb;
		begin
			lsb = array & -array;
			first = 1'sb0;
			begin : sv2v_autoblock_1
				reg signed [31:0] i;
				for (i = 0; i < N; i = i + 1)
					if (lsb[i])
						first = first | i[$clog2(N) - 1:0];
			end
		end
	endfunction
	function automatic signed [SUM_WIDTH - 1:0] sv2v_cast_ED32E_signed;
		input reg signed [SUM_WIDTH - 1:0] inp;
		sv2v_cast_ED32E_signed = inp;
	endfunction
	always @(*) begin : sv2v_autoblock_2
		reg [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] cur_prices;
		reg [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] new_prices;
		reg [(N * orderbook_pkg_QTY_WIDTH) - 1:0] cur_qtys;
		reg [(N * orderbook_pkg_QTY_WIDTH) - 1:0] new_qtys;
		reg [N - 1:0] compares;
		reg [N - 1:0] equals;
		reg any_eq;
		reg [$clog2(N) - 1:0] eq_idx;
		reg [$clog2(N) - 1:0] cmp_idx;
		reg pre_error;
		reg signed [9:0] sum_delta;
		if (_sv2v_0)
			;
		bid_prices_d = bid_prices_q;
		bid_qtys_d = bid_qtys_q;
		ask_prices_d = ask_prices_q;
		ask_qtys_d = ask_qtys_q;
		bid_sum_d = bid_sum_q;
		ask_sum_d = ask_sum_q;
		sum_delta = 1'sb0;
		cur_prices = (side_i == 1'd0 ? bid_prices_q : ask_prices_q);
		cur_qtys = (side_i == 1'd0 ? bid_qtys_q : ask_qtys_q);
		new_prices = cur_prices;
		new_qtys = cur_qtys;
		equals = 1'sb0;
		compares = 1'sb0;
		any_eq = 1'b0;
		eq_idx = 1'sb0;
		cmp_idx = 1'sb0;
		pre_error = 1'b0;
		error_d = error_q;
		if (valid_i && !error_q) begin
			begin : sv2v_autoblock_3
				reg signed [31:0] i;
				for (i = 0; i < N; i = i + 1)
					begin
						equals[i] = (cur_qtys[i * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] != 0) && (cur_prices[i * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH] == price_i);
						compares[i] = (side_i == 1'd0 ? price_i > cur_prices[i * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH] : price_i < cur_prices[i * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH]);
					end
			end
			any_eq = |equals;
			eq_idx = first(equals);
			pre_error = qty_i == 0;
			if (pre_error)
				error_d = 1'b1;
			else begin
				(* full_case, parallel_case *)
				case (op_i)
					1'd0:
						if (any_eq) begin
							if (qty_i > ({8 {1'sb1}} - cur_qtys[eq_idx * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH]))
								error_d = 1'b1;
							else begin
								new_qtys[eq_idx * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] = cur_qtys[eq_idx * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] + qty_i;
								sum_delta = $signed({2'b00, qty_i});
							end
						end
						else if (|compares) begin
							cmp_idx = first(compares);
							begin : sv2v_autoblock_4
								reg signed [31:0] i;
								for (i = 1; i < N; i = i + 1)
									begin
										new_prices[i * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH] = (i > cmp_idx ? cur_prices[(i - 1) * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH] : cur_prices[i * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH]);
										new_qtys[i * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] = (i > cmp_idx ? cur_qtys[(i - 1) * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] : cur_qtys[i * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH]);
									end
							end
							new_prices[cmp_idx * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH] = price_i;
							new_qtys[cmp_idx * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] = qty_i;
							sum_delta = $signed({2'b00, qty_i}) - $signed({2'b00, cur_qtys[(N - 1) * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH]});
						end
					1'd1:
						if (any_eq && (cur_qtys[eq_idx * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] >= qty_i)) begin
							if (cur_qtys[eq_idx * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] == qty_i) begin
								begin : sv2v_autoblock_5
									reg signed [31:0] i;
									for (i = 0; i < (N - 1); i = i + 1)
										begin
											new_prices[i * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH] = (i < eq_idx ? cur_prices[i * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH] : cur_prices[(i + 1) * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH]);
											new_qtys[i * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] = (i < eq_idx ? cur_qtys[i * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] : cur_qtys[(i + 1) * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH]);
										end
								end
								new_prices[(N - 1) * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH] = (side_i == 1'd0 ? orderbook_pkg_DEFAULT_BID : orderbook_pkg_DEFAULT_ASK);
								new_qtys[(N - 1) * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] = 0;
							end
							else
								new_qtys[eq_idx * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] = cur_qtys[eq_idx * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] - qty_i;
							sum_delta = -$signed({2'b00, qty_i});
						end
						else
							error_d = 1'b1;
					default: error_d = 1'b1;
				endcase
				(* full_case, parallel_case *)
				case (side_i)
					1'd0: begin
						bid_prices_d = new_prices;
						bid_qtys_d = new_qtys;
						bid_sum_d = sv2v_cast_ED32E_signed($signed({1'b0, bid_sum_q}) + sum_delta);
					end
					1'd1: begin
						ask_prices_d = new_prices;
						ask_qtys_d = new_qtys;
						ask_sum_d = sv2v_cast_ED32E_signed($signed({1'b0, ask_sum_q}) + sum_delta);
					end
					default: error_d = 1'b1;
				endcase
			end
		end
	end
	assign bid_prices_o = bid_prices_q;
	assign bid_qtys_o = bid_qtys_q;
	assign ask_prices_o = ask_prices_q;
	assign ask_qtys_o = ask_qtys_q;
	assign bid_qty_sum_o = bid_sum_q;
	assign ask_qty_sum_o = ask_sum_q;
	assign error_o = error_q;
	initial _sv2v_0 = 0;
endmodule
module orderbook (
	clk_i,
	rst_ni,
	valid_i,
	op_i,
	side_i,
	price_i,
	qty_i,
	best_bid_price_o,
	best_bid_qty_o,
	best_ask_price_o,
	best_ask_qty_o,
	bid_qty_sum_o,
	ask_qty_sum_o,
	error_o
);
	parameter signed [31:0] N = 8;
	parameter [0:0] UNSORTED = 1'b1;
	input wire clk_i;
	input wire rst_ni;
	input wire valid_i;
	input wire op_i;
	input wire side_i;
	localparam [31:0] orderbook_pkg_PRICE_WIDTH = 9;
	input wire [8:0] price_i;
	localparam [31:0] orderbook_pkg_QTY_WIDTH = 8;
	input wire [7:0] qty_i;
	output wire [8:0] best_bid_price_o;
	output wire [7:0] best_bid_qty_o;
	output wire [8:0] best_ask_price_o;
	output wire [7:0] best_ask_qty_o;
	output wire [($clog2(N) + orderbook_pkg_QTY_WIDTH) - 1:0] bid_qty_sum_o;
	output wire [($clog2(N) + orderbook_pkg_QTY_WIDTH) - 1:0] ask_qty_sum_o;
	output wire error_o;
	generate
		if (UNSORTED) begin : g_unsorted
			orderbook_unsorted #(.N(N)) i_ob(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(valid_i),
				.op_i(op_i),
				.side_i(side_i),
				.price_i(price_i),
				.qty_i(qty_i),
				.best_bid_price_o(best_bid_price_o),
				.best_bid_qty_o(best_bid_qty_o),
				.best_ask_price_o(best_ask_price_o),
				.best_ask_qty_o(best_ask_qty_o),
				.bid_qty_sum_o(bid_qty_sum_o),
				.ask_qty_sum_o(ask_qty_sum_o),
				.error_o(error_o)
			);
		end
		else begin : g_sorted
			wire [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] bid_prices;
			wire [(N * orderbook_pkg_PRICE_WIDTH) - 1:0] ask_prices;
			wire [(N * orderbook_pkg_QTY_WIDTH) - 1:0] bid_qtys;
			wire [(N * orderbook_pkg_QTY_WIDTH) - 1:0] ask_qtys;
			orderbook_sorted #(.N(N)) i_ob(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(valid_i),
				.op_i(op_i),
				.side_i(side_i),
				.price_i(price_i),
				.qty_i(qty_i),
				.bid_prices_o(bid_prices),
				.bid_qtys_o(bid_qtys),
				.ask_prices_o(ask_prices),
				.ask_qtys_o(ask_qtys),
				.bid_qty_sum_o(bid_qty_sum_o),
				.ask_qty_sum_o(ask_qty_sum_o),
				.error_o(error_o)
			);
			assign best_bid_price_o = bid_prices[0+:orderbook_pkg_PRICE_WIDTH];
			assign best_bid_qty_o = bid_qtys[0+:orderbook_pkg_QTY_WIDTH];
			assign best_ask_price_o = ask_prices[0+:orderbook_pkg_PRICE_WIDTH];
			assign best_ask_qty_o = ask_qtys[0+:orderbook_pkg_QTY_WIDTH];
		end
	endgenerate
endmodule
module arb_trader (
	clk_i,
	rst_ni,
	bid_price0_i,
	bid_qty0_i,
	ask_price0_i,
	ask_qty0_i,
	bid_price1_i,
	bid_qty1_i,
	ask_price1_i,
	ask_qty1_i,
	order_filled_i,
	filled_price_i,
	filled_qty_i,
	filled_side_i,
	valid_o,
	market_o,
	side_o,
	price_o,
	qty_o,
	error_o
);
	reg _sv2v_0;
	parameter signed [31:0] ARB_THRESHOLD = 2;
	input wire clk_i;
	input wire rst_ni;
	localparam [31:0] orderbook_pkg_PRICE_WIDTH = 9;
	input wire [8:0] bid_price0_i;
	localparam [31:0] orderbook_pkg_QTY_WIDTH = 8;
	input wire [7:0] bid_qty0_i;
	input wire [8:0] ask_price0_i;
	input wire [7:0] ask_qty0_i;
	input wire [8:0] bid_price1_i;
	input wire [7:0] bid_qty1_i;
	input wire [8:0] ask_price1_i;
	input wire [7:0] ask_qty1_i;
	input wire order_filled_i;
	input wire [8:0] filled_price_i;
	input wire [7:0] filled_qty_i;
	input wire filled_side_i;
	output reg valid_o;
	output reg market_o;
	output reg side_o;
	output reg [8:0] price_o;
	output reg [7:0] qty_o;
	output reg error_o;
	reg [1:0] state_q;
	reg [1:0] state_d;
	reg [8:0] ask_price_q;
	reg [8:0] ask_price_d;
	reg [8:0] bid_price_q;
	reg [8:0] bid_price_d;
	reg [7:0] arb_qty_q;
	reg [7:0] arb_qty_d;
	reg ask_market_q;
	reg ask_market_d;
	reg bid_market_q;
	reg bid_market_d;
	reg [1:0] pending_q;
	reg [1:0] pending_d;
	reg signed [15:0] residual_q;
	reg signed [15:0] residual_d;
	reg error_q;
	reg error_d;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			state_q <= 2'd0;
			ask_price_q <= 1'sb0;
			bid_price_q <= 1'sb0;
			arb_qty_q <= 1'sb0;
			ask_market_q <= 1'sb0;
			bid_market_q <= 1'sb0;
			pending_q <= 1'sb0;
			residual_q <= 1'sb0;
			error_q <= 1'sb0;
		end
		else begin
			state_q <= state_d;
			ask_price_q <= ask_price_d;
			bid_price_q <= bid_price_d;
			arb_qty_q <= arb_qty_d;
			ask_market_q <= ask_market_d;
			bid_market_q <= bid_market_d;
			pending_q <= pending_d;
			residual_q <= residual_d;
			error_q <= error_d;
		end
	always @(*) begin : sv2v_autoblock_1
		reg arb0;
		reg arb1;
		reg [1:0] pend_next;
		reg signed [15:0] res_next;
		reg sell;
		reg [7:0] res_qty;
		reg [8:0] price0;
		reg [8:0] price1;
		reg [7:0] quantity0;
		reg [7:0] quantity1;
		reg liquid0;
		reg liquid1;
		reg market;
		if (_sv2v_0)
			;
		arb0 = 1'b0;
		arb1 = 1'b0;
		sell = 1'b0;
		res_qty = 1'sb0;
		price0 = 1'sb0;
		price1 = 1'sb0;
		quantity0 = 1'sb0;
		quantity1 = 1'sb0;
		liquid0 = 1'b0;
		liquid1 = 1'b0;
		market = 1'b0;
		state_d = state_q;
		ask_price_d = ask_price_q;
		bid_price_d = bid_price_q;
		arb_qty_d = arb_qty_q;
		ask_market_d = ask_market_q;
		bid_market_d = bid_market_q;
		error_d = error_q | (order_filled_i && (pending_q == 0));
		valid_o = 1'sb0;
		market_o = 1'sb0;
		side_o = 1'd0;
		price_o = 1'sb0;
		qty_o = 1'sb0;
		error_o = error_d;
		pend_next = pending_q;
		res_next = residual_q;
		if (!error_d && order_filled_i) begin
			pend_next = pending_q - 1'b1;
			if (filled_side_i == 1'd0)
				res_next = residual_q + $signed({1'b0, filled_qty_i});
			else
				res_next = residual_q - $signed({1'b0, filled_qty_i});
		end
		pending_d = pend_next;
		residual_d = res_next;
		if (!error_d) begin
			ask_price_d = ask_price_q;
			bid_price_d = bid_price_q;
			arb_qty_d = arb_qty_q;
			ask_market_d = ask_market_q;
			bid_market_d = bid_market_q;
			case (state_q)
				2'd0: begin
					arb0 = ((bid_qty0_i > 0) && (ask_qty1_i > 0)) && (bid_price0_i > (ask_price1_i + ARB_THRESHOLD));
					arb1 = ((bid_qty1_i > 0) && (ask_qty0_i > 0)) && (bid_price1_i > (ask_price0_i + ARB_THRESHOLD));
					if (arb0) begin
						ask_market_d = 1'sb0;
						bid_market_d = 1'sb1;
						ask_price_d = bid_price0_i;
						bid_price_d = ask_price1_i;
						arb_qty_d = (bid_qty0_i < ask_qty1_i ? bid_qty0_i : ask_qty1_i);
						state_d = 2'd1;
					end
					else if (arb1) begin
						ask_market_d = 1'sb1;
						bid_market_d = 1'sb0;
						ask_price_d = bid_price1_i;
						bid_price_d = ask_price0_i;
						arb_qty_d = (bid_qty1_i < ask_qty0_i ? bid_qty1_i : ask_qty0_i);
						state_d = 2'd1;
					end
				end
				2'd1: begin
					valid_o = 1'sb1;
					market_o = ask_market_q;
					side_o = 1'd1;
					price_o = ask_price_q;
					qty_o = arb_qty_q;
					pending_d = pend_next + 1'b1;
					state_d = 2'd2;
				end
				2'd2: begin
					valid_o = 1'sb1;
					market_o = bid_market_q;
					side_o = 1'd0;
					price_o = bid_price_q;
					qty_o = arb_qty_q;
					pending_d = pend_next + 1'b1;
					state_d = 2'd3;
				end
				2'd3:
					if (pending_q == 0) begin
						if (residual_q == 0)
							state_d = 2'd0;
						else begin
							sell = residual_q > 0;
							res_qty = (sell ? residual_q : -residual_q);
							price0 = (sell ? bid_price0_i : ask_price0_i);
							price1 = (sell ? bid_price1_i : ask_price1_i);
							quantity0 = (sell ? bid_qty0_i : ask_qty0_i);
							quantity1 = (sell ? bid_qty1_i : ask_qty1_i);
							liquid0 = quantity0 != 0;
							liquid1 = quantity1 != 0;
							if (liquid0 && liquid1)
								market = (sell ? price1 > price0 : price1 < price0);
							else if (liquid1)
								market = 1'b1;
							else
								market = 1'b0;
							if (liquid0 || liquid1) begin
								valid_o = 1'b1;
								market_o = market;
								side_o = (sell ? 1'd1 : 1'd0);
								price_o = (market ? price1 : price0);
								qty_o = res_qty;
								pending_d = pend_next + 1'b1;
							end
							else
								valid_o = 1'b0;
						end
					end
				default: state_d = 2'd0;
			endcase
		end
	end
	initial _sv2v_0 = 0;
endmodule
module momentum_trader (
	clk_i,
	rst_ni,
	bid_price_i,
	bid_qty_i,
	ask_price_i,
	ask_qty_i,
	bid_qty_sum_i,
	ask_qty_sum_i,
	order_filled_i,
	filled_price_i,
	filled_qty_i,
	filled_side_i,
	grant_i,
	valid_o,
	side_o,
	price_o,
	qty_o,
	error_o
);
	reg _sv2v_0;
	parameter signed [31:0] N = 8;
	parameter signed [31:0] IMB_THRESHOLD = 2;
	parameter signed [31:0] ORDER_QTY = 32;
	parameter signed [31:0] MAX_POS = 8 * ORDER_QTY;
	input wire clk_i;
	input wire rst_ni;
	localparam [31:0] orderbook_pkg_PRICE_WIDTH = 9;
	input wire [8:0] bid_price_i;
	localparam [31:0] orderbook_pkg_QTY_WIDTH = 8;
	input wire [7:0] bid_qty_i;
	input wire [8:0] ask_price_i;
	input wire [7:0] ask_qty_i;
	input wire [($clog2(N) + orderbook_pkg_QTY_WIDTH) - 1:0] bid_qty_sum_i;
	input wire [($clog2(N) + orderbook_pkg_QTY_WIDTH) - 1:0] ask_qty_sum_i;
	input wire order_filled_i;
	input wire [8:0] filled_price_i;
	input wire [7:0] filled_qty_i;
	input wire filled_side_i;
	input wire grant_i;
	output reg valid_o;
	output reg side_o;
	output reg [8:0] price_o;
	output reg [7:0] qty_o;
	output reg error_o;
	reg [1:0] state_q;
	reg [1:0] state_d;
	reg [1:0] pending_q;
	reg [1:0] pending_d;
	reg signed [$clog2(MAX_POS) + 1:0] position_q;
	reg signed [$clog2(MAX_POS) + 1:0] position_d;
	reg error_q;
	reg error_d;
	reg order_side_q;
	reg order_side_d;
	reg [8:0] order_price_q;
	reg [8:0] order_price_d;
	reg [7:0] order_qty_q;
	reg [7:0] order_qty_d;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			state_q <= 2'd0;
			pending_q <= 1'sb0;
			error_q <= 1'sb0;
			order_side_q <= 1'd0;
			order_price_q <= 1'sb0;
			order_qty_q <= 1'sb0;
			position_q <= 1'sb0;
		end
		else begin
			state_q <= state_d;
			pending_q <= pending_d;
			position_q <= position_d;
			error_q <= error_d;
			order_side_q <= order_side_d;
			order_price_q <= order_price_d;
			order_qty_q <= order_qty_d;
		end
	function automatic [7:0] orderbook_pkg_min3;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		input reg signed [31:0] c;
		reg signed [31:0] m;
		begin
			m = (a < b ? (a < c ? a : c) : (b < c ? b : c));
			orderbook_pkg_min3 = m[7:0];
		end
	endfunction
	always @(*) begin : sv2v_autoblock_1
		reg buy_signal;
		reg sell_signal;
		reg signed [($clog2(N) + orderbook_pkg_QTY_WIDTH) + 1:0] imb;
		reg signed [$clog2(MAX_POS) + 1:0] pos_next;
		reg [1:0] pend_next;
		if (_sv2v_0)
			;
		state_d = state_q;
		order_side_d = order_side_q;
		order_price_d = order_price_q;
		order_qty_d = order_qty_q;
		error_d = error_q | (order_filled_i && (pending_q == 0));
		valid_o = 1'sb0;
		side_o = 1'd0;
		price_o = 1'sb0;
		qty_o = 1'sb0;
		error_o = error_d;
		pos_next = position_q;
		pend_next = pending_q;
		if (!error_d && order_filled_i) begin
			pend_next = pending_q - 1'b1;
			if (filled_side_i == 1'd0)
				pos_next = position_q + filled_qty_i;
			else
				pos_next = position_q - filled_qty_i;
		end
		position_d = pos_next;
		pending_d = pend_next;
		if (!error_d) begin
			order_side_d = order_side_q;
			order_price_d = order_price_q;
			order_qty_d = order_qty_q;
			case (state_q)
				2'd0: begin
					imb = $signed({1'b0, bid_qty_sum_i}) - $signed({1'b0, ask_qty_sum_i});
					buy_signal = ((imb > IMB_THRESHOLD) && (pos_next < +MAX_POS)) && (ask_qty_i != 0);
					sell_signal = ((imb < -IMB_THRESHOLD) && (pos_next > -MAX_POS)) && (bid_qty_i != 0);
					if (buy_signal) begin
						order_side_d = 1'd0;
						order_price_d = ask_price_i;
						order_qty_d = orderbook_pkg_min3(ORDER_QTY, ask_qty_i, MAX_POS - pos_next);
						state_d = 2'd1;
					end
					else if (sell_signal) begin
						order_side_d = 1'd1;
						order_price_d = bid_price_i;
						order_qty_d = orderbook_pkg_min3(ORDER_QTY, bid_qty_i, MAX_POS + pos_next);
						state_d = 2'd1;
					end
				end
				2'd1: begin
					valid_o = 1'sb1;
					side_o = order_side_q;
					price_o = order_price_q;
					qty_o = order_qty_q;
					if (grant_i) begin
						pending_d = pend_next + 1'b1;
						state_d = 2'd2;
					end
				end
				2'd2:
					if (pend_next == 0)
						state_d = 2'd0;
				default: state_d = 2'd0;
			endcase
		end
	end
	initial _sv2v_0 = 0;
endmodule
module ema_trader (
	clk_i,
	rst_ni,
	bid_price_i,
	bid_qty_i,
	ask_price_i,
	ask_qty_i,
	order_filled_i,
	filled_price_i,
	filled_qty_i,
	filled_side_i,
	grant_i,
	valid_o,
	side_o,
	price_o,
	qty_o,
	error_o
);
	reg _sv2v_0;
	parameter signed [31:0] EMA_SHIFT = 4;
	parameter signed [31:0] DEV_THRESHOLD = 4;
	parameter signed [31:0] ORDER_QTY = 32;
	parameter signed [31:0] MAX_POS = 8 * ORDER_QTY;
	input wire clk_i;
	input wire rst_ni;
	localparam [31:0] orderbook_pkg_PRICE_WIDTH = 9;
	input wire [8:0] bid_price_i;
	localparam [31:0] orderbook_pkg_QTY_WIDTH = 8;
	input wire [7:0] bid_qty_i;
	input wire [8:0] ask_price_i;
	input wire [7:0] ask_qty_i;
	input wire order_filled_i;
	input wire [8:0] filled_price_i;
	input wire [7:0] filled_qty_i;
	input wire filled_side_i;
	input wire grant_i;
	output reg valid_o;
	output reg side_o;
	output reg [8:0] price_o;
	output reg [7:0] qty_o;
	output reg error_o;
	reg [1:0] state_q;
	reg [1:0] state_d;
	reg [1:0] pending_q;
	reg [1:0] pending_d;
	reg signed [$clog2(MAX_POS) + 1:0] position_q;
	reg signed [$clog2(MAX_POS) + 1:0] position_d;
	reg error_q;
	reg error_d;
	reg signed [orderbook_pkg_PRICE_WIDTH + EMA_SHIFT:0] ema_q;
	reg signed [orderbook_pkg_PRICE_WIDTH + EMA_SHIFT:0] ema_d;
	reg ema_init_q;
	reg ema_init_d;
	reg order_side_q;
	reg order_side_d;
	reg [8:0] order_price_q;
	reg [8:0] order_price_d;
	reg [7:0] order_qty_q;
	reg [7:0] order_qty_d;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			state_q <= 2'd0;
			pending_q <= 1'sb0;
			error_q <= 1'sb0;
			ema_q <= 1'sb0;
			ema_init_q <= 1'sb0;
			order_side_q <= 1'd0;
			order_price_q <= 1'sb0;
			order_qty_q <= 1'sb0;
			position_q <= 1'sb0;
		end
		else begin
			state_q <= state_d;
			pending_q <= pending_d;
			position_q <= position_d;
			error_q <= error_d;
			ema_q <= ema_d;
			ema_init_q <= ema_init_d;
			order_side_q <= order_side_d;
			order_price_q <= order_price_d;
			order_qty_q <= order_qty_d;
		end
	function automatic [7:0] orderbook_pkg_min3;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		input reg signed [31:0] c;
		reg signed [31:0] m;
		begin
			m = (a < b ? (a < c ? a : c) : (b < c ? b : c));
			orderbook_pkg_min3 = m[7:0];
		end
	endfunction
	always @(*) begin : sv2v_autoblock_1
		reg [orderbook_pkg_PRICE_WIDTH:0] mid;
		reg signed [orderbook_pkg_PRICE_WIDTH + EMA_SHIFT:0] mid_scaled;
		reg signed [10:0] dev;
		reg both_liquid;
		reg buy_signal;
		reg sell_signal;
		reg signed [$clog2(MAX_POS) + 1:0] pos_next;
		reg [1:0] pend_next;
		if (_sv2v_0)
			;
		state_d = state_q;
		error_d = error_q | (order_filled_i && (pending_q == 0));
		ema_d = ema_q;
		ema_init_d = ema_init_q;
		order_side_d = order_side_q;
		order_price_d = order_price_q;
		order_qty_d = order_qty_q;
		valid_o = 1'sb0;
		side_o = 1'd0;
		price_o = 1'sb0;
		qty_o = 1'sb0;
		error_o = error_d;
		both_liquid = (bid_qty_i != 0) && (ask_qty_i != 0);
		mid = ({1'b0, bid_price_i} + {1'b0, ask_price_i}) >> 1;
		mid_scaled = $signed({1'b0, mid}) <<< EMA_SHIFT;
		if (both_liquid) begin
			if (!ema_init_q) begin
				ema_d = mid_scaled;
				ema_init_d = 1'b1;
			end
			else
				ema_d = ema_q + ((mid_scaled - ema_q) >>> EMA_SHIFT);
		end
		pos_next = position_q;
		pend_next = pending_q;
		if (!error_d && order_filled_i) begin
			pend_next = pending_q - 1'b1;
			if (filled_side_i == 1'd0)
				pos_next = position_q + filled_qty_i;
			else
				pos_next = position_q - filled_qty_i;
		end
		position_d = pos_next;
		pending_d = pend_next;
		if (!error_d) begin
			order_side_d = order_side_q;
			order_price_d = order_price_q;
			order_qty_d = order_qty_q;
			case (state_q)
				2'd0: begin
					dev = $signed((mid_scaled - ema_d) >>> EMA_SHIFT);
					buy_signal = ((ema_init_q && both_liquid) && (dev < -DEV_THRESHOLD)) && (pos_next < MAX_POS);
					sell_signal = ((ema_init_q && both_liquid) && (dev > DEV_THRESHOLD)) && (pos_next > -MAX_POS);
					if (buy_signal) begin
						order_side_d = 1'd0;
						order_price_d = ask_price_i;
						order_qty_d = orderbook_pkg_min3(ORDER_QTY, ask_qty_i, MAX_POS - pos_next);
						state_d = 2'd1;
					end
					else if (sell_signal) begin
						order_side_d = 1'd1;
						order_price_d = bid_price_i;
						order_qty_d = orderbook_pkg_min3(ORDER_QTY, bid_qty_i, MAX_POS + pos_next);
						state_d = 2'd1;
					end
				end
				2'd1: begin
					valid_o = 1'sb1;
					side_o = order_side_q;
					price_o = order_price_q;
					qty_o = order_qty_q;
					if (grant_i) begin
						pending_d = pend_next + 1'b1;
						state_d = 2'd2;
					end
				end
				2'd2:
					if (pend_next == 0)
						state_d = 2'd0;
				default: state_d = 2'd0;
			endcase
		end
	end
	initial _sv2v_0 = 0;
endmodule
module hft_core (
	clk_i,
	rst_ni,
	valid_i,
	message_type_i,
	market_i,
	op_i,
	side_i,
	price_i,
	qty_i,
	valid_o,
	market_o,
	side_o,
	price_o,
	qty_o,
	error_o
);
	reg _sv2v_0;
	parameter signed [31:0] N = 8;
	parameter [0:0] OB_UNSORTED = 1'b1;
	input wire clk_i;
	input wire rst_ni;
	input wire valid_i;
	input wire message_type_i;
	input wire [1:0] market_i;
	input wire op_i;
	input wire side_i;
	localparam [31:0] orderbook_pkg_PRICE_WIDTH = 9;
	input wire [8:0] price_i;
	localparam [31:0] orderbook_pkg_QTY_WIDTH = 8;
	input wire [7:0] qty_i;
	output wire valid_o;
	output wire [1:0] market_o;
	output wire side_o;
	output wire [8:0] price_o;
	output wire [7:0] qty_o;
	output wire error_o;
	localparam signed [31:0] SUM_WIDTH = $clog2(N) + orderbook_pkg_QTY_WIDTH;
	wire [35:0] bid_best_price;
	wire [35:0] ask_best_price;
	wire [31:0] bid_best_qty;
	wire [31:0] ask_best_qty;
	reg [35:0] bid_price0_q;
	reg [35:0] ask_price0_q;
	reg [31:0] bid_qty0_q;
	reg [31:0] ask_qty0_q;
	wire [SUM_WIDTH - 1:0] bid_qty_sum2;
	wire [SUM_WIDTH - 1:0] ask_qty_sum2;
	reg [SUM_WIDTH - 1:0] bid_qty_sum2_q;
	reg [SUM_WIDTH - 1:0] ask_qty_sum2_q;
	localparam [8:0] orderbook_pkg_DEFAULT_ASK = 1'sb1;
	localparam [8:0] orderbook_pkg_DEFAULT_BID = 1'sb0;
	function automatic [8:0] sv2v_cast_DC923;
		input reg [8:0] inp;
		sv2v_cast_DC923 = inp;
	endfunction
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			bid_price0_q <= {4 {sv2v_cast_DC923(orderbook_pkg_DEFAULT_BID)}};
			ask_price0_q <= {4 {sv2v_cast_DC923(orderbook_pkg_DEFAULT_ASK)}};
			bid_qty0_q <= 1'sb0;
			ask_qty0_q <= 1'sb0;
			bid_qty_sum2_q <= 1'sb0;
			ask_qty_sum2_q <= 1'sb0;
		end
		else begin
			begin : sv2v_autoblock_1
				reg signed [31:0] i;
				for (i = 0; i < 4; i = i + 1)
					begin
						bid_price0_q[i * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH] <= bid_best_price[i * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH];
						ask_price0_q[i * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH] <= ask_best_price[i * orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH];
						bid_qty0_q[i * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] <= bid_best_qty[i * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH];
						ask_qty0_q[i * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH] <= ask_best_qty[i * orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH];
					end
			end
			bid_qty_sum2_q <= bid_qty_sum2;
			ask_qty_sum2_q <= ask_qty_sum2;
		end
	wire [3:0] error_ob;
	wire [2:0] error_trader;
	reg [3:0] valid_ob;
	reg [2:0] valid_trader;
	wire valid_arb;
	wire valid_mom;
	wire valid_ema;
	wire side_arb;
	wire side_mom;
	wire side_ema;
	wire [8:0] price_arb;
	wire [8:0] price_mom;
	wire [8:0] price_ema;
	wire [7:0] qty_arb;
	wire [7:0] qty_mom;
	wire [7:0] qty_ema;
	wire market_arb;
	wire grant_mom;
	wire grant_ema;
	assign grant_mom = valid_mom & ~valid_arb;
	assign grant_ema = (valid_ema & ~valid_arb) & ~valid_mom;
	function automatic signed [1:0] sv2v_cast_2_signed;
		input reg signed [1:0] inp;
		sv2v_cast_2_signed = inp;
	endfunction
	always @(*) begin
		if (_sv2v_0)
			;
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < 4; i = i + 1)
				valid_ob[i] = (valid_i & (message_type_i == 1'd0)) & (market_i == sv2v_cast_2_signed(i));
		end
		valid_trader[0] = (valid_i & (message_type_i == 1'd1)) & (market_i < 2);
		valid_trader[1] = (valid_i & (message_type_i == 1'd1)) & (market_i == 2);
		valid_trader[2] = (valid_i & (message_type_i == 1'd1)) & (market_i == 3);
	end
	assign valid_o = (valid_arb | valid_mom) | valid_ema;
	assign market_o = (valid_arb ? {1'b0, market_arb} : (valid_mom ? 2'd2 : 2'd3));
	assign side_o = (valid_arb ? side_arb : (valid_mom ? side_mom : side_ema));
	assign price_o = (valid_arb ? price_arb : (valid_mom ? price_mom : price_ema));
	assign qty_o = (valid_arb ? qty_arb : (valid_mom ? qty_mom : qty_ema));
	assign error_o = |error_ob | (|error_trader);
	orderbook #(
		.N(N),
		.UNSORTED(OB_UNSORTED)
	) orderbook0_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(valid_ob[0]),
		.op_i(op_i),
		.side_i(side_i),
		.price_i(price_i),
		.qty_i(qty_i),
		.best_bid_price_o(bid_best_price[0+:orderbook_pkg_PRICE_WIDTH]),
		.best_bid_qty_o(bid_best_qty[0+:orderbook_pkg_QTY_WIDTH]),
		.best_ask_price_o(ask_best_price[0+:orderbook_pkg_PRICE_WIDTH]),
		.best_ask_qty_o(ask_best_qty[0+:orderbook_pkg_QTY_WIDTH]),
		.bid_qty_sum_o(),
		.ask_qty_sum_o(),
		.error_o(error_ob[0])
	);
	orderbook #(
		.N(N),
		.UNSORTED(OB_UNSORTED)
	) orderbook1_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(valid_ob[1]),
		.op_i(op_i),
		.side_i(side_i),
		.price_i(price_i),
		.qty_i(qty_i),
		.best_bid_price_o(bid_best_price[orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH]),
		.best_bid_qty_o(bid_best_qty[orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH]),
		.best_ask_price_o(ask_best_price[orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH]),
		.best_ask_qty_o(ask_best_qty[orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH]),
		.bid_qty_sum_o(),
		.ask_qty_sum_o(),
		.error_o(error_ob[1])
	);
	orderbook #(
		.N(N),
		.UNSORTED(OB_UNSORTED)
	) orderbook2_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(valid_ob[2]),
		.op_i(op_i),
		.side_i(side_i),
		.price_i(price_i),
		.qty_i(qty_i),
		.best_bid_price_o(bid_best_price[18+:orderbook_pkg_PRICE_WIDTH]),
		.best_bid_qty_o(bid_best_qty[16+:orderbook_pkg_QTY_WIDTH]),
		.best_ask_price_o(ask_best_price[18+:orderbook_pkg_PRICE_WIDTH]),
		.best_ask_qty_o(ask_best_qty[16+:orderbook_pkg_QTY_WIDTH]),
		.bid_qty_sum_o(bid_qty_sum2),
		.ask_qty_sum_o(ask_qty_sum2),
		.error_o(error_ob[2])
	);
	orderbook #(
		.N(N),
		.UNSORTED(OB_UNSORTED)
	) orderbook3_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(valid_ob[3]),
		.op_i(op_i),
		.side_i(side_i),
		.price_i(price_i),
		.qty_i(qty_i),
		.best_bid_price_o(bid_best_price[27+:orderbook_pkg_PRICE_WIDTH]),
		.best_bid_qty_o(bid_best_qty[24+:orderbook_pkg_QTY_WIDTH]),
		.best_ask_price_o(ask_best_price[27+:orderbook_pkg_PRICE_WIDTH]),
		.best_ask_qty_o(ask_best_qty[24+:orderbook_pkg_QTY_WIDTH]),
		.bid_qty_sum_o(),
		.ask_qty_sum_o(),
		.error_o(error_ob[3])
	);
	arb_trader arb_trader_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.bid_price0_i(bid_price0_q[0+:orderbook_pkg_PRICE_WIDTH]),
		.bid_qty0_i(bid_qty0_q[0+:orderbook_pkg_QTY_WIDTH]),
		.ask_price0_i(ask_price0_q[0+:orderbook_pkg_PRICE_WIDTH]),
		.ask_qty0_i(ask_qty0_q[0+:orderbook_pkg_QTY_WIDTH]),
		.bid_price1_i(bid_price0_q[orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH]),
		.bid_qty1_i(bid_qty0_q[orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH]),
		.ask_price1_i(ask_price0_q[orderbook_pkg_PRICE_WIDTH+:orderbook_pkg_PRICE_WIDTH]),
		.ask_qty1_i(ask_qty0_q[orderbook_pkg_QTY_WIDTH+:orderbook_pkg_QTY_WIDTH]),
		.order_filled_i(valid_trader[0]),
		.filled_price_i(price_i),
		.filled_qty_i(qty_i),
		.filled_side_i(side_i),
		.valid_o(valid_arb),
		.market_o(market_arb),
		.side_o(side_arb),
		.price_o(price_arb),
		.qty_o(qty_arb),
		.error_o(error_trader[0])
	);
	momentum_trader #(.N(N)) mom_trader_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.bid_price_i(bid_price0_q[18+:orderbook_pkg_PRICE_WIDTH]),
		.bid_qty_i(bid_qty0_q[16+:orderbook_pkg_QTY_WIDTH]),
		.ask_price_i(ask_price0_q[18+:orderbook_pkg_PRICE_WIDTH]),
		.ask_qty_i(ask_qty0_q[16+:orderbook_pkg_QTY_WIDTH]),
		.bid_qty_sum_i(bid_qty_sum2_q),
		.ask_qty_sum_i(ask_qty_sum2_q),
		.order_filled_i(valid_trader[1]),
		.filled_price_i(price_i),
		.filled_qty_i(qty_i),
		.filled_side_i(side_i),
		.grant_i(grant_mom),
		.valid_o(valid_mom),
		.side_o(side_mom),
		.price_o(price_mom),
		.qty_o(qty_mom),
		.error_o(error_trader[1])
	);
	ema_trader ema_trader_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.bid_price_i(bid_price0_q[27+:orderbook_pkg_PRICE_WIDTH]),
		.bid_qty_i(bid_qty0_q[24+:orderbook_pkg_QTY_WIDTH]),
		.ask_price_i(ask_price0_q[27+:orderbook_pkg_PRICE_WIDTH]),
		.ask_qty_i(ask_qty0_q[24+:orderbook_pkg_QTY_WIDTH]),
		.order_filled_i(valid_trader[2]),
		.filled_price_i(price_i),
		.filled_qty_i(qty_i),
		.filled_side_i(side_i),
		.grant_i(grant_ema),
		.valid_o(valid_ema),
		.side_o(side_ema),
		.price_o(price_ema),
		.qty_o(qty_ema),
		.error_o(error_trader[2])
	);
	initial _sv2v_0 = 0;
endmodule
