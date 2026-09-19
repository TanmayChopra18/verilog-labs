module tb;

  reg  [3:0] t_a, t_b;
  reg        t_op;
  wire [3:0] t_result;

  reg  [3:0] exp_result;
  integer    errors;

  alu DUT (
    .a      (t_a),
    .b      (t_b),
    .op     (t_op),
    .result (t_result)
  );

  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  task check;
    begin
      #1;
      if (t_op == 1'b0)
        exp_result = t_a + t_b;
      else
        exp_result = t_a - t_b;

      if (t_result !== exp_result) begin
        errors = errors + 1;
        $display("MISMATCH at t=%0t: a=%d b=%d op=%b | got=%d expected=%d",
                  $time, t_a, t_b, t_op, t_result, exp_result);
      end
    end
  endtask

  initial begin
    errors = 0;

    // fix a,b -- toggle op only, to expose the sensitivity-list bug
    t_a = 4'd5; t_b = 4'd3;
    t_op = 0; check;
    t_op = 1; check;

    // now sweep a few add/sub combos with op fixed, to expose the sub-path bug
    t_op = 1;
    t_a = 4'd5; t_b = 4'd3; check;
    t_a = 4'd9; t_b = 4'd2; check;
    t_a = 4'd1; t_b = 4'd1; check;

    t_op = 0;
    t_a = 4'd7; t_b = 4'd6; check;

    if (errors == 0)
      $display("ALL TESTS PASSED");
    else
      $display("%0d MISMATCH(ES) FOUND", errors);

    $finish;
  end

  initial
    $monitor($time, " a=%d b=%d op=%b | result=%d", t_a, t_b, t_op, t_result);

endmodule