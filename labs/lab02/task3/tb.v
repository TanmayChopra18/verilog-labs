// tb.v
module tb;

  reg  [1:0] t_a, t_b;
  wire       t_gt, t_lt, t_eq;

  reg        exp_gt, exp_lt, exp_eq;
  integer    errors;

  comp2 DUT (
    .A  (t_a),
    .B  (t_b),
    .GT (t_gt),
    .LT (t_lt),
    .EQ (t_eq)
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
      #1; // let outputs settle
      exp_gt = (t_a > t_b);
      exp_lt = (t_a < t_b);
      exp_eq = (t_a == t_b);

      if (t_gt !== exp_gt || t_lt !== exp_lt || t_eq !== exp_eq) begin
        errors = errors + 1;
        $display("MISMATCH at t=%0t: A=%d B=%d | got GT=%b LT=%b EQ=%b | expected GT=%b LT=%b EQ=%b",
                  $time, t_a, t_b, t_gt, t_lt, t_eq, exp_gt, exp_lt, exp_eq);
      end
    end
  endtask

  integer i, j;
  initial begin
    errors = 0;
    for (i = 0; i < 4; i = i + 1) begin
      for (j = 0; j < 4; j = j + 1) begin
        t_a = i;
        t_b = j;
        check;
      end
    end

    if (errors == 0)
      $display("ALL TESTS PASSED");
    else
      $display("%0d MISMATCH(ES) FOUND", errors);

    $finish;
  end

  initial
    $monitor($time, " A=%d B=%d | GT=%b LT=%b EQ=%b", t_a, t_b, t_gt, t_lt, t_eq);

endmodule