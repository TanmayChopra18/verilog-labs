module and_beh_before (
  input      a,
  input      b,
  output reg y
);

  always @(*)
    #5 y = a & b;

endmodule