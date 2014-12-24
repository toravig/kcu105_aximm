module synchronizer #(parameter WIDTH = 1)
  (
    input aclk,
    input areset_n,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout
  );

reg [WIDTH-1:0] din_r1;

always@(posedge aclk)
begin
  if(!areset_n)
  begin
    din_r1 <= {WIDTH{1'b0}};
    dout   <= {WIDTH{1'b0}};
  end
  else
  begin
    din_r1 <= din;
    dout   <= din_r1;
  end
end

endmodule
