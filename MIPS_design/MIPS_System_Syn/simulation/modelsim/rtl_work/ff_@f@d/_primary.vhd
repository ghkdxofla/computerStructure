library verilog;
use verilog.vl_types.all;
entity ff_FD is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        stall           : in     vl_logic;
        pcplus4_F       : in     vl_logic_vector(31 downto 0);
        instr_F         : in     vl_logic_vector(31 downto 0);
        pcplus4_D       : out    vl_logic_vector(31 downto 0);
        instr           : out    vl_logic_vector(31 downto 0)
    );
end ff_FD;
