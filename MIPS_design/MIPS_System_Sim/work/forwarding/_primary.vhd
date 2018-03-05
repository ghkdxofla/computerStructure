library verilog;
use verilog.vl_types.all;
entity forwarding is
    port(
        instr_D25       : in     vl_logic_vector(4 downto 0);
        instr_D20       : in     vl_logic_vector(4 downto 0);
        instr_E25       : in     vl_logic_vector(4 downto 0);
        instr_E20       : in     vl_logic_vector(4 downto 0);
        writereg_M      : in     vl_logic_vector(4 downto 0);
        writereg_W      : in     vl_logic_vector(4 downto 0);
        regwrite_M      : in     vl_logic;
        regwrite_W      : in     vl_logic;
        forward_rd1     : out    vl_logic_vector(1 downto 0);
        forward_rd2     : out    vl_logic_vector(1 downto 0);
        forward_dw1     : out    vl_logic;
        forward_dw2     : out    vl_logic
    );
end forwarding;
