library verilog;
use verilog.vl_types.all;
entity branch_adder is
    port(
        zero            : in     vl_logic;
        branch          : in     vl_logic_vector(1 downto 0);
        pcsrc           : out    vl_logic
    );
end branch_adder;
