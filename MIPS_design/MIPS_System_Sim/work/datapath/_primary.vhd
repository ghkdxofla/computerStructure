library verilog;
use verilog.vl_types.all;
entity datapath is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        signext         : in     vl_logic;
        shiftl16        : in     vl_logic;
        memtoreg        : in     vl_logic_vector(1 downto 0);
        pcsrc           : in     vl_logic;
        alusrc          : in     vl_logic;
        regdst          : in     vl_logic_vector(1 downto 0);
        regwrite        : in     vl_logic;
        jump            : in     vl_logic_vector(1 downto 0);
        alucontrol      : in     vl_logic_vector(2 downto 0);
        jrjump          : in     vl_logic_vector(1 downto 0);
        zero            : out    vl_logic;
        pc              : out    vl_logic_vector(31 downto 0);
        instr           : in     vl_logic_vector(31 downto 0);
        aluout          : out    vl_logic_vector(31 downto 0);
        writedata       : out    vl_logic_vector(31 downto 0);
        readdata        : in     vl_logic_vector(31 downto 0)
    );
end datapath;
